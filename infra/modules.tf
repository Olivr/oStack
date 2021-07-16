locals {
  module_paths = distinct([for file in fileset("../modules", "[^.]**/*") : regex("[^/]+", file)])

  terraform_modules = { for path in local.module_paths :
    path => {
      repo   = path == "ostack" ? "terraform-github-oStack" : replace(path, "/^(.+)-([^-]+)$/", "terraform-$2-$1")
      source = path == "ostack" ? "Olivr/oStack/github" : replace(path, "/^(.+)-([^-]+)$/", "Olivr/$1/$2")
    }
  }
}

# Create repos for Terraform modules
module "terraform_modules" {
  source   = "../modules/repo-github"
  for_each = local.terraform_modules

  name         = each.value.repo
  auto_init    = false
  description  = "Mirror of https://github.com/Olivr/oStack/tree/main/modules/${each.key}"
  has_issues   = false
  has_projects = false
  has_wiki     = false
  homepage_url = "https://oStack.io"
  private      = false

  secrets = {
    copybara_ssh_key = null
    copybara_token   = null
  }

  sensitive_inputs = {
    copybara_ssh_key = tls_private_key.copybara_ssh_key.private_key_pem
    copybara_token   = var.github_token
  }
}
