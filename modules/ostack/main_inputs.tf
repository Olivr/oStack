# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED INPUTS
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
# Global
variable "organization_title" {
  description = "Human-friendly organization title (eg. My Super Startup)."
  type        = string
  validation {
    condition     = var.organization_title != null && var.organization_title != ""
    error_message = "You must specify a title for your organization."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL INPUTS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
# Global
variable "organization_name" {
  description = "Computer-friendly organization name (eg. my-super-startup). \nUse only letters, numbers and dashes to maximize compatibility across every system."
  type        = string
  default     = null
  validation {
    error_message = "Organization name must only contain alphanumeric characters. It may contain '-' but cannot start or finish with it."
    condition     = var.organization_name == null || can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?([a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])?)*$", var.organization_name))
  }
}

variable "lang" {
  description = "Translation file to use. This can be one of the bundled translations of oStack or a custom translation object. \nThis can be used to overwrite how things are called through your stack."
  type        = any
  default     = "en"

  validation {
    error_message = "Variable lang cannot be null."
    condition     = var.lang != null
  }

  validation {
    error_message = "You must specify a supported language or provide your own."
    condition     = contains(["en", "fr"], var.lang) || try(length(keys(var.lang)), 0) > 0
  }
}

variable "prefix" {
  description = "Prefix to prepend to all generated resource names. It is not applied wherever you specify resource names explicitly."
  type        = string
  default     = ""
  validation {
    error_message = "Variable prefix cannot be null."
    condition     = var.prefix != null
  }
}

variable "tags" {
  description = "Tags to be applied to all resources that support it. It is not applied wherever you specify resource tags explicitly."
  type        = set(string)
  default     = ["oStack"]
  validation {
    error_message = "Variable tags cannot be null."
    condition     = var.tags != null
  }
}

variable "sensitive_inputs" {
  description = "Values that should be marked as sensitive. Supported by `repo_secrets` (vcs), `env_vars` (backend), `tf_vars` (backend), `tf_vars_hcl` (backend), `kube_config` (cluster)."
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

variable "continuous_delivery" {
  description = "Should continuous delivery be applied by default. This applies to all aspects of the stack (devops, gitops, iac)."
  type        = bool
  default     = true
  validation {
    error_message = "Variable continuous_delivery cannot be null."
    condition     = var.continuous_delivery != null
  }
}
