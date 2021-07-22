# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "ui_url" {
  description = "Management UI"
  value       = "https://app.terraform.io/app/${var.workspace_organization}/workspaces/${tfe_workspace.workspace.name}"
}
