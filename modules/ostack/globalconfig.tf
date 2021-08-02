# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalconfig = { for provider in local.globalconfig_providers :
    provider => merge(
      local.globalconfig_defaults,
      {
        vcs = merge(local.globalconfig_defaults_vcs, {
          files_strict = local.globalconfig_files_strict[provider]
          files        = local.globalconfig_files[provider]
        })
      }
    )
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalconfig_defaults = {
    name        = "${var.prefix}${local.i18n.repo_globalconfig_name}"
    description = local.i18n.repo_globalconfig_description
  }

  globalconfig_defaults_vcs = merge(local.vcs_configuration[var.vcs_default_provider], {
    auto_init            = true
    branch_protection    = false
    branch_review_count  = 0
    branch_status_checks = []
    repo_template        = local.vcs_provider_configuration[var.vcs_default_provider].repo_templates.globalconfig
    team_configuration = {
      admin    = local.globalconfig_teams_admins
      maintain = []
      read     = local.globalconfig_teams_readers
      write    = local.globalconfig_teams_writers
    }
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Set access controls
  globalconfig_teams_admins  = ["global_admin"]
  globalconfig_teams_writers = ["global_infra", "global_manager"] # Write access needed to trigger manual syncs
  globalconfig_teams_readers = ["global"]

  # Detect which VCS providers need a configuration repo
  globalconfig_providers = distinct(compact(flatten([
    local.globalops.vcs.branch_protection ? local.globalops.vcs.provider : null,
    [for repo in values(local.namespaces_repos) :
      repo.vcs.provider if repo.vcs.branch_protection
    ]
  ])))

  # Add sync workflow for each repo
  globalconfig_files_strict_workflows = { for provider in local.globalconfig_providers :
    provider => { for k, v in merge({
      "${local.vcs_provider_configuration[provider].workflow_dir}/sync-${local.globalops.name}.yaml" = local.globalops.vcs.provider == provider && local.globalops.vcs.branch_protection ? templatefile("${path.module}/templates/${provider}/sync.yaml.tpl", {
        config_branch = local.globalconfig_defaults_vcs.branch_default_name
        repo_branch   = local.globalops.vcs.branch_default_name
        repo_name     = local.globalops.name
        automerge     = local.globalops.continuous_delivery
      }) : null,
      },
      merge([for id, repo in local.namespaces_repos :
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
    (local.globalops.vcs.provider) = (
      local.globalops.vcs.branch_protection
      ? { for file_path, content in local.globalops_files_strict :
        "${local.globalops.name}/${file_path}" => content
      } : {}
    )
  }

  # Namespace repos files to add to the configuration repo
  globalconfig_files_strict_namespaces = { for provider in local.globalconfig_providers :
    provider => merge([for id, repo in local.namespaces_repos :
      { for file_path, content in lookup(local.namespaces_repos_files_strict, id, {}) :
        "${repo.name}/${file_path}" => content
      } if repo.vcs.provider == provider && repo.vcs.branch_protection
    ]...)
  }

  # Global ops repo files to add to the configuration repo
  globalconfig_files_globalops = {
    (local.globalops.vcs.provider) = (
      local.globalops.vcs.branch_protection
      ? { for file_path, content in local.globalops_files :
        "${local.globalops.name}/${file_path}" => content
      } : {}
    )
  }

  # Namespace repos files to add to the configuration repo
  globalconfig_files_namespaces = { for provider in local.globalconfig_providers :
    provider => merge([for id, repo in local.namespaces_repos :
      { for file_path, content in lookup(local.namespaces_repos_files, id, {}) :
        "${repo.name}/${file_path}" => content
      } if repo.vcs.provider == provider && repo.vcs.branch_protection
    ]...)
  }

  # Strict files to add to the configuration repo per VCS provider
  globalconfig_files_strict = { for provider in local.globalconfig_providers :
    provider => merge(
      lookup(local.vcs_templates_files, "globalconfig", null), # Add template files if a local template was used
      lookup(local.globalconfig_files_strict_workflows, provider, null),
      lookup(local.globalconfig_files_strict_globalops, provider, null),
      lookup(local.globalconfig_files_strict_namespaces, provider, null),
      lookup(local.dev, "all_files_strict", false) ? lookup(local.globalconfig_files_globalops, provider, null) : null,
      lookup(local.dev, "all_files_strict", false) ? lookup(local.globalconfig_files_namespaces, provider, null) : null
    )
  }
  # Files to add to the configuration repo per VCS provider
  globalconfig_files = { for provider in local.globalconfig_providers :
    provider => merge(
      lookup(local.dev, "all_files_strict", false) ? null : lookup(local.globalconfig_files_globalops, provider, null),
      lookup(local.dev, "all_files_strict", false) ? null : lookup(local.globalconfig_files_namespaces, provider, null)
    )
  }
}
