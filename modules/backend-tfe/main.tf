# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
# Create workspace
resource "tfe_workspace" "workspace" {
  name              = var.workspace_name
  description       = var.workspace_description
  organization      = var.workspace_organization
  auto_apply        = var.workspace_auto_apply
  working_directory = var.vcs_working_directory
  vcs_repo {
    identifier     = var.vcs_repo_path
    branch         = var.vcs_branch_name
    oauth_token_id = var.tfe_oauth_token_id
  }
}

# Add secrets
resource "tfe_variable" "tf_vars" {
  for_each = var.workspace_tf_vars

  workspace_id = tfe_workspace.workspace.id
  category     = "terraform"
  sensitive    = each.value == null
  key          = each.key
  value = can(
    regex("^sensitive::", each.value)
    ) ? (
    sensitive(var.sensitive_inputs[trimprefix(each.value, "sensitive::")])
    ) : (
    each.value
  )
}

# Add secrets in HCL format
resource "tfe_variable" "tf_vars_hcl" {
  for_each = var.workspace_tf_vars_hcl

  workspace_id = tfe_workspace.workspace.id
  category     = "terraform"
  hcl          = true
  sensitive    = each.value == null
  key          = each.key
  value = can(
    regex("^sensitive::", each.value)
    ) ? (
    sensitive(var.sensitive_inputs[trimprefix(each.value, "sensitive::")])
    ) : (
    each.value
  )
}

# Add environment variables
resource "tfe_variable" "env_variables" {
  for_each = var.workspace_env_vars

  workspace_id = tfe_workspace.workspace.id
  category     = "env"
  sensitive    = each.value == null
  key          = each.key
  value = can(
    regex("^sensitive::", each.value)
    ) ? (
    sensitive(var.sensitive_inputs[trimprefix(each.value, "sensitive::")])
    ) : (
    each.value
  )
}
