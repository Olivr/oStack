# ---------------------------------------------------------------------------------------------------------------------
# Required inputs
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
variable "tenants" {
  description = "Tenants and their repos."
  type = map(object({
    name             = string
    environments     = set(string)
    tenant_isolation = bool
    gpg_keys = map(object({
      name        = string
      fingerprint = string
      public_key  = string
    }))
    repos = map(object({
      name = string
      type = string
      vcs = object({
        provider            = string
        repo_http_url       = string
        repo_ssh_url        = string
        branch_default_name = string
      })
    }))
  }))
}

variable "environments" {
  description = "Environments and their clusters."
  type = map(object({
    name = string
    clusters = map(object({
      name            = string
      bootstrap       = bool
      gpg_fingerprint = string
      gpg_public_key  = string
    }))
  }))
}

variable "repo_ssh_url" {
  description = "SSH URL for cloning the repository."
  type        = string
  validation {
    condition     = var.repo_ssh_url != null
    error_message = "You must specify the SSH url for cloning the repository."
  }
}

variable "commit_status_http_url" {
  description = "HTTP URL of the repository."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Optional inputs
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "branch_name" {
  description = "Main repository branch name."
  type        = string
  default     = "main"
  validation {
    condition     = var.branch_name != null
    error_message = "You must specify the main repository branch name."
  }
}

variable "commit_status_provider" {
  description = "Name of the VCS provider (used to define if Flux can send commit statuses)."
  type        = string
  default     = "github"
}

variable "system_dir" {
  description = "Name of the system directory."
  type        = string
  default     = "_ostack"
  validation {
    condition     = var.system_dir != null
    error_message = "You must specify the name of the system directory."
  }
}

variable "base_dir" {
  description = "Name of the base directory where contributors must place their base files."
  type        = string
  default     = "_base"
  validation {
    condition     = var.base_dir != null
    error_message = "You must specify the name of the base directory."
  }
}

variable "overlay_dir" {
  description = "Name of the overlay directory where contributors must place their overlay files."
  type        = string
  default     = "_overlays"
  validation {
    condition     = var.overlay_dir != null
    error_message = "You must specify the name of the overlay directory."
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

variable "clusters_dir" {
  description = "Name of the tenants directory."
  type        = string
  default     = "clusters"
  validation {
    condition     = var.clusters_dir != null
    error_message = "You must specify a the name of the clusters directory."
  }
}

variable "environments_dir" {
  description = "Name of the tenants directory."
  type        = string
  default     = "environments"
  validation {
    condition     = var.environments_dir != null
    error_message = "You must specify a the name of the environments directory."
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
