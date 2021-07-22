# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "digitalocean_kubernetes_cluster" "cluster" {
  name         = var.name
  region       = var.region
  version      = data.digitalocean_kubernetes_versions.cluster.latest_version
  auto_upgrade = var.auto_upgrade
  tags         = var.tags

  dynamic "node_pool" {
    for_each = var.nodes
    content {
      name       = "${var.name}-${index(keys(var.nodes), node_pool.key) + 1}"
      size       = node_pool.key
      node_count = node_pool.value
    }
  }
}

data "digitalocean_kubernetes_versions" "cluster" {
  version_prefix = "${var.kube_version}."
}
