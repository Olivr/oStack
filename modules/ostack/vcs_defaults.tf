# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  vcs_organization_name = var.vcs_organization_name != null && var.vcs_organization_name != "" ? var.vcs_organization_name : var.organization_name

  vcs_config = { for provider in keys(local.vcs_config_defaults) :
    provider => merge(
      local.vcs_config_defaults[provider],
      local.vcs_config_sensitive_inputs[provider]
    )
  }

  vcs_provider_config = { for provider in keys(local.vcs_provider_config_defaults) :
    provider => merge(
      local.vcs_provider_config_defaults[provider],
      local.vcs_provider_config_dev_mode[provider]
    )
  }

  # If local templates are used (in dev mode), prepare the files
  vcs_templates_files = { for id, template in local.dev :
    replace(id, "/^template_/", "") => { for file_path in fileset("${path.module}/${template}", "**") :
      file_path => file("${path.module}/${template}/${file_path}")
    } if can(regex("^template_", id)) && can(regex("^\\.", template))
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Base VCS provider configuration for all providers
  vcs_provider_config_base_defaults = {
    known_hosts  = "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
    ssh_format   = "ssh://git@github.com/${local.vcs_organization_name}/%s.git"
    http_format  = "https://github.com/${local.vcs_organization_name}/%s"
    workflow_dir = ".github/workflows"
    repo_templates = {
      globalconfig = null
      globalops    = "Olivr/ostack-global-ops-github"
      apps         = "Olivr/ostack-ns-apps-github"
      infra        = "Olivr/ostack-ns-infra-github"
      ops          = "Olivr/ostack-ns-ops-github"
    }
  }

  # Base VCS configuration for all providers
  vcs_config_base_defaults = {
    branch_default_name              = "main"
    branch_delete_on_merge           = true
    branch_protection                = true
    branch_protection_enforce_admins = true
    branch_review_count              = 0
    branch_status_checks             = ["Passed all CI tests"]
    create                           = true
    deploy_keys                      = {}
    files                            = {}
    files_strict                     = {}
    provider                         = null
    repo_allow_merge_commit          = false
    repo_allow_rebase_merge          = true
    repo_allow_squash_merge          = true
    repo_archive_on_destroy          = true
    repo_auto_init                   = true
    repo_enable_issues               = true
    repo_enable_projects             = true
    repo_enable_wikis                = true
    repo_exists                      = false
    repo_full_name                   = null
    repo_homepage_url                = null
    repo_http_url                    = null
    repo_is_template                 = false
    repo_issue_labels                = {}
    repo_private                     = true
    repo_ssh_url                     = null
    repo_template                    = null
    repo_vulnerability_alerts        = true
    sensitive_inputs                 = {}
    tags                             = setunion(var.tags, [var.organization_name])
    team_config = {
      admin    = []
      maintain = []
      read     = []
      write    = []
    }
    repo_secrets = {
      vcs_write_token = "sensitive::vcs_write_token"
    }
    file_templates = {
      codeowners_header    = <<-EOT
      ##
      # ${local.i18n.file_template_header_1}
      # ${local.i18n.file_template_header_2}
      ##
      EOT
      "ostack.yaml_header" = "# This configuration file can be used by tools that work with oStack"
    }
  }

  # Base VCS provider configuration including provider-specific configuration
  vcs_provider_config_base = {
    github = local.vcs_provider_config_base_defaults
  }

  # Base VCS configuration including provider-specific configuration
  vcs_config_base = {
    github = merge(local.vcs_config_base_defaults, {
      provider = "github"
    })
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# These variables are referenced in this file only
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Merge base VCS configuration with user-defined base configuration
  vcs_config_defaults = { for provider, base_settings in local.vcs_config_base :
    provider => merge(
      # For map types, the base map and user map are merged
      { for setting, base_value in base_settings :
        setting => merge(
          base_value,
          lookup(try(var.vcs_config_base[provider], {}), setting, null)
        ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
      },
      # For all other types (inc. set), overwrite by user-defined value
      { for setting, base_value in base_settings :
        setting => lookup(try(var.vcs_config_base[provider], {}), setting, null) != null ? var.vcs_config_base[provider][setting] : base_value if !can(keys(base_value))
      }
    )
  }

  # Filter only relevant sensitive inputs
  vcs_config_sensitive_inputs = { for provider, default_settings in local.vcs_config_defaults :
    provider => {
      sensitive_inputs = { for secret_value in values(default_settings.repo_secrets) :
        trimprefix(secret_value, "sensitive::") => sensitive(
          merge(
            default_settings.sensitive_inputs,
            var.sensitive_inputs,
            {
              vcs_write_token = try(var.vcs_write_token[provider], null)
            }
          )[trimprefix(secret_value, "sensitive::")]) if can(regex("^sensitive::", secret_value)
        )
      }
    }
  }

  # Merge base VCS provider configuration with user-defined base configuration
  vcs_provider_config_defaults = { for provider, base_settings in local.vcs_provider_config_base :
    provider => merge(
      # For map types, the base map and user map are merged
      { for setting, base_value in base_settings :
        setting => merge(
          base_value,
          lookup(try(var.vcs_config_base[provider], {}), setting, null)
        ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
      },
      # For all other types (inc. set), overwrite by user-defined value
      { for setting, base_value in base_settings :
        setting => lookup(try(var.vcs_config_base[provider], {}), setting, null) != null ? var.vcs_config_base[provider][setting] : base_value if !can(keys(base_value))
      }
    )
  }

  # If the template is a local path (starts with .), set the repo_template to null (ie. do not use a template)
  # The files will be added directly from local.vcs_templates_files
  vcs_provider_config_dev_mode = { for provider, default_settings in local.vcs_provider_config_defaults :
    provider => {
      repo_templates = merge(default_settings.repo_templates, { for id, template in local.dev :
        replace(id, "/^template_/", "") => can(regex("^\\.", template)) ? "Olivr/ostack-dev" : template if can(regex("^template_", id))
      })
    }
  }
}
