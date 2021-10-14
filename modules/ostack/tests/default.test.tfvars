# ---------------------------------------------------------------------------------------------------------------------
# This test file configures required inputs with sensible values
# ---------------------------------------------------------------------------------------------------------------------
organization_name      = "my-organization"
cloud_default_provider = "linode"
vcs_write_token = {
  github = "xxx"
}
backend_config_base = {
  tfe = {
    tfe_oauth_token_id = "xxx"
  }
}
