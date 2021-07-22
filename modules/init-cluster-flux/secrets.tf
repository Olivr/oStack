resource "kubernetes_secret" "deploy_keys" {
  for_each = var.deploy_keys
  depends_on = [
    kubernetes_namespace.namespaces,
    kubernetes_namespace.flux_system
  ]

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  data = {
    "identity.pub" = base64decode(each.value.public_key)
    known_hosts    = each.value.known_hosts
    identity = can(
      regex("^sensitive::", each.value.private_key)
      ) ? (
      sensitive(var.sensitive_inputs[trimprefix(each.value.private_key, "sensitive::")])
      ) : (
      each.value.private_key
    )
  }
}

resource "kubernetes_secret" "secrets" {
  for_each = var.secrets
  depends_on = [
    kubernetes_namespace.namespaces,
    kubernetes_namespace.flux_system
  ]

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  data = { for k, v in each.value.data :
    k => can(regex("^sensitive::", v)) ? sensitive(var.sensitive_inputs[trimprefix(v, "sensitive::")]) : v
  }
}
