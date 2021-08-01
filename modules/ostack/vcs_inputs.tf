# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED INPUTS
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
# VCS token with write access
variable "vcs_write_token" {
  description = "VCS token with write access, per VCS provider. Used for updating commit statuses in GitOps and is also added as a secret to each repo for automerge. This behaviour can be overriden in `repo_secrets` in `vcs_configuration_base` or per repo in `namespaces`."
  type        = map(string)
  sensitive   = true

  validation {
    error_message = "Variable vcs_write_token cannot be null."
    condition     = var.vcs_write_token != null
  }

  validation {
    error_message = "You must specify a supported VCS provider."
    condition = alltrue([for provider in keys(var.vcs_write_token) :
      contains(["github"], provider)
    ])
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL INPUTS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
# Version Control System
variable "vcs_organization_name" {
  description = "VCS Organization name."
  type        = string
  default     = null
}

variable "vcs_default_provider" {
  description = "Default VCS provider."
  type        = string
  default     = "github"

  validation {
    error_message = "Variable vcs_default_provider cannot be null."
    condition     = var.vcs_default_provider != null
  }

  validation {
    condition     = contains(["github"], var.vcs_default_provider)
    error_message = "You must specify a supported VCS provider."
  }
}

variable "vcs_configuration_base" {
  description = "Base VCS configuration per provider."
  default     = {}
  type = map(object({
    branch_default_name              = optional(string)
    branch_delete_on_merge           = optional(bool)
    branch_protection                = optional(bool)
    branch_protection_enforce_admins = optional(bool)
    branch_review_count              = optional(number)
    branch_status_checks             = optional(set(string))
    file_templates                   = optional(map(string))
    files                            = optional(map(string))
    files_strict                     = optional(map(string))
    repo_allow_merge_commit          = optional(bool)
    repo_allow_rebase_merge          = optional(bool)
    repo_allow_squash_merge          = optional(bool)
    repo_archive_on_destroy          = optional(bool)
    repo_auto_init                   = optional(bool)
    repo_enable_issues               = optional(bool)
    repo_enable_projects             = optional(bool)
    repo_enable_wikis                = optional(bool)
    repo_homepage_url                = optional(string)
    repo_is_template                 = optional(bool)
    repo_issue_labels                = optional(map(string))
    repo_private                     = optional(bool)
    repo_secrets                     = optional(map(string))
    repo_vulnerability_alerts        = optional(bool)
    tags                             = optional(set(string))
    repo_templates = optional(object({
      apps          = optional(string)
      global_config = optional(string)
      global_ops    = optional(string)
      infra         = optional(string)
      ops           = optional(string)
    }))
  }))

  validation {
    error_message = "Variable vcs_configuration_base cannot be null."
    condition     = var.vcs_configuration_base != null
  }

  validation {
    error_message = "You must specify a supported VCS provider."
    condition = alltrue([for provider in keys(var.vcs_configuration_base) :
      contains(["github"], provider)
    ])
  }
}
