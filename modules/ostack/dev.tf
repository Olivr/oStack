# This is for expert users and oStack developers

# ---------------------------------------------------------------------------------------------------------------------
# Inputs
# ---------------------------------------------------------------------------------------------------------------------
variable "dev_mode" {
  description = "For expert users or oStack developers. Set it to a map of dev settings to use it."
  type        = map(any)
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Dev mode
  dev = var.dev_mode != null ? merge(local.dev_mode, var.dev_mode) : {}
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Defaults for dev mode
  dev_mode = {
    template_global_config = null
    template_global_ops    = "../../templates/global-ops"
    template_apps          = "../../templates/ns-apps"
    template_infra         = "../../templates/ns-infra"
    template_ops           = "../../templates/ns-ops"
    module_cluster_init    = "../init-cluster-flux"
    all_files_strict       = true # Any file that is created should be tracked by Terraform
  }
}
