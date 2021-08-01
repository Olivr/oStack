# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED INPUTS
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
# Cloud providers
variable "cloud_default_provider" {
  description = "Default cloud provider."
  type        = string

  validation {
    error_message = "Variable cloud_default_provider cannot be null or empty."
    condition     = var.cloud_default_provider != null && var.cloud_default_provider != ""
  }

  validation {
    error_message = "Accepted values are linode, digitalocean."
    condition     = contains(["linode", "digitalocean"], var.cloud_default_provider)
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL INPUTS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
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
