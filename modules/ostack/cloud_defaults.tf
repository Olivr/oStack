# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  cloud_cluster_config = { for provider in keys(local.cloud_cluster_config_defaults) :
    provider => merge(
      local.cloud_cluster_config_defaults[provider],
      local.cloud_cluster_config_nodes[provider]
    )
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  cloud_cluster_config_base_defaults = {
    autoscale    = true
    create       = true
    bootstrap    = true
    kube_version = "1.21"
    kube_config  = null
    nodes        = { "g6-standard-1" = 2 }
    provider     = null
    region       = "us-central"
    tags         = setunion(var.tags, [var.organization_name])
  }

  cloud_cluster_config_base = {
    linode = merge(local.cloud_cluster_config_base_defaults, {
      provider = "linode"
    })

    digitalocean = merge(local.cloud_cluster_config_base_defaults, {
      nodes    = { "s-1vcpu-2gb" = 2 }
      provider = "digitalocean"
      region   = "nyc1"
    })
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# These variables are referenced in this file only
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Merge base backend configuration with user-defined base configuration
  cloud_cluster_config_defaults = { for provider, base_settings in local.cloud_cluster_config_base :
    provider => merge(
      # For map types, the base map and user map are merged
      { for setting, base_value in base_settings :
        setting => merge(
          base_value,
          lookup(try(var.cloud_cluster_config_base[provider], {}), setting, null)
        ) if can(keys(base_value)) # can(keys(base_value)) returns true if base_value is a map
      },
      # For all other types (inc. set), overwrite by user-defined value
      { for setting, base_value in base_settings :
        setting => lookup(try(var.cloud_cluster_config_base[provider], {}), setting, null) != null ? var.cloud_cluster_config_base[provider][setting] : base_value if !can(keys(base_value))
      }
    )
  }

  # Ensure complex types are specified
  cloud_cluster_config_nodes = { for provider, default_settings in local.cloud_cluster_config_base :
    provider => {
      nodes = try(length(var.cloud_cluster_config_base[provider].nodes), 0) > 0 ? var.cloud_cluster_config_base[provider].nodes : default_settings.nodes
    }
  }
}
