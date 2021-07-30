# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "flux_system" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: flux-system
    YAML

  lifecycle {
    prevent_destroy = true
  }
}

resource "kubectl_manifest" "namespaces" {
  for_each  = var.namespaces
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: ${each.value}
    YAML
}
