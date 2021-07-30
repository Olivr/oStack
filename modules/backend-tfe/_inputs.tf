# ---------------------------------------------------------------------------------------------------------------------
# Required inputs
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
variable "workspace_organization" {
  description = "Terraform Cloud organization name."
  type        = string
}

variable "workspace_name" {
  description = "Terraform Cloud workspace name."
  type        = string
}

variable "tfe_oauth_token_id" {
  description = "Terraform Cloud <> VCS OAuth connection ID."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Optional inputs
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "workspace_description" {
  description = "Terraform Cloud workspace description."
  type        = string
  default     = null
}

variable "workspace_auto_apply" {
  description = "Auto apply changes (Continuous delivery)."
  type        = bool
  default     = false
}

variable "workspace_tf_vars" {
  description = "Secrets to add to the workspace. You can pass sensitive values by setting the secret value to `sensitive::key` where `key` refers to a value in `sensitive_inputs`."
  type        = map(string)
  default     = {}
  validation {
    error_message = "Null values are not accepted. Use empty values instead."
    condition     = alltrue([for v in values(var.workspace_tf_vars) : v != null])
  }
}

variable "workspace_tf_vars_hcl" {
  description = "Terraform variables to add to the workspace. You can pass sensitive values by setting the secret value to `sensitive::key` where `key` refers to a value in `sensitive_inputs`."
  type        = map(string)
  default     = {}
  validation {
    error_message = "Null values are not accepted. Use empty values instead."
    condition     = alltrue([for v in values(var.workspace_tf_vars_hcl) : v != null])
  }
}

variable "workspace_env_vars" {
  description = "Environment variables to add to the workspace. You can pass sensitive values by setting the secret value to `sensitive::key` where `key` refers to a value in `sensitive_inputs`."
  type        = map(string)
  default     = {}
  validation {
    error_message = "Null values are not accepted. Use empty values instead."
    condition     = alltrue([for v in values(var.workspace_env_vars) : v != null])
  }
}

variable "vcs_repo_path" {
  description = "VCS repository path (<organization>/<repository>)."
  type        = string
}

variable "vcs_branch_name" {
  description = "VCS repository branch to track."
  type        = string
  default     = "main"
}

variable "vcs_working_directory" {
  description = "VCS repository branch to track."
  type        = string
  default     = ""
}

variable "vcs_trigger_paths" {
  description = "VCS repository branch to track."
  type        = set(string)
  default     = []
}

variable "sensitive_inputs" {
  description = "Values that should be marked as sensitive. Supported by `workspace_tf_vars`, `workspace_tf_vars_hcl`, `workspace_env_vars`."
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
