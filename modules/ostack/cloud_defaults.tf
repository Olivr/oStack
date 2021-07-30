# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  cluster_configuration = { for provider in keys(local.cluster_configuration_simple) :
    provider => merge(
      local.cluster_configuration_simple[provider],
      local.cluster_configuration_complex[provider]
    )
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  cluster_configuration_defaults_base = {
    autoscale    = false
    create       = true
    kube_version = "1.21"
    kube_config  = null
    nodes        = { "g6-standard-1" = 2 }
    region       = "us-central"
    tags         = setunion(var.tags, [local.organization_name])
  }

  cluster_configuration_defaults = {
    linode = local.cluster_configuration_defaults_base

    digitalocean = merge(local.cluster_configuration_defaults_base, {
      autoscale = true
      nodes     = { "s-1vcpu-2gb" = 2 }
      region    = "nyc1"
    })
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Ensure simple types are specified
  cluster_configuration_simple = { for provider, default_settings in local.cluster_configuration_defaults :
    provider => { for setting, default_value in default_settings :
      setting => try(var.cluster_configuration_base[provider][setting], null) != null ? var.cluster_configuration_base[provider][setting] : default_value
      if !contains(["nodes"], setting)
    }
  }

  # Ensure complex types are specified
  cluster_configuration_complex = { for provider, default_settings in local.cluster_configuration_defaults :
    provider => {
      nodes = try(length(var.cluster_configuration_base[provider].nodes), 0) > 0 ? var.cluster_configuration_base[provider].nodes : default_settings.nodes
    }
  }
}
