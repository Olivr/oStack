# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Environments
  environments = { for id in keys(var.environments) :
    id => merge(
      local.environments_simple[id],
      local.environments_complex[id]
    )
  }
  # Clusters to create
  environments_clusters_create = { for id in keys(local.environments_clusters_create_providers) :
    id => merge(
      local.environments_clusters_create_providers[id],
      local.environments_clusters_create_simple[id],
      local.environments_clusters_create_complex[id]
    )
  }

  environments_clusters = merge(
    local.environments_clusters_create,
    local.environments_clusters_existing
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  environments_simple = { for id, env in var.environments :
    id => {
      id                  = id
      name                = lookup(env, "name", null) != null && lookup(env, "name", "") != "" ? env.name : lower(trim(replace(replace(id, "/[\\s_\\.]/", "-"), "/[^a-zA-Z0-9-]/", ""), "-"))
      promotion_order     = lookup(env, "promotion_order", null)
      continuous_delivery = lookup(env, "continuous_delivery", null) != null ? env.continuous_delivery : var.continuous_delivery
      clusters            = try(length(env.clusters) > 0 ? env.clusters : tomap(false), {})
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Prepare clusters
  environments_clusters_prepare = merge(flatten([
    for env_id, env in local.environments_simple : [
      for cluster_id, cluster in env.clusters : {
        "${env_id}_${cluster_id}" = merge(cluster, {
          _env = env
          name = lookup(cluster, "name", null) != null ? cluster.name : lower(replace(replace("${var.prefix}${env.name}_${cluster_id}", "/[ _]/", "-"), "/[^a-zA-Z0-9-]/", ""))
        })
      }
    ]
  ])...)

  # Existing clusters
  environments_clusters_existing = { for id, cluster in local.environments_clusters_prepare :
    id => merge(cluster, {
      create    = false
      bootstrap = lookup(cluster, "kube_config", null) != null
      kube_ca_certificate = try(
        can(regex("^sensitive::", cluster.kube_config.ca_certificate) ? (
          sensitive(var.sensitive_inputs[trimprefix(cluster.kube_config.ca_certificate, "sensitive::")])
        ) : cluster.kube_config.ca_certificate),
      "")

      kube_host = try(
        can(regex("^sensitive::", cluster.kube_config.host) ? (
          sensitive(var.sensitive_inputs[trimprefix(cluster.kube_config.host, "sensitive::")])
        ) : cluster.kube_config.host),
      "")

      kube_token = try(
        can(regex("^sensitive::", cluster.kube_config.token) ? (
          sensitive(var.sensitive_inputs[trimprefix(cluster.kube_config.token, "sensitive::")])
        ) : cluster.kube_config.token),
      "")
    }) if lookup(cluster, "create", true) == false || lookup(cluster, "kube_config", null) != null
  }

  # Clusters to create: Ensure provider is specified
  environments_clusters_create_providers = { for id, cluster in local.environments_clusters_prepare :
    id => merge(cluster, {
      provider = lookup(cluster, "provider", null) != null ? cluster.provider : var.cloud_default_provider
    }) if !contains(keys(local.environments_clusters_existing), id)
  }

  # Clusters to create: Ensure simple types are specified
  environments_clusters_create_simple = { for id, cluster in local.environments_clusters_create_providers :
    id => merge(cluster, { for setting, default_value in local.cluster_configuration[cluster.provider] :
      setting => lookup(cluster, setting, null) != null ? cluster[setting] : default_value if !contains(["nodes", "tags"], setting)
    })
  }

  # Clusters to create: Ensure complex types are specified
  environments_clusters_create_complex = { for id, cluster in local.environments_clusters_create_providers :
    id => {
      nodes = lookup(cluster, "nodes", null) != null && try(length(lookup(cluster, "nodes", {})) > 0, false) ? cluster.nodes : local.cluster_configuration[cluster.provider].nodes
      tags  = lookup(cluster, "tags", null) != null ? cluster.tags : setunion(local.cluster_configuration[cluster.provider].tags, [cluster._env.name])
    }
  }

  # All clusters per environment
  environments_complex = { for env_id, env in local.environments_simple :
    env_id => {
      clusters = { for cluster_id, settings in env.clusters :
        cluster_id => merge(local.environments_clusters_existing, local.environments_clusters_create)["${env_id}_${cluster_id}"]
      }
    }
  }
}


