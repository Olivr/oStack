# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
module "gitops_flux" {
  source = "../gitops-flux"

  for_each = local.gitops_flux

  base_dir           = local.globalops_static.gitops.base_dir
  cluster_init_path  = local.globalops_static.gitops.cluster_init_path
  deploy_keys        = local.globalops_gitops_deploy_keys
  environments       = local.globalops_static.gitops.environments
  global             = local.globalops_static
  infra_dir          = local.globalops_static.gitops.infra_dir
  init_cluster       = local.globalops_static.gitops.init_cluster
  local_var_template = local.globalops_gitops_local_vars_template
  namespaces         = local.globalops_static.gitops.namespaces
  secrets            = local.globalops_gitops_secrets
}
