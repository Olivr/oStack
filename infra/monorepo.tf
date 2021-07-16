// Generate matrix used to sync folders to external repos
// .github/workflows/sync-repos.yaml

locals {
  modules_replace_common = concat(flatten([for path, config in local.terraform_modules : [
    "source = \\\"../${path}\\\"||source = \\\"${config.source}\\\"||**.tf",
    "../${path}||${config.source}||**.md"
    ]]), [
    "# version = \\\"||version = \\\"||**.tf"
  ])

  modules_replace_specific = {
    ostack = [
      "At 01:00 on Tuesday||At 01:00 on Wednesday||.github/workflows/prepare-release.yaml",
      "cron: \\\"0 1 * * 2\\\"||cron: \\\"0 1 * * 3\\\"||.github/workflows/prepare-release.yaml"
    ]
  }

  modules_replace = { for path, config in local.terraform_modules :
    path => concat([
      "%%module_path%%||${path}",
      "%%module_source%%||${config.source}"
      ],
      local.modules_replace_common,
      lookup(local.modules_replace_specific, path, []),
    )
  }

  // Order modules to execute oStack in last position
  ordered_modules_list = concat(tolist(setsubtract(keys(local.terraform_modules), ["ostack"])), ["ostack"])

  modules_matrix = jsonencode({
    include = [for path in local.ordered_modules_list :
      {
        path    = "modules/${path}",
        repo    = local.terraform_modules[path].repo
        replace = join("\n", lookup(local.modules_replace, path, []))
      }
    ]
  })

  templates_matrix = jsonencode({
    include = [for path, repo in local.terraform_templates :
      {
        path = "templates/${path}",
        repo = repo
      }
    ]
  })
}

// Maintain the monorepo
module "ostack_monorepo" {
  source = "../modules/repo-github"

  name                   = "oStack"
  archive_on_destroy     = true
  auto_init              = false
  branch_delete_on_merge = true
  branch_protection      = true
  branch_status_checks   = ["Run tests"]
  has_projects           = false
  has_wiki               = false
  homepage_url           = "https://oStack.io"
  private                = false

  secrets = {
    copybara_ssh_key = null
    copybara_token   = null
    modules_matrix   = replace(replace(local.modules_matrix, "\\", "\\\\"), "\"", "\\\"")
    templates_matrix = replace(local.templates_matrix, "\"", "\\\"")
  }

  sensitive_inputs = {
    copybara_ssh_key = tls_private_key.copybara_ssh_key.private_key_pem
    copybara_token   = var.github_token
  }
}
