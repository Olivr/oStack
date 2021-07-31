# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  gitops_configuration = { for provider in keys(local.gitops_configuration_simple) :
    provider => merge(
      local.gitops_configuration_simple[provider],
      local.gitops_configuration_complex[provider]
    )
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  gitops_configuration_defaults_base = {
    base_dir         = "_ostack"
    tenant_isolation = true
    init_cluster = {
      module_source  = "Olivr/init-cluster/flux"
      module_version = ""
    }
  }

  gitops_configuration_defaults = {
    flux = local.gitops_configuration_defaults_base
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Defaults for simple types
  gitops_configuration_simple = { for provider, default_settings in local.gitops_configuration_defaults :
    provider => { for setting, default_value in default_settings :
      setting => try(var.gitops_configuration_base[provider][setting], null) != null ? var.gitops_configuration_base[provider][setting] : default_value
      if !contains(["init_cluster"], setting)
    }
  }

  # Defaults for complex types
  gitops_configuration_complex = { for provider, default_settings in local.gitops_configuration_defaults :
    provider => {
      init_cluster = merge(default_settings.init_cluster, try(var.gitops_configuration_base[provider].init_cluster, null))
    }
  }
}
