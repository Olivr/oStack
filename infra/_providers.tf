terraform {
  required_version = "~> 1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "github" {
  owner = "Olivr"
  token = var.github_token
}
