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
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Dev mode
  dev = var.dev_mode != null ? merge(local.dev_mode, var.dev_mode) : {}
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# These variables are referenced in this file only
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Defaults for dev mode
  dev_mode = {
    template_globalconfig     = null
    template_globalops        = "../../templates/global-ops"
    template_apps             = "../../templates/ns-apps"
    template_infra            = "../../templates/ns-infra"
    template_ops              = "../../templates/ns-ops"
    module_cluster_init       = "../init-cluster-flux"
    all_files_strict          = true # Any file that is created should be tracked by Terraform
    globalinfra_vcs_repo_name = null # Disables configuring the global-infra repo which is usually not created when developing
    disable_outputs           = true # It is quite annoying to have long outputs printed out after an apply/plan
  }
}
