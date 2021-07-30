# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
# Generate "deploy key" to be used by Flux
resource "tls_private_key" "cluster_keys" {
  for_each = local.environments_keys_create

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "ns_keys" {
  for_each = local.ns_keys_create

  algorithm = "RSA"
  rsa_bits  = 4096
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  environments_keys_create = setunion(keys(local.environments_clusters_create), ["_ci"])

  ns_keys_create = toset(
    [
      for pair in setproduct(
        [for id, repo in local.namespaces_repos_static : id if repo.type == "ops"],
        local.environments_keys_create
      ) : "${pair[0]}_${pair[1]}"
    ]
  )
}
