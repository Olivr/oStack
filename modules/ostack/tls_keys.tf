# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
# Generate "deploy key" to be used by Flux
resource "tls_private_key" "cluster_keys" {
  for_each = toset(keys(local.environments_clusters))

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "ns_keys" {
  for_each = local.ns_keys_create

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "ci_keys" {
  for_each = local.tls_keys_ci_create

  algorithm = "RSA"
  rsa_bits  = 4096
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  tls_keys_ci_create = setunion(["_globalops"], keys(local.namespaces_repos_ops))

  ns_keys_create = toset(
    [
      for pair in setproduct(
        keys(local.namespaces_repos_ops),
        keys(local.environments_clusters)
      ) : "${pair[0]}_${pair[1]}"
    ]
  )
}
