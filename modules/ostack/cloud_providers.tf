# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  cloud_clusters_k8s = merge(
    module.cloud_clusters_k8s_linode,
    module.cloud_clusters_k8s_digitalocean,
    { for id, cluster in local.environments_clusters_existing :
      id => cluster if cluster.bootstrap
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Multi-providers
# ---------------------------------------------------------------------------------------------------------------------
locals {
  cloud_clusters_k8s_linode = { for id, cluster in local.environments_clusters_create :
    id => cluster if cluster.provider == "linode"
  }

  cloud_clusters_k8s_digitalocean = { for id, cluster in local.environments_clusters_create :
    id => cluster if cluster.provider == "digitalocean"
  }
}
