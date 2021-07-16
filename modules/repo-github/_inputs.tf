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
variable "enable" {
  description = "Enable this module. If set to false, no resources will be created."
  type        = bool
  default     = true
}

variable "repo_exists" {
  description = "Set to `true` if the repository aalready exists."
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
  description = "Map of labels and their colors to add to the repository. \nIn the format { \"label\" = \"#FFFFFF\" }"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Pass secrets. Set a secret to null to use the sensitive_inputs value corresponding to its key."
  type        = map(string)
  default     = {}
}

variable "sensitive_inputs" {
  description = "Pass sensitive inputs here."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "deploy_keys" {
  description = "Map of repository deploy keys. Set the `ssh_key` parameter to `null` to use the corresponding value in `sensitive_inputs` (store it in the format `my_key_ssh_key`)."
  type = map(object({
    title     = string
    ssh_key   = string
    read_only = optional(bool)
  }))
  default = {}
}

variable "files" {
  description = "Files to add to the repository's default branch."
  type        = map(string)
  default     = {}
}
