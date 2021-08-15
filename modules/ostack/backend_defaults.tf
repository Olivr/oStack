# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  backend_organization_name = var.backend_organization_name != null && var.backend_organization_name != "" ? var.backend_organization_name : var.organization_name

  backend_config = { for provider in keys(local.backend_config_defaults) :
    provider => merge(
      local.backend_config_defaults[provider],
      local.backend_config_sensitive_inputs[provider]
    )
  }

  backend_provider_config = local.backend_provider_config_defaults
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Base backend provider configuration for all providers
  backend_provider_config_base_defaults = {
    status_check_format = "Terraform Cloud/${local.backend_organization_name}/%s"
  }

  # Base backend configuration for all providers
  backend_config_base_defaults = {
    allow_destroy_plan    = false
    auto_apply            = var.continuous_delivery
    create                = true
    description           = null
    env_vars              = {}
    name                  = null
    provider              = null
    sensitive_inputs      = {}
    separate_environments = true
    speculative_enabled   = true
    tf_vars               = {}
    tf_vars_hcl           = {}
    tfe_oauth_token_id    = null
    vcs_trigger_paths     = []
    vcs_working_directory = ""
    workspace_triggers    = toset(compact([local.globalinfra_backend_workspace_name]))
  }

  # Base backend provider configuration including provider-specific configuration
  backend_config_base = {
    tfe = merge(local.backend_config_base_defaults, {
      provider = "tfe"
    })
  }

  # Base backend configuration including provider-specific configuration
  backend_provider_config_base = {
    tfe = local.backend_provider_config_base_defaults
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# These variables are referenced in this file only
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Merge base backend configuration with user-defined base configuration
  backend_config_defaults = { for provider, base_settings in local.backend_config_base :
    provider => merge(
      # For map types, the base map and user map are merged
      { for setting, base_value in base_settings :
        setting => merge(
          base_value,
          lookup(try(var.backend_config_base[provider], {}), setting, null)
        ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
      },
      # For all other types (inc. set), overwrite by user-defined value
      { for setting, base_value in base_settings :
        setting => lookup(try(var.backend_config_base[provider], {}), setting, null) != null ? var.backend_config_base[provider][setting] : base_value if !can(keys(base_value))
      }
    )
  }

  # Filter only relevant sensitive inputs
  backend_config_sensitive_inputs = { for provider, default_settings in local.backend_config_defaults :
    provider => {
      sensitive_inputs = { for secret_value in setunion(values(default_settings.env_vars), values(default_settings.tf_vars), values(default_settings.tf_vars_hcl)) :
        trimprefix(secret_value, "sensitive::") => sensitive(
          merge(
            default_settings.sensitive_inputs,
            var.sensitive_inputs
          )[trimprefix(secret_value, "sensitive::")]) if can(regex("^sensitive::", secret_value)
        )
      }
    }
  }

  # Merge base backend provider configuration with user-defined base configuration
  backend_provider_config_defaults = { for provider, base_settings in local.backend_provider_config_base :
    provider => merge(
      # For map types, the base map and user map are merged
      { for setting, base_value in base_settings :
        setting => merge(
          base_value,
          lookup(try(var.backend_config_base[provider], {}), setting, null)
        ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
      },
      # For all other types (inc. set), overwrite by user-defined value
      { for setting, base_value in base_settings :
        setting => lookup(try(var.backend_config_base[provider], {}), setting, null) != null ? var.backend_config_base[provider][setting] : base_value if !can(keys(base_value))
      }
    )
  }
}
