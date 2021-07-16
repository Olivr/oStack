# The configuration repo is used to store files that should be synced to other repos but cannot be done inside of Terraform when branches are protected

# ---------------------------------------------------------------------------------------------------------------------
# Multi-providers
# ---------------------------------------------------------------------------------------------------------------------
# locals {
#   configuration_repo = lookup({
#     github = module.configuration_repo_github
#   }, var.vcs_provider)
# }

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Files to be added to the _configuration repo if some repos are protected
  protected_files = merge([for repo_id, config in local.repos_with_files :
    { for path, content in config.files :
      "${config.repo_name}/${path}" => content if config.branch_protection == true
    }
  ]...)
}
