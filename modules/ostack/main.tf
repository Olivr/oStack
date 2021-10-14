# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  organization_title                 = var.organization_title != null && var.organization_title != "" ? var.organization_title : title(replace(var.organization_name, "-", " "))
  globalinfra_vcs_repo_name          = lookup(local.dev, "globalinfra_vcs_repo_name", var.globalinfra_vcs_repo_name)
  globalinfra_backend_workspace_name = lookup(local.dev, "globalinfra_backend_workspace_name", var.globalinfra_backend_workspace_name)

  config_file = {
    version = "1.0.0"
    organization = {
      name = var.organization_name
      vcs  = local.vcs_organization_name
    }
  }
}
