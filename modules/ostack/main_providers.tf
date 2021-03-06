# ---------------------------------------------------------------------------------------------------------------------
# Providers
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  experiments = [module_variable_optional_attrs]

  required_version = "~> 1.0"

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
    gpg = {
      source  = "Olivr/gpg"
      version = "~> 0.1.0"
    }
  }
}
