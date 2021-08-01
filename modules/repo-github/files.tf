# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
# GitHub does not like empty files, so make sure no file is empty
locals {
  files_strict = { for file_path, file_content in var.files_strict :
    file_path => file_content == "" ? " " : file_content if !(var.dotfiles_first && can(regex("^\\.", file_path)))
  }
  files = { for file_path, file_content in var.files :
    file_path => file_content == "" ? " " : file_content if !(var.dotfiles_first && can(regex("^\\.", file_path)))
  }
  dotfiles_strict = { for file_path, file_content in var.files_strict :
    file_path => file_content == "" ? " " : file_content if var.dotfiles_first && can(regex("^\\.", file_path))
  }
  dotfiles = { for file_path, file_content in var.files :
    file_path => file_content == "" ? " " : file_content if var.dotfiles_first && can(regex("^\\.", file_path))
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "github_repository_file" "dotfiles_strict" {
  for_each = local.dotfiles_strict

  repository          = local.repo.name
  branch              = local.repo.default_branch
  file                = each.key
  content             = each.value
  overwrite_on_create = true
}

resource "github_repository_file" "dotfiles" {
  for_each = local.dotfiles

  repository          = local.repo.name
  branch              = local.repo.default_branch
  file                = each.key
  content             = each.value
  overwrite_on_create = true

  lifecycle {
    ignore_changes = all
  }
}

resource "github_repository_file" "files_strict" {
  for_each = local.files_strict
  depends_on = [
    github_actions_secret.secret,
    github_repository_file.dotfiles_strict
  ]

  repository          = local.repo.name
  branch              = local.repo.default_branch
  file                = each.key
  content             = each.value
  overwrite_on_create = true
}

resource "github_repository_file" "files" {
  for_each = local.files
  depends_on = [github_actions_secret.secret,
    github_repository_file.dotfiles
  ]

  repository          = local.repo.name
  branch              = local.repo.default_branch
  file                = each.key
  content             = each.value
  overwrite_on_create = true

  lifecycle {
    ignore_changes = all
  }
}
