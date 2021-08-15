# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalinfra = merge(
    local.globalinfra_base,
    {
      vcs     = local.globalinfra_vcs
      backend = local.globalinfra_backend
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalinfra_base = {
    name        = local.globalinfra_vcs_repo_name
    description = format(local.i18n.repo_globalinfra_description, local.organization_title)
  }

  globalinfra_vcs_base = {
    repo_exists = true
    team_config = {
      admin    = ["global_admin"]
      maintain = ["global_manager", "global_infra_lead"]
      read     = ["global"]
      write    = ["global_infra"]
    }
  }

  globalinfra_backend_base = {
    auto_apply            = false
    create                = false
    description           = local.globalinfra_base.description
    separate_environments = false
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# These variables are referenced in this file only
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Merge globalinfra base VCS configuration with user-defined base configuration
  globalinfra_vcs_defaults = merge(
    # For map types, the base map and user map are merged
    { for setting, base_value in local.vcs_config[var.vcs_default_provider] :
      setting => merge(
        base_value,
        lookup(local.globalinfra_vcs_base, setting, null)
      ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
    },
    # For all other types (inc. set), overwrite by user-defined value
    { for setting, base_value in local.vcs_config[var.vcs_default_provider] :
      setting => lookup(local.globalinfra_vcs_base, setting, null) != null ? local.globalinfra_vcs_base[setting] : base_value if !can(keys(base_value))
    }
  )

  # Filter only relevant sensitive inputs
  globalinfra_vcs_sensitive_inputs = {
    sensitive_inputs = { for secret_value in values(local.globalinfra_vcs_defaults.repo_secrets) :
      trimprefix(secret_value, "sensitive::") => sensitive(
        merge(
          local.globalinfra_vcs_defaults.sensitive_inputs,
          var.sensitive_inputs
        )[trimprefix(secret_value, "sensitive::")]) if can(regex("^sensitive::", secret_value)
      )
    }
  }

  globalinfra_vcs = merge(
    local.globalinfra_vcs_defaults,
    local.globalinfra_vcs_sensitive_inputs,
  )

  # Merge base backend configuration with user-defined base configuration
  globalinfra_backend_defaults = merge(
    # For map types, the base map and user map are merged
    { for setting, base_value in local.backend_config[var.backend_default_provider] :
      setting => merge(
        base_value,
        lookup(local.globalinfra_backend_base, setting, null)
      ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
    },
    # For all other types (inc. set), overwrite by user-defined value
    { for setting, base_value in local.backend_config[var.backend_default_provider] :
      setting => lookup(local.globalinfra_backend_base, setting, null) != null ? local.globalinfra_backend_base[setting] : base_value if !can(keys(base_value))
    }
  )

  # Filter only relevant sensitive inputs
  globalinfra_backend_sensitive_inputs = {
    sensitive_inputs = { for secret_value in setunion(values(local.globalinfra_backend_defaults.env_vars), values(local.globalinfra_backend_defaults.tf_vars), values(local.globalinfra_backend_defaults.tf_vars_hcl)) :
      trimprefix(secret_value, "sensitive::") => sensitive(
        merge(
          local.globalinfra_backend_defaults.sensitive_inputs,
          var.sensitive_inputs
        )[trimprefix(secret_value, "sensitive::")]) if can(regex("^sensitive::", secret_value)
      )
    }
  }

  globalinfra_backend = merge(
    local.globalinfra_backend_defaults,
    local.globalinfra_backend_sensitive_inputs,
  )
}
