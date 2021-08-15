# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL INPUTS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "globalinfra_vcs_repo_name" {
  description = <<-DESC
    Name of the global infra repo so that oStack can apply its settings to it (eg. branch protection, team access)
    It must be created already on the default VCS provider.
    Set to `null` if you don't want oStack to manage this repo at all.
    DESC
  type        = string
  default     = null
}

variable "globalinfra_backend_workspace_name" {
  description = <<-DESC
    Name of the global infra backend workspace name so that oStack can propagate backend runs.
    This is used because Terraform Cloud won't trigger a run when variables values change, but oStack needs to in order to keep the configuration up to date!
    It must be created already on the default backend provider.
    Set to `null` if you don't want runs to propagate.
    DESC
  type        = string
  default     = null
}
