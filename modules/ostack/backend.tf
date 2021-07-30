# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  backends_namespaces = merge(
    module.backends_namespaces_tfe
  )

  backends_globalops = merge(
    module.backends_globalops_tfe
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Multi-providers
# ---------------------------------------------------------------------------------------------------------------------
locals {
  backends_namespaces_tfe = { for id, backend in local.namespaces_backends_create :
    id => backend if backend.provider == "tfe"
  }

  backends_globalops_tfe = var.backend_default_provider == "tfe" ? toset(local.globalops_backend_create) : toset([])
}
