# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Static
  globalconfig_static = { for provider in local.global_config_providers :
    provider => merge(
      local.globalconfig_defaults,
      {
        vcs = local.globalconfig_defaults_vcs
      }
    )
  }

  # Dynamic
  globalconfig_dynamic = { for provider in local.global_config_providers :
    provider => {
      vcs = {
        files_strict = local.globalconfig_files_strict[provider]
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Static defaults
# These are computable statically (without any resource created or any external data fetched)
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalconfig_defaults = {
    name        = "${var.prefix}${local.i18n.repo_global_config_name}"
    description = local.i18n.repo_global_config_description
  }

  globalconfig_defaults_vcs = merge(local.vcs_configuration[var.vcs_default_provider], {
    auto_init            = true
    branch_protection    = false
    branch_review_count  = 0
    branch_status_checks = []
    repo_secrets         = merge(local.vcs_configuration[var.vcs_default_provider].repo_secrets, { VCS_WRITE_TOKEN = "sensitive::vcs_token_write" })
    sensitive_inputs     = merge(local.vcs_configuration[var.vcs_default_provider].sensitive_inputs, { vcs_token_write = sensitive(var.vcs_token_write[var.vcs_default_provider]) })
    repo_template        = local.vcs_provider_configuration[var.vcs_default_provider].repo_templates.global_config
    team_configuration = {
      admin    = ["global_admin"]
      maintain = []
      read     = keys(merge(values(local.namespace_teams).*.teams...))
      write    = keys(local.global_teams.global.teams)
    }
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# Static computations
# These are computable statically (without any resource created or any external data fetched)
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Detect which VCS providers need a configuration repo
  global_config_providers = distinct(compact(flatten([
    local.globalops_static.vcs.branch_protection ? local.globalops_static.vcs.provider : null,
    [for repo in values(local.namespaces_repos_static) :
      repo.vcs.provider if repo.vcs.branch_protection
    ]
  ])))
}

# ---------------------------------------------------------------------------------------------------------------------
# Dynamic computations
# These may require an output from a data/resource/module
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Add sync workflow for each repo
  globalconfig_files_workflows = { for provider in local.global_config_providers :
    provider => { for k, v in merge({
      "${local.vcs_provider_configuration[provider].workflow_dir}/sync-${local.globalops_static.name}.yaml" = local.globalops_static.vcs.provider == provider && local.globalops_static.vcs.branch_protection ? templatefile("${path.module}/templates/${provider}/sync.yaml.tpl", {
        config_branch = local.globalconfig_defaults_vcs.branch_default_name
        repo_branch   = local.globalops_static.vcs.branch_default_name
        repo_name     = local.globalops_static.name
        automerge     = local.globalops_static.continuous_delivery
      }) : null,
      },
      merge([for id, repo in local.namespaces_repos_static :
        {
          "${local.vcs_provider_configuration[provider].workflow_dir}/sync-${repo.name}.yaml" = templatefile("${path.module}/templates/${provider}/sync.yaml.tpl", {
            config_branch = local.globalconfig_defaults_vcs.branch_default_name
            repo_branch   = repo.vcs.branch_default_name
            repo_name     = repo.name
            automerge     = repo.continuous_delivery
          })
        } if repo.vcs.provider == provider && repo.vcs.branch_protection
      ]...)
    ) : k => v if v != null }
  }

  # Global ops repo files to add to the configuration repo
  globalconfig_files_strict_globalops = {
    (local.globalops_static.vcs.provider) = (
      local.globalops_static.vcs.branch_protection
      ? { for path, content in merge(local.globalops_files, local.globalops_files_strict) :
        "${local.globalops_static.name}/${path}" => content
      } : {}
    )
  }

  # Namespace repos files to add to the configuration repo
  globalconfig_files_strict_namespaces = { for provider in local.global_config_providers :
    provider => merge([for id, repo in local.namespaces_repos_static :
      { for path, content in lookup(merge(local.namespaces_repos_files, local.namespaces_repos_files_strict), id, {}) :
        "${repo.name}/${path}" => content
      } if repo.vcs.provider == provider && repo.vcs.branch_protection
    ]...)
  }

  # Files to add to the configuration repo per VCS provider
  globalconfig_files_strict = { for provider in local.global_config_providers :
    provider => merge(
      lookup(local.vcs_templates_files, "global_config", null), # Add template files if a local template was used
      lookup(local.globalconfig_files_workflows, provider, null),
      lookup(local.globalconfig_files_strict_globalops, provider, null),
      lookup(local.globalconfig_files_strict_namespaces, provider, null)
    )
  }
}
