# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Partials directory path
  partial = "${path.module}/partials"

  # Remove begining and trailing '/' from directory names
  base_dir    = trim(var.base_dir, "/")
  infra_dir   = trim(var.infra_dir, "/")
  tenants_dir = trim(var.tenants_dir, "/")

  # Normalize cluster_init_path if it was provided
  cluster_init_path = var.cluster_init_path == null || var.cluster_init_path == "" ? null : trimsuffix(
    can(regex("^/", var.cluster_init_path)) ? var.cluster_init_path : "${path.module}/${var.cluster_init_path}"
  , "/")

  # Index tenants by name instead of ID
  tenants = { for namespace in values(var.namespaces) :
    (namespace.name) => namespace if anytrue([for repo in namespace.repos : repo.type == "ops"])
  }

  # Only GitHub has been tested (Flux supports more though https://fluxcd.io/docs/components/notification/provider/#git-commit-status)
  # commit_status_notifications = ["github", "gitlab", "bitbucket", "azuredevops"]
  commit_status_providers = ["github"]

  # Not tested yet https://fluxcd.io/docs/components/notification/provider/
  # notifications_providers = ["slack", "msteams", "rocket", "discord", "googlechat", "webex", "sentry"]
}
