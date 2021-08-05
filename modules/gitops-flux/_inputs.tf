# ---------------------------------------------------------------------------------------------------------------------
# Required inputs
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
variable "namespaces" {
  description = "Namespaces to be used as isolated tenants."
  type = map(object({
    name             = string
    environments     = set(string)
    tenant_isolation = bool
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
      name      = string
      bootstrap = bool
    }))
  }))
}

variable "global" {
  description = "Global ops repo configuration."
  type = object({
    vcs = object({
      provider            = string
      http_url            = string
      ssh_url             = string
      branch_default_name = string
    })
    backends = map(object({
      vcs_working_directory = string
      _env_name             = string
      _cluster_name         = string
    }))
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
    error_message = "You must specify the name of the base directory."
  }
}

variable "infra_dir" {
  description = "Name of the infrastructure directory."
  type        = string
  default     = "_init"
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

variable "init_cluster" {
  description = "Remote Terraform module used to bootstrap a cluster (superseeded by `cluster_init_path`)."
  type = object({
    module_source  = string
    module_version = string
  })
  default = {
    module_source  = "Olivr/init-cluster/flux"
    module_version = null
  }
  validation {
    condition     = var.init_cluster != null && var.init_cluster.module_source != null
    error_message = "You must specify a module source. If you want to use a local module, you should specify `cluster_init_path` instead and leave this with the defaults."
  }
}

variable "local_var_template" {
  description = "JSON Terraform variables template with empty values."
  type        = string
  default     = ""
  validation {
    condition     = var.local_var_template != null
    error_message = "Variable local_var_template cannot be null, use an empty value instead."
  }
}

variable "deploy_keys" {
  description = "Deploy keys to add to each cluster at bootstrap time. You can pass sensitive values by setting the `private_key` value to `sensitive::key` where `key` refers to a value in `sensitive_inputs` (defined at run time in the infrastructure backend)."
  type = map(map(object({
    name        = string
    namespace   = string
    known_hosts = string
    private_key = string
    public_key  = string
  })))
  default = {}
}

variable "secrets" {
  description = "Secrets to add to each cluster at bootstrap time. You can pass sensitive values by setting the `private_key` value to `sensitive::key` where `key` refers to a value in `sensitive_inputs` (defined at run time in the infrastructure backend)."
  type = map(map(object({
    name      = string
    namespace = string
    data      = map(string)
  })))
  default = {}
}
