# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "gpg_private_key" "ci_key" {
  name  = "ci"
  email = "ci@${var.organization_name}"
}

resource "gpg_private_key" "cluster_keys" {
  for_each = local.gpg_keys_cluster_create
  name     = each.value
  email    = "${each.value}@${var.organization_name}"
}

resource "gpg_private_key" "ns_keys" {
  for_each = local.gpg_keys_ns_create
  name     = each.value
  email    = "${each.value}@${var.organization_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  gpg_keys_cluster_create = { for id, cluster in local.environments_clusters :
    id => cluster.name if cluster.bootstrap && lookup(cluster, "gpg_fingerprint", null) == null
  }
  gpg_keys_ns_create = merge([for env_id, env in local.environments :
    { for ns_id, ns in local.namespaces_ops :
      "${env_id}_${ns_id}" => "${env.name}-${ns.name}"
    }
  ]...)
}
