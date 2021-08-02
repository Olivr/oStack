# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalops_backend_create = keys(local.globalops.backends)

  globalops = merge(
    local.globalops_defaults,
    {
      backends = { for id, backend in local.globalops_backends :
        id => merge(backend, {
          tf_vars_hcl      = local.globalops_backends_tf_vars_hcl[id]
          sensitive_inputs = local.globalops_backend_sensitive_inputs[id]
        })
      }
      vcs = merge(local.globalops_defaults.vcs, {
        branch_status_checks = setunion(local.globalops_defaults_vcs.branch_status_checks, local.globalops_status_checks)
        files                = local.globalops_defaults_vcs.branch_protection ? {} : local.globalops_files
        files_strict         = local.globalops_defaults_vcs.branch_protection ? {} : local.globalops_files_strict
        deploy_keys          = local.globalops_vcs_deploy_keys
        sensitive_inputs     = local.globalops_vcs_sensitive_inputs
        repo_secrets         = local.globalops_vcs_repo_secrets
      })
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalops_defaults_base = {
    name                = "${var.prefix}${local.i18n.repo_globalops_name}"
    description         = local.i18n.repo_globalops_description
    continuous_delivery = var.continuous_delivery
  }

  globalops_defaults_vcs = merge(local.vcs_configuration[var.vcs_default_provider], {
    provider         = var.vcs_default_provider
    http_url         = format(local.vcs_provider_configuration[var.vcs_default_provider].http_format, local.globalops_defaults_base.name)
    ssh_url          = format(local.vcs_provider_configuration[var.vcs_default_provider].ssh_format, local.globalops_defaults_base.name)
    full_name        = "${local.vcs_organization_name}/${local.globalops_defaults_base.name}"
    auto_init        = true
    repo_is_template = false
    repo_template    = local.vcs_provider_configuration[var.vcs_default_provider].repo_templates.globalops
    tags = setunion(
      local.vcs_configuration[var.vcs_default_provider].tags,
      [
        local.i18n.tag_infra_proper,
        local.i18n.tag_infra_buzz,
        local.i18n.tag_ops_proper,
        local.i18n.tag_ops_buzz
      ]
    )
    team_configuration = {
      admin    = local.globalops_teams_admins
      maintain = local.globalops_teams_maintainers
      read     = local.globalops_teams_readers
      write    = local.globalops_teams_writers
    }
  })

  globalops_defaults_gitops = merge(local.gitops_configuration[var.gitops_default_provider], {
    infra_dir         = "_ostack/bootstrap-clusters"
    namespaces        = local.namespaces
    environments      = local.environments
    cluster_init_path = lookup(local.dev, "module_cluster_init", null)
  })

  globalops_defaults_backend = merge(local.backend_configuration[var.backend_default_provider], {
    name                  = local.globalops_defaults_base.name
    provider              = var.backend_default_provider
    description           = local.globalops_defaults_base.description
    vcs_working_directory = local.globalops_defaults_gitops.infra_dir
  })

  globalops_defaults = merge(local.globalops_defaults_base, {
    vcs      = local.globalops_defaults_vcs
    gitops   = local.globalops_defaults_gitops
    backends = local.globalops_backends
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Set access controls
  globalops_teams_admins      = ["global_admin"]
  globalops_teams_maintainers = ["global_manager", "global_infra_lead"]
  globalops_teams_writers     = ["global_ops", "global_infra"]
  globalops_teams_readers     = keys(local.teams) # All teams can read

  globalops_backends = local.backend_configuration[var.backend_default_provider].separate_environments ? { for id, env in local.environments :
    id => merge(local.globalops_defaults_backend, {
      _env                  = { id = id }
      name                  = "${local.globalops_defaults_base.name}-${env.name}"
      description           = "${local.globalops_defaults_base.description} (${env.name})"
      vcs_working_directory = "${local.globalops_defaults_gitops.infra_dir}/${env.name}"
      vcs_trigger_paths     = ["${local.globalops_defaults_gitops.infra_dir}/shared-modules"]
      auto_apply            = env.continuous_delivery
    })
  } : { keys(local.environments)[0] = merge(local.globalops_defaults_backend, { _env = null }) }

  globalops_status_checks = [for backend in local.globalops_backends :
    format(local.backend_provider_configuration[backend.provider].status_check_format, backend.name)
  ]

  globalops_files_prepare = merge(
    lookup(local.dev, "all_files_strict", false) ? null : local.gitops.global_files,
    lookup(local.dev, "all_files_strict", false) ? null : local.vcs_configuration[var.vcs_default_provider].files
  )

  globalops_files_formatted = { for file_path, content in local.globalops_files_prepare :
    (file_path) => try(join("\n", concat(
      compact([lookup(local.globalops_defaults_vcs.file_templates, "${trimprefix(regex("/?[^/^]+$", lower(file_path)), "/")}_header", "")]),
      content,
      compact([lookup(local.globalops_defaults_vcs.file_templates, "${trimprefix(regex("/?[^/^]+$", lower(file_path)), "/")}_footer", "")])
    )), content)
  }

  # Add template files if a local template was used
  globalops_files = merge(
    lookup(local.dev, "all_files_strict", false) ? null : lookup(local.vcs_templates_files, "globalops", null),
    local.globalops_files_formatted
  )

  globalops_files_strict_prepare = merge(
    lookup(local.dev, "all_files_strict", false) ? local.vcs_configuration[var.vcs_default_provider].files : null,
    lookup(local.dev, "all_files_strict", false) ? local.gitops.global_files : null,
    local.gitops.global_files_strict,
    local.vcs_configuration[var.vcs_default_provider].files_strict
  )

  globalops_files_strict_formatted = { for file_path, content in local.globalops_files_strict_prepare :
    (file_path) => try(join("\n", concat(
      compact([lookup(local.globalops_defaults_vcs.file_templates, "${trimprefix(regex("/?[^/^]+$", lower(file_path)), "/")}_header", "")]),
      content,
      compact([lookup(local.globalops_defaults_vcs.file_templates, "${trimprefix(regex("/?[^/^]+$", lower(file_path)), "/")}_footer", "")])
    )), content)
  }

  # Add template files if a local template was used
  globalops_files_strict = merge(
    lookup(local.dev, "all_files_strict", false) ? lookup(local.vcs_templates_files, "globalops", null) : null,
    local.globalops_files_strict_formatted
  )

  globalops_vcs_deploy_keys = merge(
    {
      _ci = {
        title    = "CI / GitHub Actions (${local.globalops_defaults_base.name})"
        ssh_key  = tls_private_key.cluster_keys["_ci"].public_key_openssh
        readonly = true
      }
    },
    { for id, cluster in local.environments_clusters_create :
      (id) => {
        title    = cluster.name
        ssh_key  = tls_private_key.cluster_keys[id].public_key_openssh
        readonly = true
      }
  })

  globalops_vcs_repo_secrets = merge(
    local.vcs_configuration[var.vcs_default_provider].repo_secrets,
    {
      ci_sensitive_inputs = "sensitive::ci_sensitive_inputs"
      ci_init_path        = "${local.globalops_defaults_gitops.infra_dir}/_local"
    }
  )

  globalops_vcs_sensitive_inputs = merge(
    local.vcs_configuration[var.vcs_default_provider].sensitive_inputs,
    {
      ci_sensitive_inputs = jsonencode({
        sensitive_inputs = local.globalops_gitops_local_sensitive_inputs
      })
  })

  globalops_gitops_local_sensitive_inputs = merge(
    { "${local.globalops_defaults_base.name}_private_key" = sensitive(tls_private_key.cluster_keys["_ci"].private_key_pem) },
    { for id, repo in local.namespaces_repos :
      "${repo.name}_private_key" => sensitive(tls_private_key.ns_keys["${id}__ci"].private_key_pem) if repo.type == "ops"
    }
  )

  globalops_gitops_local_vars_template = jsonencode({
    cluster_path = "./${values(local.environments)[0].name}/${values(values(local.environments)[0].clusters)[0].name}/${local.globalops_defaults_gitops.base_dir}"
    sensitive_inputs = merge({ for k in keys(local.globalops_gitops_local_sensitive_inputs) :
      k => ""
    })
  })

  globalops_gitops_deploy_keys = { for cluster_id, cluster in merge(local.environments_clusters_create, { _ci = { name = "_ci" } }) :
    (cluster.name) => merge(
      {
        "globalops" = {
          name        = "flux-system"
          namespace   = "flux-system"
          known_hosts = local.vcs_provider_configuration[var.vcs_default_provider].known_hosts
          public_key  = base64encode(tls_private_key.cluster_keys[cluster_id].public_key_pem)
          private_key = "sensitive::${local.globalops_defaults_base.name}_private_key"
        }
      },
      { for repo_id, repo in local.namespaces_repos :
        repo_id => {
          name        = "flux-${repo.name}"
          namespace   = repo._namespace.name
          known_hosts = local.vcs_provider_configuration[repo.vcs.provider].known_hosts
          public_key  = base64encode(tls_private_key.ns_keys["${repo_id}_${cluster_id}"].public_key_pem)
          private_key = "sensitive::${repo.name}_private_key"
        } if repo.type == "ops" && (cluster.name == "_ci" || try(contains(repo._namespace.environments, cluster._env.id), false))
    })
  }

  globalops_gitops_secrets = { for cluster_id, cluster in local.environments_clusters_create :
    (cluster.name) => merge({
      globalops_vcs_token = {
        name      = "vcs-token"
        namespace = "flux-system"
        data      = { token = "sensitive::${local.globalops_defaults_base.name}_vcs_token" }
      }
      }, { for repo_id, repo in local.namespaces_repos :
      "${repo_id}_vcs_token" => {
        name      = "vcs-token-${replace(repo.name, "/[\\s_\\.]/", "-")}"
        namespace = "flux-system"
        data      = { token = "sensitive::${repo.name}_vcs_token" }
      } if repo.type == "ops" && contains(repo._namespace.environments, cluster._env.id)
    })
  }


  globalops_backend_sensitive_inputs = { for id, backend in local.globalops_backends :
    id => merge(
      backend.sensitive_inputs,
      {
        sensitive_inputs_per_cluster = replace(jsonencode(merge([for cluster_id, cluster in local.environments_clusters_create : {
          (cluster.name) = merge({
            kube_token                                          = sensitive(local.clusters_k8s[cluster_id].kube_token)
            "${local.globalops_defaults_base.name}_private_key" = sensitive(tls_private_key.cluster_keys[cluster_id].private_key_pem)
            "${local.globalops_defaults_base.name}_vcs_token"   = sensitive(var.vcs_write_token[var.vcs_default_provider])
            }, merge([for id, repo in local.namespaces_repos :
              {
                "${repo.name}_private_key" = sensitive(tls_private_key.ns_keys["${id}_${cluster_id}"].private_key_pem)
                "${repo.name}_vcs_token"   = sensitive(var.vcs_write_token[repo.vcs.provider])
              } if repo.type == "ops" && contains(repo._namespace.environments, cluster._env.id)
            ]...)
          )
          } if !backend.separate_environments || cluster._env.id == backend._env.id
        ]...)), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
      }
  ) }

  globalops_backends_tf_vars_hcl = { for id, backend in local.globalops_backends :
    id => merge(backend.tf_vars_hcl,
      {
        sensitive_inputs_per_cluster = "sensitive::sensitive_inputs_per_cluster"
        clusters = replace(jsonencode(merge([for cluster_id, cluster in local.environments_clusters_create : {
          (cluster.name) = {
            kube_host           = local.clusters_k8s[cluster_id].kube_host
            kube_token          = "sensitive::kube_token"
            kube_ca_certificate = base64encode(local.clusters_k8s[cluster_id].kube_ca_certificate)
          }
          } if !backend.separate_environments || cluster._env.id == backend._env.id
        ]...)), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
    })
  }
}
