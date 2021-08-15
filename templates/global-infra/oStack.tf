# This template contains the most common options for getting started with oStack

module "ostack" {
  source  = "Olivr/oStack/oStack"
  version = "~> 1.0.0"

  # ---------------------------------------------------------------------------------------------------------------------
  # General configuration
  # These parameters span across to the whole stack
  # ---------------------------------------------------------------------------------------------------------------------

  # Computer-friendly organization name (eg. my-startup).
  # Use only letters, numbers and dashes to maximize compatibility across every system.
  organization_name = ""

  # Default cloud provider.
  # Use "linode" or "digitalocean"
  cloud_default_provider = ""

  # Namespaces and their optional configuration.
  # A namespace can be a project or a group of projects (if using a monorepo structure).
  # If you want to later rename your namespaces, do not change the key name or Terraform will destroy it and create a new one from scratch which will have dramatic effects on your repos.
  # For this reason, it is recommended to use generic key names such as ns1, ns2.
  # By default a main namespace will be created with a typical repo structure (infra/apps/ops).
  # namespaces = {
  #   ns1 = {
  #     title = "Main"
  #     repos = {
  #       apps  = { type = "apps" }
  #       infra = { type = "infra" }
  #       ops   = { type = "ops" }
  #     }
  #   }
  # }

  # Environment names and their optional configuration.
  # Each environment contains one or more Kubernetes clusters.
  # If you want to later rename your environments, do not change the key name or Terraform will destroy it and create a new one from scratch which will have dramatic effects on your deployments.
  # For this reason, it is recommended to use generic key names for both environments and clusters, you can name both by using the `name` parameter.
  # By default a staging environment is created with one cluster using the default cluster configuration on your default cloud provider
  # environments = {
  #   stage = {
  #     name = "staging"
  #     clusters = {
  #       cluster1 = {}
  #     }
  #   }
  # }

  # ---------------------------------------------------------------------------------------------------------------------
  # VCS configuration
  # These parameters configure your VCS providers
  # ---------------------------------------------------------------------------------------------------------------------

  # VCS organization name.
  # Default is the value from organization_name
  # vcs_organization_name = "my-organization"

  # Base VCS configuration per provider.
  vcs_config_base = {
    github = {
      # Enable branch protection for all repos
      # Default is true
      # branch_protection = true

      # Make all repos private
      # Default is true
      # repo_private = true

      # Repos should be archived instead of deleted
      # This is presently set to false to make it more convenient to experiment with oStack but should be set back to true for the long term
      # Default is true
      repo_archive_on_destroy = false
    }
  }

  # VCS token with write access, per VCS provider.
  # Used for updating commit statuses in GitOps and is also added as a secret to each repo for automerge.
  # This behaviour can be overriden in `repo_secrets` in `vcs_config_base` or per repo in `namespaces`.
  vcs_write_token = {
    github = var.github_write_token
  }

  # ---------------------------------------------------------------------------------------------------------------------
  # Backend configuration
  # These parameters configure your (infrastructure) backend providers
  # ---------------------------------------------------------------------------------------------------------------------

  # Backend organization name.
  # Default is the value from organization_name
  # backend_organization_name = "my-organization"

  # Base backend configuration per provider.
  backend_config_base = {
    tfe = {
      tfe_oauth_token_id = var.tfe_oauth_token_id

      # Manage infrastructure for each environment in a separate folder / backend (might be overkill in some use cases)
      # Default is true
      # separate_environments = true
    }
  }

  # Name of the global infra repo so that oStack can apply its settings to it (eg. branch protection, team access)
  # It must be created already on the default VCS provider.
  # Set to `null` if you don't want oStack to manage this repo at all.
  # Default is null
  globalinfra_vcs_repo_name = "global-infra"

  # Name of the global infra backend workspace name so that oStack can propagate backend runs.
  # This is used because Terraform Cloud won't trigger a run when variables values change, but oStack needs to in order to keep the configuration up to date!
  # It must be created already on the default backend provider.
  # Set to `null` if you don't want runs to propagate.
  # Default is null
  globalinfra_backend_workspace_name = "global-infra"
}
