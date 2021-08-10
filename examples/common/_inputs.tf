# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED INPUTS
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
variable "organization_name" {
  description = <<-DESC
    Computer-friendly organization name (eg. my-startup).
    Use only letters, numbers and dashes to maximize compatibility across every system.
    DESC
  type        = string

  validation {
    error_message = "Organization name must only contain alphanumeric characters. It may contain '-' but cannot start or finish with it."
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?([a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])?)*$", var.organization_name))
  }
}

variable "tfe_oauth_token_id" {
  description = "ID representing the oAuth connection between GitHub and Terraform cloud. It is used by oStack for connecting Terraform Cloud workspaces to GitHub repos."
  type        = string
  validation {
    condition     = var.tfe_oauth_token_id != null && var.tfe_oauth_token_id != ""
    error_message = "You must specify a Terraform Cloud VCS token ID."
  }
}

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

variable "vcs_write_token" {
  description = <<-DESC
    VCS token with write access, per VCS provider.
    Used for updating commit statuses in GitOps and is also added as a secret to each repo for automerge.
    This behaviour can be overriden in `repo_secrets` in `vcs_configuration_base` or per repo in `namespaces`.
    DESC
  type        = map(string)
  sensitive   = true

  validation {
    error_message = "Variable vcs_write_token cannot be null."
    condition     = var.vcs_write_token != null
  }

  validation {
    error_message = "You must specify a supported VCS provider (github)."
    condition = alltrue([for provider in keys(var.vcs_write_token) :
      contains(["github"], provider)
    ])
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL INPUTS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "sensitive_inputs" {
  description = "Values that should be marked as sensitive."
  type        = map(string)
  sensitive   = true
  default     = {}

  validation {
    error_message = "Variable sensitive_inputs cannot be null."
    condition     = var.sensitive_inputs != null
  }

  validation {
    error_message = "Null values are not accepted. Use empty values instead."
    condition     = alltrue([for v in values(var.sensitive_inputs) : v != null])
  }
}
