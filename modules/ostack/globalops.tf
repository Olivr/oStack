# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalops_backends_create = local.globalops_backends
  globalops_gitops_create   = local.globalops_gitops_defaults
  globalops_vcs_create      = local.globalops_vcs_defaults
  globalops_vcs_files_create = {
    files        = local.globalops_vcs_defaults.branch_protection ? {} : local.globalops_vcs_files
    files_strict = local.globalops_vcs_defaults.branch_protection ? {} : local.globalops_vcs_files_strict
  }

  globalops = merge(
    local.globalops_base,
    {
      backends = local.globalops_backends
      vcs      = local.globalops_vcs
      gitops   = local.globalops_gitops_defaults
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalops_base = {
    name                = "${var.prefix}${local.i18n.repo_globalops_name}"
    description         = local.i18n.repo_globalops_description
    continuous_delivery = var.continuous_delivery
  }

  globalops_vcs_base = {
    repo_http_url  = format(local.vcs_provider_config[var.vcs_default_provider].http_format, local.globalops_base.name)
    repo_ssh_url   = format(local.vcs_provider_config[var.vcs_default_provider].ssh_format, local.globalops_base.name)
    repo_full_name = "${local.vcs_organization_name}/${local.globalops_base.name}"
    repo_auto_init = true
    repo_template  = local.vcs_provider_config[var.vcs_default_provider].repo_templates.globalops
    branch_status_checks = setunion(
      local.vcs_config[var.vcs_default_provider].branch_status_checks,
      [for backend in local.globalops_backends_defaults :
        format(local.backend_provider_config[backend.provider].status_check_format, backend.name)
      ]
    )
    deploy_keys = merge(
      {
        _ci = {
          title    = "CI / GitHub Actions (${local.globalops_base.name})"
          ssh_key  = tls_private_key.ci_keys["_globalops"].public_key_openssh
          readonly = true
        }
      },
      { for id, cluster in local.environments_clusters :
        (id) => {
          title    = cluster.name
          ssh_key  = tls_private_key.cluster_keys[id].public_key_openssh
          readonly = true
        }
    })
    repo_secrets = {
      ci_sensitive_inputs = "sensitive::ci_sensitive_inputs"
    }
    sensitive_inputs = {
      ci_sensitive_inputs = jsonencode({
        sensitive_inputs = merge(
          {
            "${local.globalops_base.name}_private_key" = sensitive(tls_private_key.ci_keys["_globalops"].private_key_pem)
            "sops_gpg_key"                             = sensitive(gpg_private_key.ci_key.private_key)
          },
          { for ns_id, ns in local.namespaces_ops :
            "${ns_id}_gpg_key" => sensitive(gpg_private_key.ci_key.private_key)
          },
          { for id, repo in local.namespaces_repos_ops :
            "${repo.name}_private_key" => sensitive(tls_private_key.ci_keys[id].private_key_pem)
          }
        )
      })
    }
    tags = setunion(
      local.vcs_config[var.vcs_default_provider].tags,
      [
        local.i18n.tag_infra_proper,
        local.i18n.tag_infra_buzz,
        local.i18n.tag_ops_proper,
        local.i18n.tag_ops_buzz
      ]
    )
    team_config = {
      admin    = ["global_admin"]
      maintain = ["global_manager", "global_infra_lead"]
      read     = keys(local.teams) # All teams can read
      write    = ["global_ops", "global_infra"]
    }
  }

  globalops_gitops_base = {
    namespaces = { for ns_id, ns in local.namespaces_ops :
      ns_id => merge(ns, {
        gpg_keys = { for env_id in ns.environments :
          env_id => {
            name        = "${local.environments[env_id].name}-${ns.name}"
            fingerprint = gpg_private_key.ns_keys["${env_id}_${ns_id}"].fingerprint
            public_key  = gpg_private_key.ns_keys["${env_id}_${ns_id}"].public_key
          }
        }
      })
    }
    environments = local.environments
  }

  globalops_backends_base = { for cluster_id, cluster in local.environments_clusters :
    cluster_id => {
      auto_apply            = cluster._env.continuous_delivery
      description           = "${local.globalops_base.description} (${cluster.name})"
      name                  = "${local.globalops_base.name}-${cluster._env.name}-${cluster.name}"
      vcs_trigger_paths     = ["${local.globalops_gitops_defaults.infra_dir}/shared-modules"]
      vcs_working_directory = "${local.globalops_gitops_defaults.infra_dir}/${cluster._env.name}-${cluster.name}"
      tf_vars = {
        kube_host           = local.cloud_clusters_k8s[cluster_id].kube_host
        kube_token          = "sensitive::kube_token"
        kube_ca_certificate = local.cloud_clusters_k8s[cluster_id].kube_ca_certificate
      }
      tf_vars_hcl = {
        sensitive_inputs = "sensitive::sensitive_inputs"
      }
      sensitive_inputs = {
        kube_token = sensitive(local.cloud_clusters_k8s[cluster_id].kube_token)
        sensitive_inputs = replace(jsonencode(merge(
          # Global Ops
          {
            "sops_gpg_key"                             = try(gpg_private_key.cluster_keys[cluster_id].private_key, "")
            "${local.globalops_base.name}_private_key" = sensitive(tls_private_key.cluster_keys[cluster_id].private_key_pem)
            "${local.globalops_base.name}_vcs_token"   = sensitive(var.vcs_write_token[var.vcs_default_provider])
          },
          # Namespaces
          { for ns_id, ns in local.namespaces_ops :
            "${ns_id}_gpg_key" => sensitive(gpg_private_key.ns_keys["${cluster._env.id}_${ns_id}"].private_key) if contains(ns.environments, cluster._env.id)
          },
          # Repos
          merge([for id, repo in local.namespaces_repos_ops :
            {
              "${repo.name}_private_key" = sensitive(tls_private_key.ns_keys["${id}_${cluster_id}"].private_key_pem)
              "${repo.name}_vcs_token"   = sensitive(var.vcs_write_token[repo.vcs.provider])
            } if contains(repo._namespace.environments, cluster._env.id)
          ]...)
        )), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
      }
    } if cluster.bootstrap
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# These variables are referenced in this file only
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Merge globalops base VCS configuration with user-defined base configuration
  globalops_vcs_defaults = merge(
    # For map types, the base map and user map are merged
    { for setting, base_value in local.vcs_config[var.vcs_default_provider] :
      setting => merge(
        base_value,
        lookup(local.globalops_vcs_base, setting, null)
      ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
    },
    # For all other types (inc. set), overwrite by user-defined value
    { for setting, base_value in local.vcs_config[var.vcs_default_provider] :
      setting => lookup(local.globalops_vcs_base, setting, null) != null ? local.globalops_vcs_base[setting] : base_value if !can(keys(base_value))
    }
  )

  # Filter only relevant sensitive inputs
  globalops_vcs_sensitive_inputs = {
    sensitive_inputs = { for secret_value in values(local.globalops_vcs_defaults.repo_secrets) :
      trimprefix(secret_value, "sensitive::") => sensitive(
        merge(
          local.globalops_vcs_defaults.sensitive_inputs,
          var.sensitive_inputs
        )[trimprefix(secret_value, "sensitive::")]) if can(regex("^sensitive::", secret_value)
      )
    }
  }

  # Merge globalops base backend configuration with user-defined base configuration
  # For map types, the base map and user map are merged
  # For all other types (inc. set), overwrite by user-defined value
  globalops_backends_defaults = { for backend_id in keys(local.globalops_backends_base) :
    backend_id => merge(
      # For map types, the base map and user map are merged
      { for setting, base_value in local.backend_config[var.backend_default_provider] :
        setting => merge(
          base_value,
          lookup(local.globalops_backends_base[backend_id], setting, null)
        ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
      },
      # For all other types (inc. set), overwrite by user-defined value
      { for setting, base_value in local.backend_config[var.backend_default_provider] :
        setting => lookup(local.globalops_backends_base[backend_id], setting, null) != null ? local.globalops_backends_base[backend_id][setting] : base_value if !can(keys(base_value))
      }
    )
  }

  # Filter only relevant sensitive inputs
  globalops_backends_sensitive_inputs = { for backend_id, backend in local.globalops_backends_defaults :
    backend_id => {
      sensitive_inputs = { for secret_value in setunion(values(backend.env_vars), values(backend.tf_vars), values(backend.tf_vars_hcl)) :
        trimprefix(secret_value, "sensitive::") => sensitive(
          merge(
            backend.sensitive_inputs,
            var.sensitive_inputs
          )[trimprefix(secret_value, "sensitive::")]) if can(regex("^sensitive::", secret_value)
        )
      }
    }
  }

  globalops_backends = { for backend_id in keys(local.globalops_backends_base) :
    backend_id => merge(
      local.globalops_backends_defaults[backend_id],
      local.globalops_backends_sensitive_inputs[backend_id]
    )
  }

  # Merge globalops base GitOps configuration with user-defined base configuration
  # For map types, the base map and user map are merged
  # For all other types (inc. set), overwrite by user-defined value
  globalops_gitops_defaults = merge(
    # For map types, the base map and user map are merged
    { for setting, base_value in local.gitops_config[var.gitops_default_provider] :
      setting => merge(
        base_value,
        lookup(local.globalops_gitops_base, setting, null)
      ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
    },
    # For all other types (inc. set), overwrite by user-defined value
    { for setting, base_value in local.gitops_config[var.gitops_default_provider] :
      setting => lookup(local.globalops_gitops_base, setting, null) != null ? local.globalops_gitops_base[setting] : base_value if !can(keys(base_value))
    }
  )

  globalops_vcs_files_prepare = merge(
    lookup(local.dev, "all_files_strict", false) ? null : local.gitops.repo_files,
    lookup(local.dev, "all_files_strict", false) ? null : local.vcs_config[var.vcs_default_provider].files
  )

  globalops_vcs_files_formatted = { for file_path, content in local.globalops_vcs_files_prepare :
    (file_path) => try(join("\n", concat(
      compact([lookup(local.globalops_vcs_defaults.file_templates, "${trimprefix(regex("/?[^/^]+$", lower(file_path)), "/")}_header", "")]),
      content,
      compact([lookup(local.globalops_vcs_defaults.file_templates, "${trimprefix(regex("/?[^/^]+$", lower(file_path)), "/")}_footer", "")])
    )), content)
  }

  # Add template files if a local template was used
  globalops_vcs_files = merge(
    lookup(local.dev, "all_files_strict", false) ? null : lookup(local.vcs_templates_files, "globalops", null),
    local.globalops_vcs_files_formatted
  )

  globalops_vcs_files_strict_prepare = merge(
    lookup(local.dev, "all_files_strict", false) ? local.vcs_config[var.vcs_default_provider].files : null,
    lookup(local.dev, "all_files_strict", false) ? local.gitops.repo_files : null,
    local.gitops.repo_system_files,
    local.vcs_config[var.vcs_default_provider].files_strict,
  )

  globalops_vcs_files_strict_formatted = { for file_path, content in local.globalops_vcs_files_strict_prepare :
    (file_path) => try(join("\n", concat(
      compact([lookup(local.globalops_vcs_defaults.file_templates, "${trimprefix(regex("/?[^/^]+$", lower(file_path)), "/")}_header", "")]),
      content,
      compact([lookup(local.globalops_vcs_defaults.file_templates, "${trimprefix(regex("/?[^/^]+$", lower(file_path)), "/")}_footer", "")])
    )), content)
  }

  globalops_vcs_files_strict = merge(
    # Add template files if a local template was used
    lookup(local.dev, "all_files_strict", false) ? lookup(local.vcs_templates_files, "globalops", null) : null,
    local.globalops_vcs_files_strict_formatted
  )

  globalops_gitops_deploy_keys = { for cluster_id, cluster in merge(local.environments_clusters, { _ci = { name = "_ci" }, _dev = { name = "_dev" } }) :
    (cluster.name) => merge(
      {
        "globalops" = {
          name        = "flux-system"
          namespace   = "flux-system"
          known_hosts = local.vcs_provider_config[var.vcs_default_provider].known_hosts
          public_key = cluster.name == "_dev" ? "$${var.ssh_key_public_${var.vcs_default_provider}}" : base64encode(
            cluster.name == "_ci" ? tls_private_key.ci_keys["_globalops"].public_key_pem
            : tls_private_key.cluster_keys[cluster_id].public_key_pem
          )
          private_key = (
            cluster.name == "_dev" ? "$${var.ssh_key_private_${var.vcs_default_provider}}"
            : "sensitive::${local.globalops_base.name}_private_key"
          )
        }
      },
      { for repo_id, repo in local.namespaces_repos_ops :
        repo_id => {
          name        = "flux-${repo.name}"
          namespace   = repo._namespace.name
          known_hosts = local.vcs_provider_config[repo.vcs.provider].known_hosts
          public_key = cluster.name == "_dev" ? "$${var.ssh_key_public_${repo.vcs.provider}}" : base64encode(
            cluster.name == "_ci" ? tls_private_key.ci_keys[repo_id].public_key_pem
            : tls_private_key.ns_keys["${repo_id}_${cluster_id}"].public_key_pem
          )
          private_key = (
            cluster.name == "_dev" ? "$${var.ssh_key_private_${repo.vcs.provider}}"
            : "sensitive::${repo.name}_private_key"
          )
        } if cluster.name == "_ci" || cluster.name == "_dev" || try(contains(repo._namespace.environments, cluster._env.id), false)
    })
  }

  globalops_gitops_secrets = { for cluster_id, cluster in merge(local.environments_clusters, { _ci = { name = "_ci" }, _dev = { name = "_dev" } }) :
    (cluster.name) => merge(
      # Global Ops
      {
        sops = {
          name      = "sops-gpg"
          namespace = "flux-system"
          data      = { "sops.asc" = cluster_id == "_dev" ? "$${var.gpg_key_private_sops}" : "sensitive::sops_gpg_key" }
        }
        globalops_vcs_token = {
          name      = "vcs-token"
          namespace = "flux-system"
          data      = { token = cluster_id == "_dev" || cluster_id == "_ci" ? "none" : "sensitive::${local.globalops_base.name}_vcs_token" }
        }
      },
      # Namespaces
      { for ns_id, ns in local.namespaces_ops :
        "${ns.name}_sops" => {
          name      = "sops-gpg"
          namespace = ns.name
          data      = { "sops.asc" = cluster_id == "_dev" ? "$${var.gpg_key_private_sops}" : cluster_id == "_ci" ? "sensitive::sops_gpg_key" : "sensitive::${ns_id}_gpg_key" }
        } if cluster_id == "_dev" || cluster_id == "_ci" || try(contains(ns.environments, cluster._env.id), false)
      },
      # Repos
      cluster_id == "_dev" || cluster_id == "_ci" ? {} : { for repo_id, repo in local.namespaces_repos_ops :
        "${repo_id}_vcs_token" => {
          name      = "vcs-token-${replace(repo.name, "/[\\s_\\.]/", "-")}"
          namespace = "flux-system"
          data      = { token = "sensitive::${repo.name}_vcs_token" }
        } if contains(repo._namespace.environments, cluster._env.id)
      }
    )
  }

  globalops_vcs = merge(
    local.globalops_vcs_defaults,
    local.globalops_vcs_sensitive_inputs,
    {
      files        = local.globalops_vcs_defaults.branch_protection ? {} : local.globalops_vcs_files
      files_strict = local.globalops_vcs_defaults.branch_protection ? {} : local.globalops_vcs_files_strict
    }
  )
}
