##
# Integration tests
# https://www.terraform.io/docs/language/modules/testing-experiment.html
##

variable "name" {
  description = "ID representing the oAuth connection between GitHub and Terraform cloud. It is used by oStack for connecting Terraform Cloud workspaces to GitHub repos."
  type        = string
  validation {
    condition     = var.name != null && var.name != ""
    error_message = "You must specify a Terraform Cloud VCS token ID."
  }
}

##
# Setup
##
terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

##
# Randomizers
##
resource "random_pet" "name" {}



##
# Tests
##
# resource "test_assertions" "kube_version" {
#   depends_on = [module.main]

#   component = "kube_version"

#   equal "linode_version" {
#     description = "default kubernetes version is 1.21"
#     got         = module.main.kube_version
#     want        = "1.21"
#   }

#   equal "server_version" {
#     description = "default kubernetes version is 1.21"
#     got         = data.kubectl_server_version.current.version
#     want        = "1.21"
#   }
# }
