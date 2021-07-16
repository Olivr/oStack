# Generate "deploy key" to be used by Copybara
resource "tls_private_key" "copybara_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Add the key to user profile
resource "github_user_ssh_key" "copybara_ssh_key" {
  title = "Generated from oStack monorepo"
  key   = tls_private_key.copybara_ssh_key.public_key_openssh
}


# Generate colors for issue labels
locals {
  modules_labels   = [for key in keys(local.terraform_modules) : "modules/${key}"]
  templates_labels = [for key in keys(local.terraform_templates) : "templates/${key}"]
  sub_repos        = setunion(local.modules_labels, local.templates_labels)
  issue_labels = { for key in local.sub_repos :
    key => resource.random_id.colors[key].hex
  }
}

resource "random_id" "colors" {
  for_each    = local.sub_repos
  byte_length = 3
}
