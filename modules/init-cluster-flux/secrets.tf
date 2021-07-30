# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "deploy_keys" {
  for_each = var.deploy_keys

  depends_on = [
    kubectl_manifest.namespaces,
    kubectl_manifest.flux_system
  ]

  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    type: Opaque
    metadata:
      name: "${each.value.name}"
      namespace: "${each.value.namespace}"
      labels:
        toolkit.fluxcd.io/tenant: ${each.value.namespace}
    data:
      "known_hosts": >-
        ${base64encode(each.value.known_hosts)}
      "identity.pub": >-
        ${each.value.public_key}
      "identity": >-
        ${base64encode(can(regex("^sensitive::", each.value.private_key)) ? sensitive(var.sensitive_inputs[trimprefix(each.value.private_key, "sensitive::")]) : each.value.private_key)}
    YAML
}

resource "kubectl_manifest" "secrets" {
  for_each = var.secrets

  depends_on = [
    kubectl_manifest.namespaces,
    kubectl_manifest.flux_system
  ]

  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    type: Opaque
    metadata:
      name: "${each.value.name}"
      namespace: "${each.value.namespace}"
      labels:
        toolkit.fluxcd.io/tenant: ${each.value.namespace}
    data:
    %{for k, v in each.value.data}
      "${k}": >-
        ${base64encode(can(regex("^sensitive::", v)) ? sensitive(var.sensitive_inputs[trimprefix(v, "sensitive::")]) : v)}
    %{endfor~}
    YAML
}
