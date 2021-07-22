# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  prepare_maintainers = lookup(var.team_permissions, "maintain", null) == null ? [] : var.team_permissions.maintain

  # Add current user to maintainers when there are files to commit so it can push them
  maintainers = setunion(
    [for team in local.prepare_maintainers : var.teams[team].node_id],
    length(var.files) > 1 || length(var.strict_files) > 1 ? [data.github_user.current.node_id] : []
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "github_branch_protection" "branch" {
  count = var.branch_protection ? 1 : 0

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

# Detect current user.
data "github_user" "current" {
  username = ""
}
