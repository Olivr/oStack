# ---------------------------------------------------------------------------------------------------------------------
# Required inputs
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "The name of the repository."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Optional inputs
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "repo_exists" {
  description = "Set to `true` if the repository already exists."
  type        = bool
  default     = false
}

# Repository attributes

variable "description" {
  description = "A description of the repository."
  type        = string
  default     = null
}

variable "homepage_url" {
  description = "URL of a page describing the project."
  type        = string
  default     = null
}

variable "private" {
  description = "Set to `true` to create a private repository."
  type        = bool
  default     = true
}

variable "has_issues" {
  description = "Set to `true` to enable the GitHub Issues features on the repository."
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Set to `true` to enable the GitHub Projects features on the repository."
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "Set to `true` to enable the GitHub Wiki features on the repository."
  type        = bool
  default     = null
}

variable "is_template" {
  description = "Repository is a template repository."
  type        = bool
  default     = false
}

variable "allow_merge_commit" {
  description = "Allow merge commits."
  type        = bool
  default     = true
}

variable "allow_squash_merge" {
  description = "Allow squash merge."
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "Allow rebase merge."
  type        = bool
  default     = true
}

variable "auto_init" {
  description = "Set to `true` to produce an initial commit in the repository."
  type        = bool
  default     = false
}

variable "archive_on_destroy" {
  description = "Set to `true` to archive the repository instead of deleting on destroy."
  type        = bool
  default     = false
}

variable "topics" {
  description = "The list of topics of the repository."
  type        = set(string)
  default     = []
}

variable "vulnerability_alerts" {
  description = "Set to `true` to enable security alerts for vulnerable dependencies. Enabling requires alerts to be enabled on the owner level."
  type        = bool
  default     = null
}

variable "template" {
  description = "Template to use when creating repository."
  type        = string
  default     = null
}

# Branches

variable "branch_delete_on_merge" {
  description = "Automatically delete branch after a pull request is merged."
  type        = bool
  default     = false
}

variable "branch_protection" {
  description = "Enable branch protection. \nFor private repos, it is only available on the paid plan."
  type        = bool
  default     = false
}

variable "branch_protection_enforce_admins" {
  description = "Enforce admins on branch protection."
  type        = bool
  default     = true
}

variable "branch_review_count" {
  description = "Number of required reviews before merging pull requests."
  type        = number
  default     = 0
  validation {
    condition     = var.branch_review_count >= 0 && var.branch_review_count <= 6
    error_message = "The branch_review_count value must be between 0 and 6."
  }
}

variable "branch_status_checks" {
  description = "List of status checks required before merging pull requests."
  type        = list(string)
  default     = []
  validation {
    error_message = "Variable branch_status_checks cannot be null."
    condition     = var.branch_status_checks != null
  }
}

# Teams

variable "team_permissions" {
  description = "Teams access levels."
  type = object({
    pull     = optional(list(string))
    triage   = optional(list(string))
    push     = optional(list(string))
    maintain = optional(list(string))
    admin    = optional(list(string))
  })
  default = {}
}

variable "teams" {
  description = "Map of GitHub teams."
  type = map(object({
    id      = string
    node_id = string
  }))
  default = {}
}

# Other resources

variable "issue_labels" {
  description = "Map of labels and their colors to add to the repository. \nIn the format { \"label\" = \"FFFFFF\" }"
  type        = map(string)
  default     = {}
  validation {
    error_message = "You must specify a color for each label."
    condition     = alltrue([for v in values(var.issue_labels) : v != null && v != ""])
  }
}

variable "secrets" {
  description = "Secrets to be added to the repo. You can pass sensitive values by setting the secret value to `sensitive::key` where `key` refers to a value in `sensitive_inputs`."
  type        = map(string)
  default     = {}
  validation {
    error_message = "Null values are not accepted. Use empty values instead."
    condition     = alltrue([for v in values(var.secrets) : v != null])
  }
}

variable "deploy_keys" {
  description = "Map of repository deploy keys. You can pass sensitive values by setting the `ssh_key` value to `sensitive::key` where `key` refers to a value in `sensitive_inputs`."
  default     = {}
  type = map(object({
    title     = string
    ssh_key   = string
    read_only = optional(bool)
  }))
  validation {
    error_message = "Null values are not accepted for `ssh_key` and `title`."
    condition     = alltrue([for v in values(var.deploy_keys) : v.title != null && v.ssh_key != null])
  }
}

variable "strict_files" {
  description = "Files to add to the repository's default branch. These files are tracked by Terraform to make sure their content always matches the configuration."
  type        = map(string)
  default     = {}
  validation {
    error_message = "Variable strict_files cannot be null."
    condition     = var.strict_files != null
  }
  validation {
    error_message = "Null values are not accepted. Use empty values instead."
    condition     = alltrue([for v in values(var.strict_files) : v != null])
  }
}

variable "files" {
  description = "Files to add to the repository's default branch. These files can be modified outside of Terraform."
  type        = map(string)
  default     = {}
  validation {
    error_message = "Variable files cannot be null."
    condition     = var.files != null
  }
  validation {
    error_message = "Null values are not accepted. Use empty values instead."
    condition     = alltrue([for v in values(var.files) : v != null])
  }
}

variable "sensitive_inputs" {
  description = "Values that should be marked as sensitive. Supported by `secrets`, `deploy_keys`."
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
