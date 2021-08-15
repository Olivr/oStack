# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "gpg_private_key" "cluster_keys" {
  for_each = { for id, cluster in merge(local.environments_clusters_existing, local.environments_clusters_create) :
    id => cluster if cluster.bootstrap && lookup(cluster, "gpg_fingerprint", null) == null
  }

  name  = each.value.name
  email = "${each.value.name}@${var.organization_name}"
}
