# Configure oStack to create one folder/backend for all environments instead of being separate
# Do not forget to add the files in ./common to use this configuration as is

# ---------------------------------------------------------------------------------------------------------------------
# oStack configuration
# ---------------------------------------------------------------------------------------------------------------------
module "oStack" {
  source  = "Olivr/oStack/oStack"
  version = "~> 1.0.0"

  # ---------------------------------------------------------------------------------------------------------------------
  # REQUIRED INPUTS
  # These parameters must be specified.
  # ---------------------------------------------------------------------------------------------------------------------
  organization_name      = var.organization_name
  cloud_default_provider = var.cloud_default_provider
  vcs_write_token        = var.vcs_write_token

  # ---------------------------------------------------------------------------------------------------------------------
  # OPTIONAL INPUTS
  # oStack provide reasonable defaults for these parameters.
  # ---------------------------------------------------------------------------------------------------------------------
  vcs_configuration_base = {
    github = {
      # Set to false to make it more convenient to experiment with oStack
      # Set back to true or delete this line/block for the long term
      repo_archive_on_destroy = true
    }
  }

  backend_configuration_base = {
    tfe = {
      separate_environments = false
      tfe_oauth_token_id    = var.tfe_oauth_token_id
    }
  }
}
