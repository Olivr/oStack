# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL INPUTS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
# Gitops
variable "gitops_default_provider" {
  description = "Default GitOps provider."
  type        = string
  default     = "flux"

  validation {
    error_message = "Variable gitops_default_provider cannot be null or empty."
    condition     = var.gitops_default_provider != null && var.gitops_default_provider != ""
  }

  validation {
    error_message = "You must specify a supported GitOps provider (flux)."
    condition     = contains(["flux"], var.gitops_default_provider)
  }
}

variable "gitops_config_base" {
  description = "Base GitOps configuration per provider."
  default     = { flux = {} }
  type = map(object({
    base_dir = optional(string)
    init_cluster = optional(object({
      module_source  = optional(string)
      module_version = optional(string)
    }))
  }))

  validation {
    error_message = "Variable gitops_config_base cannot be null."
    condition     = var.gitops_config_base != null
  }

  validation {
    error_message = "You must specify only supported GitOps providers."
    condition = alltrue([for provider in keys(var.gitops_config_base) :
      contains(["flux"], provider)
    ])
  }
}
