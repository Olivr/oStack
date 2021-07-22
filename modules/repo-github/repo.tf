# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
# Unify attribute calls wether repo was created or fetched
locals {
  repo = {
    name           = var.name
    full_name      = var.repo_exists ? data.github_repository.repo[0].full_name : github_repository.repo[0].full_name
    html_url       = var.repo_exists ? data.github_repository.repo[0].html_url : github_repository.repo[0].html_url
    node_id        = var.repo_exists ? data.github_repository.repo[0].node_id : github_repository.repo[0].node_id
    default_branch = var.repo_exists ? data.github_repository.repo[0].default_branch : github_repository.repo[0].default_branch
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
# Fetch repository if it exists
data "github_repository" "repo" {
  count = var.repo_exists ? 1 : 0
  name  = var.name
}

# Create repository if it doesn't exist
resource "github_repository" "repo" {
  count = var.repo_exists ? 0 : 1

  name                   = var.name
  description            = var.description
  homepage_url           = var.homepage_url
  visibility             = try(var.private ? "private" : "public", "private")
  has_issues             = var.has_issues
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  is_template            = var.is_template
  allow_merge_commit     = var.allow_merge_commit
  allow_squash_merge     = var.allow_squash_merge
  allow_rebase_merge     = var.allow_rebase_merge
  auto_init              = var.auto_init
  archive_on_destroy     = var.archive_on_destroy
  topics                 = try([for v in var.topics : lower(replace(replace(v, "/[_ ]/", "-"), "/[^a-zA-Z0-9-]/", ""))], [])
  vulnerability_alerts   = var.vulnerability_alerts
  delete_branch_on_merge = var.branch_delete_on_merge

  dynamic "template" {
    for_each = var.template == null || var.template == "" ? [] : [1]
    content {
      owner      = split("/", var.template)[0]
      repository = split("/", var.template)[1]
    }
  }

  lifecycle {
    ignore_changes = [template]
  }
}
