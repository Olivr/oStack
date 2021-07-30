# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Environments
  environments = { for id in keys(var.environments) :
    id => merge(
      local.env_simple[id],
      local.env_complex[id]
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
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
locals {
  env_simple = { for id, env in var.environments :
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
  all_clusters = merge(flatten([
    for env_id, env in local.env_simple : [
      for cluster_id, cluster in env.clusters : {
        "${env_id}_${cluster_id}" = merge(cluster, { _env = env })
      }
    ]
  ])...)

  # Existing clusters
  existing_clusters = { for id, cluster in local.all_clusters :
    id => {
      create      = false
      kube_config = lookup(cluster, "kube_config", null) == null || lookup(cluster, "kube_config", "") == "" ? null : cluster.kube_config
    } if(lookup(cluster, "create", true) == false || lookup(cluster, "kube_config", null) != null && lookup(cluster, "kube_config", "") != "")
  }

  # Clusters to create: Ensure provider is specified
  environments_clusters_create_providers = { for id, cluster in local.all_clusters :
    id => merge(cluster, {
      provider = lookup(cluster, "provider", null) != null ? cluster.provider : var.cloud_default_provider
    }) if !contains(keys(local.existing_clusters), id)
  }

  # Clusters to create: Ensure simple types are specified
  environments_clusters_create_simple = { for id, cluster in local.environments_clusters_create_providers :
    id => { for setting, default_value in local.cluster_configuration[cluster.provider] :
      setting => lookup(cluster, setting, null) != null ? cluster[setting] : default_value if !contains(["nodes", "tags"], setting)
    }
  }

  # Clusters to create: Ensure complex types are specified
  environments_clusters_create_complex = { for id, cluster in local.environments_clusters_create_providers :
    id => {
      name  = lookup(cluster, "name", null) != null ? cluster.name : lower(replace(replace(replace("${var.prefix}${id}", cluster._env.id, cluster._env.name), "/[ _]/", "-"), "/[^a-zA-Z0-9-]/", ""))
      nodes = lookup(cluster, "nodes", null) != null && try(length(lookup(cluster, "nodes", {})) > 0, false) ? cluster.nodes : local.cluster_configuration[cluster.provider].nodes
      tags  = lookup(cluster, "tags", null) != null ? cluster.tags : setunion(local.cluster_configuration[cluster.provider].tags, [cluster._env.name])
    }
  }

  # All clusters per environment
  env_complex = { for env_id, env in local.env_simple :
    env_id => {
      clusters = { for cluster_id, settings in env.clusters :
        cluster_id => merge(local.existing_clusters, local.environments_clusters_create)["${env_id}_${cluster_id}"]
      }
    }
  }
}


