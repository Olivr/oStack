# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
module "cloud_clusters_k8s_digitalocean" {
  source = "../k8s-cluster-digitalocean"

  for_each = local.cloud_clusters_k8s_digitalocean

  kube_version = each.value.kube_version
  name         = each.value.name
  nodes        = each.value.nodes
  region       = each.value.region
  tags         = each.value.tags
}
