# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
module "gitops_flux" {
  source = "../gitops-flux"

  namespaces        = local.namespaces
  environments      = local.environments
  base_dir          = local.gitops_configuration[var.gitops_default_provider].base_dir
  global            = local.global_ops_repo_defaults
  cluster_init_path = lookup(local.dev, "module_cluster_init", null)
}
