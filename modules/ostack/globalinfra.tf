# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Static
  globalinfra_static = {
    name        = local.globalinfra_repo_name
    description = format(local.i18n.repo_global_infra_description, var.organization_title)
    vcs = merge(local.vcs_configuration[var.vcs_default_provider], {
      repo_exists = true
      team_configuration = {
        admin    = local.globalinfra_teams_admins
        maintain = local.globalinfra_teams_maintainers
        read     = local.globalinfra_teams_readers
        write    = local.globalinfra_teams_writers
      }
    })
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Static computations
# These are computable statically (without any resource created or any external data fetched)
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalinfra_teams_admins      = ["global_admin"]
  globalinfra_teams_maintainers = ["global_manager", "global_infra_lead"]
  globalinfra_teams_writers     = ["global_infra"]
  globalinfra_teams_readers = setsubtract(
    setunion(
      keys(local.global_teams.global.teams),
      keys(merge(values(local.namespace_teams).*.teams...))
    ),
    setunion(
      local.globalinfra_teams_admins,
      local.globalinfra_teams_maintainers,
      local.globalinfra_teams_writers
    )
  )
}
