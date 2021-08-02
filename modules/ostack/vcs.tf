# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  vcs_teams = merge(
    module.vcs_teams_github
  )

  vcs_repos_namespaces = merge(
    module.vcs_repos_namespaces_github
  )

  # The global configuration repo is used to store files that cannot be committed to other repos due to branch protection
  vcs_repo_globalconfig = merge(
    module.vcs_repo_globalconfig_github
  )

  # The global ops repo is used to manage the clusters global configuration
  vcs_repo_globalops = merge(
    module.vcs_repo_globalops_github
  )["globalops"]
}

# ---------------------------------------------------------------------------------------------------------------------
# Multi-providers
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Github
  vcs_repo_globalops_github    = var.vcs_default_provider == "github" ? toset(["globalops"]) : toset([])
  vcs_repo_globalinfra_github  = var.vcs_default_provider == "github" ? toset(compact([local.globalinfra_repo_name])) : toset([])
  vcs_repo_globalconfig_github = contains(keys(local.globalconfig), "github") ? { github = local.globalconfig["github"] } : {}
  vcs_teams_github             = contains(local.vcs_providers_in_use, "github") ? { github = local.teams_static } : {}
  vcs_repos_namespaces_github = { for id, repo in local.namespaces_repos_static :
    id => repo if repo.vcs.provider == "github"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Static computations
# These are computable statically (without any resource created or any external data fetched)
# ---------------------------------------------------------------------------------------------------------------------
locals {
  vcs_providers_in_use = distinct(flatten([
    local.globalops_static.vcs.provider,
    [for repo in values(local.namespaces_repos_static) : repo.vcs.provider]
  ]))
}
