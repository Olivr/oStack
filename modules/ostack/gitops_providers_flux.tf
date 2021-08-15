# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
module "gitops_flux" {
  source = "../gitops-flux"

  for_each = local.gitops_flux

  base_dir               = local.globalops_gitops_create.base_dir
  branch_name            = local.globalops_vcs_create.branch_default_name
  cluster_init_path      = local.globalops_gitops_create.cluster_init_path
  commit_status_http_url = local.globalops_vcs_create.repo_http_url
  commit_status_provider = local.globalops_vcs_create.provider
  deploy_keys            = local.globalops_gitops_deploy_keys
  environments           = local.globalops_gitops_create.environments
  infra_dir              = local.globalops_gitops_create.infra_dir
  init_cluster           = local.globalops_gitops_create.init_cluster
  local_var_template     = local.globalops_gitops_local_vars_template
  overlay_dir            = local.globalops_gitops_create.overlay_dir
  repo_ssh_url           = local.globalops_vcs_create.repo_ssh_url
  secrets                = local.globalops_gitops_secrets
  system_dir             = local.globalops_gitops_create.system_dir
  tenants                = local.globalops_gitops_create.namespaces
}
