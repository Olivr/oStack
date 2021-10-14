# Add some secrets to all repos / backends
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
  organization_name      = ""
  cloud_default_provider = ""
  vcs_write_token        = var.vcs_write_token

  # ---------------------------------------------------------------------------------------------------------------------
  # OPTIONAL INPUTS
  # oStack provide reasonable defaults for these parameters.
  # ---------------------------------------------------------------------------------------------------------------------
  vcs_config_base = {
    github = {
      # Set to false to make it more convenient to experiment with oStack
      # Set back to true or delete this line/block for the long term
      repo_archive_on_destroy = true

      repo_secrets = {
        my_secret       = "I am a secret"
        my_other_secret = "sensitive::my_secret_input"
      }
    }
  }

  backend_config_base = {
    tfe = {
      tfe_oauth_token_id = var.tfe_oauth_token_id

      tf_vars = {
        my_backend_secret       = "I am a secret"
        my_other_backend_secret = "sensitive::my_secret_input"
      }
    }
  }

  sensitive_inputs = var.sensitive_inputs
  # Example values passed to var.sensitive_inputs
  # {
  #   my_secret_input = "This is a sensitive value"
  # }
}
