# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "github_issue_label" "labels" {
  for_each = var.issue_labels

  repository = local.repo.name
  name       = each.key
  color      = trimprefix(each.value, "#")
}
