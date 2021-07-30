# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
# GitHub does not like empty files
locals {
  files_strict = { for k, v in var.files_strict :
    k => v == "" ? " " : v
  }
  files = { for k, v in var.files :
    k => v == "" ? " " : v
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "github_repository_file" "files_strict" {
  for_each   = local.files_strict
  depends_on = [github_actions_secret.secret]

  repository          = local.repo.name
  branch              = local.repo.default_branch
  file                = each.key
  content             = each.value
  overwrite_on_create = true
}

resource "github_repository_file" "files" {
  for_each   = local.files
  depends_on = [github_actions_secret.secret]

  repository          = local.repo.name
  branch              = local.repo.default_branch
  file                = each.key
  content             = each.value
  overwrite_on_create = true

  lifecycle {
    ignore_changes = all
  }
}
