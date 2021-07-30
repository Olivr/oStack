# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL INPUTS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
# Cloud providers
variable "cloud_default_provider" {
  description = "Default cloud provider."
  type        = string
  default     = "linode"

  validation {
    error_message = "Variable cloud_default_provider cannot be null."
    condition     = var.cloud_default_provider != null
  }

  validation {
    error_message = "You must specify a supported cloud provider."
    condition     = contains(["linode", "digitalocean"], var.cloud_default_provider)
  }
}

variable "cluster_configuration_base" {
  description = "Base cluster configuration per cloud provider."
  default     = {}
  type = map(object({
    autoscale    = optional(bool)
    kube_version = optional(string)
    nodes        = optional(map(number))
    region       = optional(string)
    tags         = optional(set(string))
  }))

  validation {
    error_message = "Variable cluster_configuration_base cannot be null."
    condition     = var.cluster_configuration_base != null
  }

  validation {
    error_message = "You must specify only supported cloud providers."
    condition = alltrue([for provider in keys(var.cluster_configuration_base) :
      contains(["linode", "digitalocean"], provider)
    ])
  }
}
