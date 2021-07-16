locals {
  template_paths = distinct([for file in fileset("../templates", "[^.]**/*") : regex("[^/]+", file)])

  terraform_templates = { for path in local.template_paths :
    path => "ostack-${path}"
  }
}

# Create repos for Terraform modules
module "terraform_templates" {
  source   = "../modules/repo-github"
  for_each = local.terraform_templates

  name         = each.value
  auto_init    = false
  description  = "Mirror of https://github.com/Olivr/oStack/tree/main/templates/${each.key}"
  has_issues   = false
  has_projects = false
  has_wiki     = false
  homepage_url = "https://oStack.io"
  is_template  = true
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
