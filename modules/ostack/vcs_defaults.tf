# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  vcs_organization_name = var.vcs_organization_name != null && var.vcs_organization_name != "" ? var.vcs_organization_name : local.organization_name

  vcs_configuration = { for provider in keys(local.vcs_configuration_defaults) :
    provider => merge(
      local.vcs_configuration_simple[provider],
      local.vcs_configuration_complex[provider]
    )
  }

  vcs_provider_configuration = local.vcs_provider_configuration_templates
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  vcs_provider_configuration_defaults_base = {
    known_hosts  = "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
    ssh_format   = "ssh://git@github.com/${local.vcs_organization_name}/%s.git"
    http_format  = "https://github.com/${local.vcs_organization_name}/%s"
    workflow_dir = ".github/workflows"
    repo_templates = {
      globalconfig = null
      globalops    = "Olivr/ostack-global-ops"
      apps         = "Olivr/ostack-ns-apps"
      infra        = "Olivr/ostack-ns-infra"
      ops          = "Olivr/ostack-ns-ops"
    }
  }

  vcs_configuration_defaults_base = {
    create                           = true
    branch_default_name              = "main"
    branch_delete_on_merge           = true
    branch_protection                = true
    branch_protection_enforce_admins = true
    branch_review_count              = 0
    branch_status_checks             = ["Passed all CI tests"]
    deploy_keys                      = {}
    files                            = {}
    files_strict                     = {}
    repo_allow_merge_commit          = false
    repo_allow_rebase_merge          = true
    repo_allow_squash_merge          = true
    repo_archive_on_destroy          = true
    repo_auto_init                   = true
    repo_enable_issues               = true
    repo_enable_projects             = true
    repo_enable_wikis                = true
    repo_homepage_url                = null
    repo_is_template                 = false
    repo_issue_labels                = {}
    repo_private                     = true
    repo_template                    = null
    repo_vulnerability_alerts        = true
    sensitive_inputs                 = {}
    tags                             = setunion(var.tags, [local.organization_name])
    repo_secrets = {
      vcs_write_token = "sensitive::vcs_write_token"
    }
    file_templates = {
      codeowners_header = <<-EOT
      ##
      # ${local.i18n.file_template_header_1}
      # ${local.i18n.file_template_header_2}
      ##
      EOT
      codeowners_footer = ""
    }
  }

  vcs_configuration_defaults = {
    github = merge(local.vcs_configuration_defaults_base, {
      sensitive_inputs = {
        vcs_write_token = try(sensitive(var.vcs_write_token.github), null)
      }
    })
  }

  vcs_provider_configuration_defaults = {
    github = local.vcs_provider_configuration_defaults_base
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Defaults for simple types
  vcs_configuration_simple = { for provider, default_settings in local.vcs_configuration_defaults :
    provider => { for setting, default_value in default_settings :
      setting => try(var.vcs_configuration_base[provider][setting], null) != null ? var.vcs_configuration_base[provider][setting] : default_value
      if !contains(["file_templates"], setting)
    }
  }

  # Defaults for complex types
  vcs_configuration_complex = { for provider, default_settings in local.vcs_configuration_defaults :
    provider => {
      file_templates = merge(default_settings.file_templates, try(var.vcs_configuration_base[provider].file_templates, null))
    }
  }

  # Defaults for templates
  vcs_provider_configuration_templates = { for provider, default_settings in local.vcs_provider_configuration_defaults :
    provider => merge(default_settings, {
      repo_templates = merge(
        { for id, template in default_settings.repo_templates :
          id => try(var.vcs_configuration_base[provider].repo_templates[id], null) == null ? template : (
            var.vcs_configuration_base[provider].repo_templates[id] == "" ? null : var.vcs_configuration_base[provider].repo_templates[id]
          )
        },
        # if dev_mode is used, force templates
        { for id, template in local.dev :
          replace(id, "/^template_/", "") => can(regex("^\\.", template)) ? null : template if can(regex("^template_", id))
        }
      )
    })
  }

  # If local templates are used (in dev mode), prepare the files
  vcs_templates_files = { for id, template in local.dev :
    replace(id, "/^template_/", "") => { for file_path in fileset("${path.module}/${template}", "**") :
      file_path => file("${path.module}/${template}/${file_path}")
    } if can(regex("^template_", id)) && can(regex("^\\.", template))
  }
}
