# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
module "vcs_teams_github" {
  source = "../teams-github"

  for_each = local.vcs_teams_github

  teams = local.teams_static
}

module "vcs_repos_namespaces_github" {
  source = "../repo-github"

  for_each = local.vcs_repos_namespaces_github

  allow_merge_commit               = each.value.vcs.repo_allow_merge_commit
  allow_rebase_merge               = each.value.vcs.repo_allow_rebase_merge
  allow_squash_merge               = each.value.vcs.repo_allow_squash_merge
  archive_on_destroy               = each.value.vcs.repo_archive_on_destroy
  auto_init                        = each.value.vcs.repo_auto_init
  branch_delete_on_merge           = each.value.vcs.branch_delete_on_merge
  branch_protection                = each.value.vcs.branch_protection
  branch_protection_enforce_admins = each.value.vcs.branch_protection_enforce_admins
  branch_review_count              = each.value.vcs.branch_review_count
  branch_status_checks             = each.value.vcs.branch_status_checks
  deploy_keys                      = local.namespaces_repos_dynamic[each.key].vcs.deploy_keys
  description                      = each.value.description
  files                            = local.namespaces_repos_dynamic[each.key].vcs.files
  files_strict                     = local.namespaces_repos_dynamic[each.key].vcs.files_strict
  has_issues                       = each.value.vcs.repo_enable_issues
  has_projects                     = each.value.vcs.repo_enable_projects
  has_wiki                         = each.value.vcs.repo_enable_wikis
  homepage_url                     = each.value.vcs.repo_homepage_url
  is_template                      = each.value.vcs.repo_is_template
  issue_labels                     = each.value.vcs.repo_issue_labels
  name                             = each.value.name
  private                          = each.value.vcs.repo_private
  repo_exists                      = !each.value.vcs.create
  secrets                          = each.value.vcs.repo_secrets
  sensitive_inputs                 = each.value.vcs.sensitive_inputs
  teams                            = module.vcs_teams_github["github"].teams
  template                         = each.value.vcs.repo_template
  topics                           = each.value.vcs.tags
  vulnerability_alerts             = each.value.vcs.repo_vulnerability_alerts
  team_permissions = {
    admin    = each.value.vcs.team_configuration.admin
    maintain = each.value.vcs.team_configuration.maintain
    pull     = each.value.vcs.team_configuration.read
    push     = each.value.vcs.team_configuration.write
    triage   = []
  }
}

module "vcs_repo_globalops_github" {
  source = "../repo-github"

  for_each = local.vcs_repo_globalops_github

  allow_merge_commit               = local.globalops_static.vcs.repo_allow_merge_commit
  allow_rebase_merge               = local.globalops_static.vcs.repo_allow_rebase_merge
  allow_squash_merge               = local.globalops_static.vcs.repo_allow_squash_merge
  archive_on_destroy               = local.globalops_static.vcs.repo_archive_on_destroy
  auto_init                        = local.globalops_static.vcs.repo_auto_init
  branch_delete_on_merge           = local.globalops_static.vcs.branch_delete_on_merge
  branch_protection                = local.globalops_static.vcs.branch_protection
  branch_protection_enforce_admins = local.globalops_static.vcs.branch_protection_enforce_admins
  branch_review_count              = local.globalops_static.vcs.branch_review_count
  branch_status_checks             = local.globalops_static.vcs.branch_status_checks
  deploy_keys                      = local.globalops_dynamic.vcs.deploy_keys
  description                      = local.globalops_static.description
  files                            = local.globalops_dynamic.vcs.files
  files_strict                     = local.globalops_dynamic.vcs.files_strict
  has_issues                       = local.globalops_static.vcs.repo_enable_issues
  has_projects                     = local.globalops_static.vcs.repo_enable_projects
  has_wiki                         = local.globalops_static.vcs.repo_enable_wikis
  homepage_url                     = local.globalops_static.vcs.repo_homepage_url
  is_template                      = local.globalops_static.vcs.repo_is_template
  issue_labels                     = local.globalops_static.vcs.repo_issue_labels
  name                             = local.globalops_static.name
  private                          = local.globalops_static.vcs.repo_private
  secrets                          = local.globalops_dynamic.vcs.repo_secrets
  sensitive_inputs                 = local.globalops_dynamic.vcs.sensitive_inputs
  teams                            = module.vcs_teams_github["github"].teams
  template                         = local.globalops_static.vcs.repo_template
  topics                           = local.globalops_static.vcs.tags
  vulnerability_alerts             = local.globalops_static.vcs.repo_vulnerability_alerts
  team_permissions = {
    admin    = local.globalops_static.vcs.team_configuration.admin
    maintain = local.globalops_static.vcs.team_configuration.maintain
    pull     = local.globalops_static.vcs.team_configuration.read
    push     = local.globalops_static.vcs.team_configuration.write
    triage   = []
  }
}

module "vcs_repo_globalconfig_github" {
  source = "../repo-github"

  for_each = local.vcs_repo_globalconfig_github
  depends_on = [
    module.vcs_repo_globalops_github,
    module.vcs_repos_namespaces_github,
    local.backends_namespaces,
    local.backends_globalops
  ]

  allow_merge_commit               = each.value.vcs.repo_allow_merge_commit
  allow_rebase_merge               = each.value.vcs.repo_allow_rebase_merge
  allow_squash_merge               = each.value.vcs.repo_allow_squash_merge
  archive_on_destroy               = each.value.vcs.repo_archive_on_destroy
  auto_init                        = each.value.vcs.repo_auto_init
  branch_delete_on_merge           = each.value.vcs.branch_delete_on_merge
  branch_protection                = each.value.vcs.branch_protection
  branch_protection_enforce_admins = each.value.vcs.branch_protection_enforce_admins
  branch_review_count              = each.value.vcs.branch_review_count
  branch_status_checks             = each.value.vcs.branch_status_checks
  deploy_keys                      = each.value.vcs.deploy_keys
  description                      = each.value.description
  files                            = local.globalconfig_dynamic[each.key].vcs.files
  files_strict                     = local.globalconfig_dynamic[each.key].vcs.files_strict
  has_issues                       = each.value.vcs.repo_enable_issues
  has_projects                     = each.value.vcs.repo_enable_projects
  has_wiki                         = each.value.vcs.repo_enable_wikis
  homepage_url                     = each.value.vcs.repo_homepage_url
  is_template                      = each.value.vcs.repo_is_template
  issue_labels                     = each.value.vcs.repo_issue_labels
  name                             = each.value.name
  private                          = each.value.vcs.repo_private
  secrets                          = each.value.vcs.repo_secrets
  sensitive_inputs                 = each.value.vcs.sensitive_inputs
  teams                            = module.vcs_teams_github["github"].teams
  template                         = each.value.vcs.repo_template
  topics                           = each.value.vcs.tags
  vulnerability_alerts             = each.value.vcs.repo_vulnerability_alerts
  team_permissions = {
    admin    = each.value.vcs.team_configuration.admin
    maintain = each.value.vcs.team_configuration.maintain
    pull     = each.value.vcs.team_configuration.read
    push     = each.value.vcs.team_configuration.write
    triage   = []
  }
}
