# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
module "gitops_flux" {
  source = "../gitops-flux"

  for_each = local.gitops_flux

  base_dir           = local.globalops_defaults.gitops.base_dir
  cluster_init_path  = local.globalops_defaults.gitops.cluster_init_path
  deploy_keys        = local.globalops_gitops_deploy_keys
  environments       = local.globalops_defaults.gitops.environments
  global             = local.globalops_defaults
  infra_dir          = local.globalops_defaults.gitops.infra_dir
  init_cluster       = local.globalops_defaults.gitops.init_cluster
  local_var_template = local.globalops_gitops_local_vars_template
  namespaces         = local.globalops_defaults.gitops.namespaces
  secrets            = local.globalops_gitops_secrets
}
