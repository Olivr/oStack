# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "sensitive_outputs" {
  description = "Sensitive outputs."
  sensitive   = true
  value = lookup(local.dev, "disable_outputs", false) ? null : {
    environments      = local.environments_outputs_sensitive
    namespaces        = local.namespaces_outputs_sensitive
    globalconfig_repo = local.globalconfig_outputs_sensitive
    globalops_repo    = local.globalops_outputs_sensitive
  }
}
