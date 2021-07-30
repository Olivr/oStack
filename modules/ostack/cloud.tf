# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  clusters_k8s = merge(
    module.clusters_k8s_linode,
    module.clusters_k8s_digitalocean
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Multi-providers
# ---------------------------------------------------------------------------------------------------------------------
locals {
  clusters_k8s_linode = { for id, cluster in local.environments_clusters_create :
    id => cluster if cluster.provider == "linode"
  }

  clusters_k8s_digitalocean = { for id, cluster in local.environments_clusters_create :
    id => cluster if cluster.provider == "digitalocean"
  }
}
