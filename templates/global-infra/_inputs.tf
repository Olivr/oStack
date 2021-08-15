# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED INPUTS
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
# oStack
variable "github_write_token" {
  description = "Personal access token used for updating commit statuses in GitOps and is also added as a secret to each repo managed by oStack for automerge."
  type        = string
  validation {
    condition     = var.github_write_token != null && var.github_write_token != ""
    error_message = "You must specify a write token for GitHub."
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
