# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalconfig = { for provider in local.globalconfig_vcs_providers :
    provider => merge(
      local.globalconfig_base,
      {
        vcs = local.globalconfig_vcs[provider]
      }
    )
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalconfig_base = {
    name        = "${var.prefix}${local.i18n.repo_globalconfig_name}"
    description = local.i18n.repo_globalconfig_description
  }

  globalconfig_vcs_base = {
    auto_init            = true
    branch_protection    = false
    branch_review_count  = 0
    branch_status_checks = []
    repo_template        = local.vcs_provider_config[var.vcs_default_provider].repo_templates.globalconfig
    team_config = {
      admin    = ["global_admin"]
      maintain = []
      read     = ["global"]
      write    = ["global_infra", "global_manager"] # Write access is needed to trigger manual syncs
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# These variables are referenced in this file only
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Detect which VCS providers need a configuration repo
  globalconfig_vcs_providers = distinct(compact(flatten([
    local.globalops.vcs.branch_protection ? local.globalops.vcs.provider : null,
    [for repo in values(local.namespaces_repos) :
      repo.vcs.provider if repo.vcs.branch_protection
    ]
  ])))

  # Merge globalconfig base VCS configuration with user-defined base configuration
  globalconfig_vcs_defaults = { for provider in local.globalconfig_vcs_providers :
    provider => merge(
      # For map types, the base map and user map are merged
      { for setting, base_value in local.vcs_config[provider] :
        setting => merge(
          base_value,
          lookup(local.globalconfig_vcs_base, setting, null)
        ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
      },
      # For all other types (inc. set), overwrite by user-defined value
      { for setting, base_value in local.backend_config[var.backend_default_provider] :
        setting => lookup(local.globalconfig_vcs_base, setting, null) != null ? local.globalconfig_vcs_base[setting] : base_value if !can(keys(base_value))
      }
    )
  }

  # Filter only relevant sensitive inputs
  globalconfig_vcs_sensitive_inputs = { for provider in local.globalconfig_vcs_providers :
    provider => {
      sensitive_inputs = { for secret_value in values(local.vcs_config[provider].repo_secrets) :
        trimprefix(secret_value, "sensitive::") => sensitive(
          merge(
            local.vcs_config[provider].sensitive_inputs,
            var.sensitive_inputs
          )[trimprefix(secret_value, "sensitive::")]) if can(regex("^sensitive::", secret_value)
        )
      }
    }
  }

  # Add sync workflow for each repo
  globalconfig_vcs_files_strict_workflows = { for provider in local.globalconfig_vcs_providers :
    provider => { for k, v in merge({
      "${local.vcs_provider_config[provider].workflow_dir}/sync-${local.globalops.name}.yaml" = local.globalops.vcs.provider == provider && local.globalops.vcs.branch_protection ? templatefile("${path.module}/templates/${provider}/sync.yaml.tpl", {
        config_branch = local.globalconfig_vcs_defaults[provider].branch_default_name
        repo_branch   = local.globalops.vcs.branch_default_name
        repo_name     = local.globalops.name
        automerge     = local.globalops.continuous_delivery
      }) : null,
      },
      merge([for id, repo in local.namespaces_repos :
        {
          "${local.vcs_provider_config[provider].workflow_dir}/sync-${repo.name}.yaml" = templatefile("${path.module}/templates/${provider}/sync.yaml.tpl", {
            config_branch = local.globalconfig_vcs_defaults[provider].branch_default_name
            repo_branch   = repo.vcs.branch_default_name
            repo_name     = repo.name
            automerge     = repo.continuous_delivery
          })
        } if repo.vcs.provider == provider && repo.vcs.branch_protection
      ]...)
    ) : k => v if v != null }
  }

  # Global ops repo files to add to the configuration repo
  globalconfig_vcs_files_strict_globalops = {
    (local.globalops.vcs.provider) = (
      local.globalops.vcs.branch_protection
      ? { for file_path, content in local.globalops_vcs_files_strict :
        "${local.globalops.name}/${file_path}" => content
      } : {}
    )
  }

  # Namespace repos files to add to the configuration repo
  globalconfig_vcs_files_strict_namespaces = { for provider in local.globalconfig_vcs_providers :
    provider => merge([for id, repo in local.namespaces_repos :
      { for file_path, content in lookup(local.namespaces_repos_files_strict, id, {}) :
        "${repo.name}/${file_path}" => content
      } if repo.vcs.provider == provider && repo.vcs.branch_protection
    ]...)
  }

  # Global ops repo files to add to the configuration repo
  globalconfig_vcs_files_globalops = {
    (local.globalops.vcs.provider) = (
      local.globalops.vcs.branch_protection
      ? { for file_path, content in local.globalops_vcs_files :
        "${local.globalops.name}/${file_path}" => content
      } : {}
    )
  }

  # Namespace repos files to add to the configuration repo
  globalconfig_vcs_files_namespaces = { for provider in local.globalconfig_vcs_providers :
    provider => merge([for id, repo in local.namespaces_repos :
      { for file_path, content in lookup(local.namespaces_repos_files, id, {}) :
        "${repo.name}/${file_path}" => content
      } if repo.vcs.provider == provider && repo.vcs.branch_protection
    ]...)
  }

  # Files to add to the configuration repo per VCS provider
  globalconfig_vcs_files = { for provider in local.globalconfig_vcs_providers :
    provider => {
      files = merge(
        lookup(local.dev, "all_files_strict", false) ? null : lookup(local.globalconfig_vcs_files_globalops, provider, null),
        lookup(local.dev, "all_files_strict", false) ? null : lookup(local.globalconfig_vcs_files_namespaces, provider, null)
      )
      files_strict = merge(
        lookup(local.vcs_templates_files, "globalconfig", null), # Add template files if a local template was used
        lookup(local.globalconfig_vcs_files_strict_workflows, provider, null),
        lookup(local.globalconfig_vcs_files_strict_globalops, provider, null),
        lookup(local.globalconfig_vcs_files_strict_namespaces, provider, null),
        lookup(local.dev, "all_files_strict", false) ? lookup(local.globalconfig_vcs_files_globalops, provider, null) : null,
        lookup(local.dev, "all_files_strict", false) ? lookup(local.globalconfig_vcs_files_namespaces, provider, null) : null
      )
    }
  }

  globalconfig_vcs = { for provider in local.globalconfig_vcs_providers :
    provider => merge(
      local.globalconfig_vcs_defaults[provider],
      local.globalconfig_vcs_sensitive_inputs[provider],
      local.globalconfig_vcs_files[provider],
    )
  }
}
