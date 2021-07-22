# ---------------------------------------------------------------------------------------------------------------------
# Required inputs
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
variable "namespaces" {
  description = "Namespaces to be used as isolated tenants."
  type = map(object({
    name         = string
    environments = set(string)
    repos = map(object({
      name = string
      type = string
      vcs = object({
        provider            = string
        http_url            = string
        ssh_url             = string
        branch_default_name = string
      })
    }))
  }))
}

variable "environments" {
  description = "Clusters per environments."
  type = map(object({
    name = string
    clusters = map(object({
      name = string
    }))
  }))
}

variable "global" {
  description = "Global ops repo configuration."
  type = object({
    provider            = string
    http_url            = string
    ssh_url             = string
    branch_default_name = string
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# Optional inputs
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "base_dir" {
  description = "Name of the base directory."
  type        = string
  default     = "_base"
  validation {
    condition     = var.base_dir != null
    error_message = "You must specify a the name of the base directory."
  }
}

variable "infra_dir" {
  description = "Name of the infrastructure directory."
  type        = string
  default     = "_infra"
  validation {
    condition     = var.infra_dir != null
    error_message = "You must specify a the name of the infrastructure directory."
  }
}

variable "tenants_dir" {
  description = "Name of the tenants directory."
  type        = string
  default     = "tenants"
  validation {
    condition     = var.tenants_dir != null
    error_message = "You must specify a the name of the tenants directory."
  }
}

variable "cluster_init_path" {
  description = "Path to the cluster init module directory if you'd rather use an inline module rather than an external one."
  type        = string
  default     = null
}

variable "cluster_init_module" {
  description = "Remote Terraform module used to bootstrap a cluster (superseeded by `cluster_init_path`)."
  type        = string
  default     = "Olivr/init-cluster/flux"
  validation {
    condition     = var.cluster_init_module != null
    error_message = "You must specify a module source. If you want to use a local module, you should specify `cluster_init_path` instead."
  }
}
