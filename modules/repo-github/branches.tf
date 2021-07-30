# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  prepare_maintainers = lookup(var.team_permissions, "maintain", null) == null ? [] : var.team_permissions.maintain

  maintainers = [for team in local.prepare_maintainers : var.teams[team].node_id]
}

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "github_branch_protection" "branch" {
  count = var.branch_protection ? 1 : 0
  depends_on = [
    github_repository_file.files_strict,
    github_repository_file.files
  ]

  repository_id     = local.repo.node_id
  pattern           = local.repo.default_branch
  enforce_admins    = var.branch_protection_enforce_admins
  push_restrictions = local.maintainers

  # GitHub recreates the commits when rebase merging. As a result, any signed commit is not signed anymore
  # Keep to false to not break rebase merging until GitHub changes this behaviour
  # require_signed_commits = !var.repo_configuration.repo_allow_rebase_merge

  dynamic "required_status_checks" {
    for_each = length(var.branch_status_checks) > 0 ? [1] : []
    content {
      strict   = true
      contexts = var.branch_status_checks
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = var.branch_review_count > 0 ? [1] : []
    content {
      required_approving_review_count = var.branch_review_count
      require_code_owner_reviews      = true
      dismiss_stale_reviews           = true
      dismissal_restrictions          = local.maintainers
    }
  }
}
