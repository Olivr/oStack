# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Static
  namespaces_static = local.namespaces_complex

  namespaces_repos_static = local.namespaces_repos_complex

  namespaces_backends_create = merge([for repo_id, repo in local.namespaces_repos_static :
    { for id, backend in repo.backends :
      "${repo_id}_${id}" => merge(backend, { repo_id = repo_id }) if backend.create == true
    }
  ]...)

  # Dynamic
  namespaces_repos_dynamic = { for repo_id, repo in local.namespaces_repos_static :
    repo_id => {
      vcs = {
        # If repo is protected by status checks pr PR reviews, don't write files (they are added to the configuration repo instead)
        files        = repo.vcs.branch_protection ? {} : lookup(local.namespaces_repos_files, repo_id, {})
        files_strict = repo.vcs.branch_protection ? {} : lookup(local.namespaces_repos_files_strict, repo_id, {})
        deploy_keys  = merge(repo.vcs.deploy_keys, lookup(local.namespaces_repos_deploy_keys, repo_id, null))
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Static defaults
# These are computable statically (without any resource created or any external data fetched)
# ---------------------------------------------------------------------------------------------------------------------
locals {
  namespaces_simple = { for id, namespace in var.namespaces :
    id => {
      id               = id
      title            = namespace.title
      name             = lookup(namespace, "name", null) != null && lookup(namespace, "name", "") != "" ? namespace.name : lower(trim(replace(replace("${var.prefix}${namespace.title}", "/[\\s_\\.]/", "-"), "/[^a-zA-Z0-9-]/", ""), "-"))
      description      = lookup(namespace, "description", null) != null && lookup(namespace, "description", "") != "" ? namespace.description : format(local.i18n.ns_description, namespace.title)
      environments     = lookup(namespace, "environments", null) != null ? namespace.environments : keys(local.environments)
      tenant_isolation = lookup(namespace, "tenant_isolation", null) != null ? namespace.tenant_isolation : local.gitops_configuration[var.gitops_default_provider].tenant_isolation
      repos            = try(length(namespace.repos) > 0 ? namespace.repos : tomap(false), {})
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Static computations
# These are computable statically (without any resource created or any external data fetched)
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Prepare repos
  # We add a _namespace key to access the parent namespace properties easily. It will be removed later.
  namespaces_repos_prepare = merge(flatten([
    for ns_id, namespace in local.namespaces_simple : [
      for repo_id, repo in namespace.repos : {
        "${ns_id}_${repo_id}" = merge(repo,
          {
            _namespace = { for k, v in namespace : k => v if !contains(["repos"], k) }
            id         = repo_id
          }
        )
      }
    ]
  ])...)

  # Repos to create: Ensure simple types are specified
  namespaces_repos_simple = { for id, repo in local.namespaces_repos_prepare :
    id => merge(repo,
      {
        name                = lookup(repo, "name", null) != null && lookup(repo, "name", "") != "" ? repo.name : lower(trim("${repo._namespace.name}-${replace(replace(repo.id, "/[\\s_\\.]/", "-"), "/[^a-zA-Z0-9-]/", "")}", "-"))
        description         = lookup(repo, "description", null) != null && lookup(repo, "description", "") != "" ? repo.description : format(local.i18n["repo_${repo.type}_description"], repo._namespace.title)
        backend             = try(length(repo.backend) > 0 ? repo.backend : tomap(false), {})
        vcs                 = try(length(repo.vcs) > 0 ? repo.vcs : tomap(false), {})
        continuous_delivery = lookup(repo, "continuous_delivery", null) != null ? repo.continuous_delivery : var.continuous_delivery
      }
    )
  }

  # Backends to create: Ensure provider is specified
  # We add a _repo key to access the parent repo properties easily. It will be removed later.
  namespaces_repos_backend_provider = { for id, repo in local.namespaces_repos_simple :
    id => merge(repo.backend,
      {
        _repo       = { for k, v in repo : k => v if !contains(["backend", "vcs"], k) }
        provider    = lookup(repo.backend, "provider", null) != null ? repo.backend.provider : var.backend_default_provider
        name        = repo.name
        description = repo.description
        auto_apply  = repo.continuous_delivery
      }
    ) if repo.type == "infra"
  }

  # Backends to create: Ensure simple types are specified
  namespaces_repos_backend_simple = { for id, backend in local.namespaces_repos_backend_provider :
    id => merge(backend,
      { for setting, default_value in local.backend_configuration[backend.provider] :
        setting => lookup(backend, setting, null) != null ? backend[setting] : default_value
      }
    )
  }

  # Backends to create: Ensure complex types are specified
  namespaces_repos_backend_complex = { for id, backend in local.namespaces_repos_backend_simple :
    id => merge(backend,
      {
        env_vars    = merge(local.backend_configuration[backend.provider].env_vars, backend.env_vars)
        tf_vars     = merge(local.backend_configuration[backend.provider].tf_vars, backend.tf_vars)
        tf_vars_hcl = merge(local.backend_configuration[backend.provider].tf_vars_hcl, backend.tf_vars_hcl)
      }
    )
  }

  # Backends to create: Get relevant sensitive inputs
  namespaces_repos_backend_sensitive = { for id, backend in local.namespaces_repos_backend_complex :
    id => merge(backend,
      {
        sensitive_inputs = merge(
          { for k, v in backend.env_vars : trimprefix(v, "sensitive::") => sensitive(var.sensitive_inputs[trimprefix(v, "sensitive::")]) if can(regex("^sensitive::", v)) },
          { for k, v in backend.tf_vars : trimprefix(v, "sensitive::") => sensitive(var.sensitive_inputs[trimprefix(v, "sensitive::")]) if can(regex("^sensitive::", v)) },
          { for k, v in backend.tf_vars_hcl : trimprefix(v, "sensitive::") => sensitive(var.sensitive_inputs[trimprefix(v, "sensitive::")]) if can(regex("^sensitive::", v)) },
        )
      }
    )
  }

  # Backends to create: Define multiple backends per environment if needed
  namespaces_repos_backend_env = { for repo_id, backend in local.namespaces_repos_backend_sensitive :
    repo_id => !backend.combine_environments ? { for env_id, env in local.environments :
      env_id => merge(backend, {
        name                  = "${backend._repo.name}-${env.name}"
        description           = "${backend._repo.description} (${env.name})"
        vcs_working_directory = env.name
        auto_apply            = env.continuous_delivery && backend.auto_apply
        vcs_trigger_paths     = ["shared-modules"]
      })
    } : { "combined" = backend }
  }



  # VCS repos to create: Ensure provider is specified
  # We add a _repo key to access the parent repo properties easily. It will be removed later.
  namespaces_repos_vcs_provider = { for id, repo in local.namespaces_repos_simple :
    id => merge(repo.vcs,
      {
        _repo    = { for k, v in repo : k => v if !contains(["backend", "vcs"], k) }
        provider = lookup(repo.vcs, "provider", null) != null ? repo.vcs.provider : var.vcs_default_provider
      }
    )
  }

  # VCS repos to create: Ensure simple types are specified
  namespaces_repos_vcs_simple = { for id, vcs in local.namespaces_repos_vcs_provider :
    id => merge(vcs,
      { for setting, default_value in local.vcs_configuration[vcs.provider] :
        setting => lookup(vcs, setting, null) != null ? vcs[setting] : default_value if !contains(["tags", "repo_template"], setting)
      }
    )
  }

  # VCS repos to create: Ensure complex types are specified
  namespaces_repos_vcs_complex = { for id, vcs in local.namespaces_repos_vcs_simple :
    id => merge(vcs, {
      full_name     = "${local.vcs_organization_name}/${vcs._repo.name}"
      http_url      = format(local.vcs_provider_configuration[vcs.provider].http_format, vcs._repo.name)
      ssh_url       = format(local.vcs_provider_configuration[vcs.provider].ssh_format, vcs._repo.name)
      repo_template = lookup(vcs, "repo_template", null) != null ? vcs.repo_template : local.vcs_provider_configuration[vcs.provider].repo_templates[vcs._repo.type]
      reviewers = {
        "*" = ["global_${vcs._repo.type}_lead", "${vcs._repo._namespace.id}_${vcs._repo.type}_lead"]
      }

      file_templates = { for name, default_content in local.vcs_configuration[vcs.provider].file_templates :
        name => lookup(vcs.file_templates, name, null) != null ? vcs.file_templates[name] : default_content
      }

      tags = lookup(vcs, "tags", null) != null ? vcs.tags : setunion(
        local.vcs_configuration[vcs.provider].tags,
        [for env in vcs._repo._namespace.environments : local.environments[env].name],
        [
          vcs._repo._namespace.title,
          local.i18n["tag_${vcs._repo.type}_proper"],
          local.i18n["tag_${vcs._repo.type}_buzz"]
        ]
      )
    })
  }

  # VCS repos to create: Get relevant sensitive inputs
  namespaces_repos_vcs_sensitive = { for id, vcs in local.namespaces_repos_vcs_complex :
    id => merge(vcs,
      {
        sensitive_inputs = merge(
          { for k, v in vcs.repo_secrets :
            trimprefix(v, "sensitive::") => sensitive(var.sensitive_inputs[trimprefix(v, "sensitive::")]) if can(regex("^sensitive::", v))
          },
          { vcs_token_write = sensitive(var.vcs_token_write[var.vcs_default_provider]) }
        )
        repo_secrets = merge(vcs.repo_secrets, { VCS_WRITE_TOKEN = "sensitive::vcs_token_write" })
      }
    )
  }

  # VCS repos to create: Specify apps-specific values
  namespaces_repos_vcs_apps = { for id, vcs in local.namespaces_repos_vcs_sensitive :
    id => {
      team_configuration = {
        admin    = ["global_admin"]
        maintain = ["global_manager", "${vcs._repo._namespace.id}_manager", "global_apps_lead", "${vcs._repo._namespace.id}_apps_lead"]
        read     = ["global_infra", "global_ops", "${vcs._repo._namespace.id}_ops", "${vcs._repo._namespace.id}_infra"]
        write    = ["global_apps", "${vcs._repo._namespace.id}_apps"]
      }
    } if vcs._repo.type == "apps"
  }

  # VCS repos to create: Specify infra-specific values
  namespaces_repos_vcs_infra = { for id, vcs in local.namespaces_repos_vcs_sensitive :
    id => {
      branch_status_checks = [for backend in local.namespaces_repos_backend_env[id] :
        format(local.backend_provider_configuration[backend.provider].status_check_format, backend.name)
      ]
      team_configuration = {
        admin    = ["global_admin"]
        maintain = ["global_manager", "${vcs._repo._namespace.id}_manager", "global_infra_lead", "${vcs._repo._namespace.id}_infra_lead"]
        read     = ["global_ops", "global_apps", "${vcs._repo._namespace.id}_ops", "${vcs._repo._namespace.id}_apps"]
        write    = ["global_infra", "${vcs._repo._namespace.id}_infra"]
      }
    } if vcs._repo.type == "infra"
  }

  # VCS repos to create: Specify ops-specific values
  namespaces_repos_vcs_ops = { for id, vcs in local.namespaces_repos_vcs_sensitive :
    id => {
      team_configuration = {
        admin    = ["global_admin"]
        maintain = ["global_manager", "${vcs._repo._namespace.id}_manager"]
        read     = ["global_infra", "global_apps", "${vcs._repo._namespace.id}_apps", "${vcs._repo._namespace.id}_infra"]
        write    = ["global_ops", "${vcs._repo._namespace.id}_ops"]
      }
      reviewers = { for env in vcs._repo._namespace.environments :
        "/${local.environments[env].name}/**" => ["global_ops_${env}", "${vcs._repo._namespace.id}_ops_${env}"]
      }
    } if vcs._repo.type == "ops"
  }

  # VCS configuration & all backends per repo
  namespaces_repos_complex = { for id, repo in local.namespaces_repos_simple :
    id => merge(
      # Remove the obsolete backend key (now replaced by backends)
      { for k, v in repo :
        k => v if k != "backend"
      },
      {
        # Add the backends key
        backends = repo.type == "infra" ? { for backend_id, backend_settings in local.namespaces_repos_backend_env[id] :
          # Remove the _repo key for cleanup purposes
          backend_id => { for k, v in backend_settings :
            k => v if k != "_repo"
          }
        } : {}

        vcs = { for k, v in merge(
          local.namespaces_repos_vcs_sensitive[id],
          lookup(local.namespaces_repos_vcs_apps, id, {}),
          lookup(local.namespaces_repos_vcs_infra, id, {}),
          lookup(local.namespaces_repos_vcs_ops, id, {})
        ) : k => v if k != "_repo" } # Remove the _repo key
      },
    )
  }

  # All repos per namespace
  namespaces_complex = { for ns_id, namespace in local.namespaces_simple :
    ns_id => merge(namespace, {
      repos = { for repo_id in keys(namespace.repos) :
        repo_id => local.namespaces_repos_complex["${ns_id}_${repo_id}"]
      }
    })
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Dynamic computations
# These may require an output from a data/resource/module
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Prepare CODEONWERS files for managing code reviews
  namespaces_repos_files_codeowners_prepare = { for id, repo in local.namespaces_repos_static :
    id => { for path, owners in repo.vcs.reviewers :
      "CODEOWNERS" => join(" @${local.vcs_organization_name}/", concat([path], [for owner in owners : local.vcs_teams[repo.vcs.provider].teams[owner].slug]))...
    }
  }
  namespaces_repos_files_codeowners = { for id, files in local.namespaces_repos_files_codeowners_prepare :
    id => { for path, multiline in files :
      path => join("\n", multiline)
    }
  }

  # Files generated by GitOps module
  namespaces_repos_files_gitops = { for id, repo in local.namespaces_repos_static :
    id => local.gitops.ns_files[repo._namespace.id][repo.id] if repo.type == "ops"
  }

  # Raw files per repo
  namespaces_repos_files_prepare = { for id, repo in local.namespaces_repos_static :
    id => merge(
      lookup(local.dev, "all_files_strict", false) ? null : lookup(local.namespaces_repos_files_gitops, id, {}),
      lookup(local.dev, "all_files_strict", false) ? null : repo.vcs.files
    )
  }

  # Format each file with header/footer if any was specified in the file templates
  namespaces_repos_files_formatted = { for id, files in local.namespaces_repos_files_prepare :
    id => { for path, content in files :
      (path) => try(join("\n", concat(
        compact([lookup(local.namespaces_repos_static[id].file_templates, "${trimprefix(regex("/?[^/^]+$", lower(path)), "/")}_header", "")]),
        content,
        compact([lookup(local.namespaces_repos_static[id].file_templates, "${trimprefix(regex("/?[^/^]+$", lower(path)), "/")}_footer", "")])
      )), content)
    }
  }

  # Add template files if a local template was used
  namespaces_repos_files = { for id, repo in local.namespaces_repos_static :
    id => merge(
      lookup(local.dev, "all_files_strict", false) ? null : lookup(local.vcs_templates_files, repo.type, null),
      local.namespaces_repos_files_formatted[id]
    )
  }

  # Raw files per repo
  namespaces_repos_files_strict_prepare = { for id, repo in local.namespaces_repos_static :
    id => merge(
      local.namespaces_repos_files_codeowners[id],
      repo.type == "ops" ? local.gitops.ns_files_strict[repo._namespace.id][repo.id] : {},
      lookup(local.dev, "all_files_strict", false) ? lookup(local.namespaces_repos_files_gitops, id, null) : null,
      lookup(local.dev, "all_files_strict", false) ? repo.vcs.files : null,
      repo.vcs.files_strict,
    )
  }

  # Format each file with header/footer if any was specified in the file templates
  namespaces_repos_files_strict_formatted = { for id, files in local.namespaces_repos_files_strict_prepare :
    id => { for path, content in files :
      (path) => try(join("\n", concat(
        compact([lookup(local.namespaces_repos_static[id].file_templates, "${trimprefix(regex("/?[^/^]+$", lower(path)), "/")}_header", "")]),
        content,
        compact([lookup(local.namespaces_repos_static[id].file_templates, "${trimprefix(regex("/?[^/^]+$", lower(path)), "/")}_footer", "")])
      )), content)
    }
  }

  # Add template files if a local template was used
  namespaces_repos_files_strict = { for id, repo in local.namespaces_repos_static :
    id => merge(
      lookup(local.dev, "all_files_strict", false) ? lookup(local.vcs_templates_files, repo.type, null) : null,
      local.namespaces_repos_files_strict_formatted[id]
    )
  }

  namespaces_repos_deploy_keys = { for id, repo in local.namespaces_repos_static :
    id => merge(
      {
        _ci = {
          title    = "CI / GitHub Actions (${local.globalops_static.name}, ${repo.name})"
          ssh_key  = tls_private_key.ns_keys["${id}__ci"].public_key_openssh
          readonly = true
        }
      },
      { for cluster_id, cluster in local.environments_clusters_create :
        (cluster_id) => {
          title    = cluster.name
          ssh_key  = tls_private_key.ns_keys["${id}_${cluster_id}"].public_key_openssh
          readonly = true
        }
    }) if repo.type == "ops"
  }
}
