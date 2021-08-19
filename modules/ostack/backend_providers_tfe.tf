# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
module "backends_namespaces_tfe" {
  source = "../backend-tfe"

  for_each   = local.backends_namespaces_tfe
  depends_on = [local.vcs_repos_namespaces] # Needs the repo to be created for connecting the backend to it

  sensitive_inputs       = each.value.sensitive_inputs
  tfe_oauth_token_id     = sensitive(each.value.tfe_oauth_token_id) # Not really sensitive but TFE marked it as such
  vcs_branch_name        = local.namespaces_repos[each.value.repo_id].vcs.branch_default_name
  vcs_repo_path          = local.namespaces_repos[each.value.repo_id].vcs.repo_full_name
  vcs_working_directory  = each.value.vcs_working_directory
  vcs_trigger_paths      = each.value.vcs_trigger_paths
  workspace_auto_apply   = each.value.auto_apply
  workspace_description  = each.value.description
  workspace_env_vars     = each.value.env_vars
  workspace_name         = each.value.name
  workspace_organization = local.backend_organization_name
  workspace_tf_vars      = each.value.tf_vars
  workspace_tf_vars_hcl  = each.value.tf_vars_hcl
  workspace_triggers     = each.value.workspace_triggers
}

module "backends_globalops_tfe" {
  source = "../backend-tfe"

  for_each   = local.backends_globalops_tfe
  depends_on = [local.vcs_repo_globalops] # Needs the repo to be created for connecting the backend to it

  sensitive_inputs       = local.globalops.backends[each.key].sensitive_inputs
  tfe_oauth_token_id     = sensitive(local.globalops.backends[each.key].tfe_oauth_token_id) # Not really sensitive but TFE marked it as such
  vcs_branch_name        = local.globalops.vcs.branch_default_name
  vcs_repo_path          = local.globalops.vcs.repo_full_name
  vcs_working_directory  = local.globalops.backends[each.key].vcs_working_directory
  vcs_trigger_paths      = local.globalops.backends[each.key].vcs_trigger_paths
  workspace_auto_apply   = local.globalops.backends[each.key].auto_apply
  workspace_description  = local.globalops.backends[each.key].description
  workspace_env_vars     = local.globalops.backends[each.key].env_vars
  workspace_name         = local.globalops.backends[each.key].name
  workspace_organization = local.backend_organization_name
  workspace_tf_vars      = local.globalops.backends[each.key].tf_vars
  workspace_tf_vars_hcl  = local.globalops.backends[each.key].tf_vars_hcl
  workspace_triggers     = local.globalops.backends[each.key].workspace_triggers
}
