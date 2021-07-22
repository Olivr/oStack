# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "github_repository_file" "strict_files" {
  for_each = var.strict_files

  repository          = local.repo.name
  branch              = local.repo.default_branch
  file                = each.key
  content             = each.value
  overwrite_on_create = true
}

resource "github_repository_file" "files" {
  for_each = var.files

  repository          = local.repo.name
  branch              = local.repo.default_branch
  file                = each.key
  content             = each.value
  overwrite_on_create = true

  lifecycle {
    ignore_changes = all
  }
}
