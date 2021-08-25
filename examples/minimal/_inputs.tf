# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED INPUTS
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
variable "tfe_oauth_token_id" {
  description = "ID representing the oAuth connection between GitHub and Terraform cloud. It is used by oStack for connecting Terraform Cloud workspaces to GitHub repos."
  type        = string
  validation {
    condition     = var.tfe_oauth_token_id != null && var.tfe_oauth_token_id != ""
    error_message = "You must specify a Terraform Cloud VCS token ID."
  }
}

variable "vcs_write_token" {
  description = <<-DESC
    VCS token with write access, per VCS provider.
    Used for updating commit statuses in GitOps and is also added as a secret to each repo for automerge.
    This behaviour can be overriden in `repo_secrets` in `vcs_config_base` or per repo in `namespaces`.
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
