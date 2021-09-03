# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  gitops_config = local.gitops_config_defaults
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  gitops_config_base_defaults = {
    base_dir          = "base"
    cluster_init_path = lookup(local.dev, "module_cluster_init", null)
    environments      = null
    infra_dir         = "system/bootstrap-clusters"
    namespaces        = null
    provider          = null
    system_dir        = "system"
    overlay_dir       = "overlays"
    tenant_isolation  = true
    init_cluster = {
      module_source  = "Olivr/init-cluster/flux"
      module_version = ""
    }
  }

  gitops_config_base = {
    flux = merge(local.gitops_config_base_defaults, {
      provider = "flux"
    })
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# These variables are referenced in this file only
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Merge base gitops configuration with user-defined base configuration
  gitops_config_defaults = { for provider, base_settings in local.gitops_config_base :
    provider => merge(
      # For map types, the base map and user map are merged
      { for setting, base_value in base_settings :
        setting => merge(
          base_value,
          lookup(try(var.gitops_config_base[provider], {}), setting, null)
        ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
      },
      # For all other types (inc. set), overwrite by user-defined value
      { for setting, base_value in base_settings :
        setting => lookup(try(var.gitops_config_base[provider], {}), setting, null) != null ? var.gitops_config_base[provider][setting] : base_value if !can(keys(base_value))
      }
    )
  }
}
