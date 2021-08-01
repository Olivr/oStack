# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  backend_organization_name = var.backend_organization_name != null && var.backend_organization_name != "" ? var.backend_organization_name : local.organization_name

  backend_configuration = { for provider in keys(local.backend_configuration_simple) :
    provider => merge(
      local.backend_configuration_simple[provider],
      local.backend_configuration_complex[provider]
    )
  }

  backend_provider_configuration = local.backend_provider_configuration_defaults
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  backend_provider_configuration_defaults_base = {
    status_check_format = "Terraform Cloud/${local.backend_organization_name}/%s"
  }

  backend_configuration_defaults_base = {
    allow_destroy_plan    = false
    auto_apply            = var.continuous_delivery
    separate_environments = true
    create                = true
    description           = null
    env_vars              = {}
    speculative_enabled   = true
    tf_vars               = {}
    tf_vars_hcl           = {}
    tfe_oauth_token_id    = null
    vcs_working_directory = ""
    vcs_trigger_paths     = []
  }

  backend_configuration_defaults = {
    tfe = local.backend_configuration_defaults_base
  }

  backend_provider_configuration_defaults = {
    tfe = local.backend_provider_configuration_defaults_base
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Defaults for simple types
  backend_configuration_simple = { for provider, default_settings in local.backend_configuration_defaults :
    provider => { for setting, default_value in default_settings :
      setting => try(var.backend_configuration_base[provider][setting], null) != null ? var.backend_configuration_base[provider][setting] : default_value
    }
  }

  # Defaults for complex types
  backend_configuration_complex = { for provider, default_settings in local.backend_configuration_simple :
    provider => {
      sensitive_inputs = merge(
        { for k, v in default_settings.env_vars : trimprefix(v, "sensitive::") => sensitive(var.sensitive_inputs[trimprefix(v, "sensitive::")]) if can(regex("^sensitive::", v)) },
        { for k, v in default_settings.tf_vars : trimprefix(v, "sensitive::") => sensitive(var.sensitive_inputs[trimprefix(v, "sensitive::")]) if can(regex("^sensitive::", v)) },
        { for k, v in default_settings.tf_vars_hcl : trimprefix(v, "sensitive::") => sensitive(var.sensitive_inputs[trimprefix(v, "sensitive::")]) if can(regex("^sensitive::", v)) },
      )
    }
  }
}
