# ---------------------------------------------------------------------------------------------------------------------
# English language (also used as the fallback language)
# ---------------------------------------------------------------------------------------------------------------------
locals {
  i18n_en = {
    file_template_header_1             = "This file is managed automatically by oStack"
    file_template_header_2             = "Most likely, you do not want to edit it manually"
    ns_description                     = "%s namespace"
    repo_apps_description              = "%s applications"
    repo_global_ops_name               = "global-ops"
    repo_global_ops_description        = "Cluster management"
    repo_global_config_name            = "global-config"
    repo_global_config_description     = "oStack-managed configuration repository. Not for human eyes."
    repo_global_infra_description      = "%s global infrastructure (Manage oStack)."
    repo_infra_description             = "%s infrastructure"
    repo_ops_description               = "%s application deployments"
    tag_apps_buzz                      = "DevOps"
    tag_apps_proper                    = "Applications"
    tag_infra_buzz                     = "IaC"
    tag_infra_proper                   = "Infrastructure"
    tag_ops_buzz                       = "GitOps"
    tag_ops_proper                     = "Operations"
    team_global_admin_description      = "Full access to all repositories across all namespaces, including sensitive and destructive actions like managing security or deleting a repository"
    team_global_admin_name             = "Administrators"
    team_global_apps_description       = "Push to application repositories across all namespaces"
    team_global_apps_lead_description  = "Manage application repositories across all namespaces"
    team_global_apps_lead_name         = "Lead App Developers"
    team_global_apps_name              = "App Developers"
    team_global_description            = "Teams with permissions across all namespaces"
    team_global_infra_description      = "Make changes to global and namespace-specific infrastructure"
    team_global_infra_lead_description = "Sign-off changes to global and namespace-specific infrastructure"
    team_global_infra_lead_name        = "Lead Infrastructure Engineers"
    team_global_infra_name             = "Infrastructure Engineers"
    team_global_manager_description    = "Manage all repositories across all namespaces without access to sensitive or destructive actions"
    team_global_manager_name           = "Project Managers"
    team_global_name                   = "- Global -"
    team_global_ops_description        = "Manage application deployments across all namespaces"
    team_global_ops_env_description    = "Sign-off changes to %s application deployments across all namespaces"
    team_global_ops_env_name           = "%s Operations Managers"
    team_global_ops_name               = "Operations Managers"
    team_ns_apps_description           = "Push code to %s's applications repository"
    team_ns_apps_lead_description      = "Manage %s's applications repository"
    team_ns_apps_lead_name             = "%s Lead App Developers"
    team_ns_apps_name                  = "%s App Developers"
    team_ns_description                = "Teams specific to the %s namespace"
    team_ns_infra_description          = "Make changes to %s's infrastructure"
    team_ns_infra_lead_description     = "Sign-off changes to %s's infrastructure"
    team_ns_infra_lead_name            = "%s Lead Infrastructure Engineers"
    team_ns_infra_name                 = "%s Infrastructure Engineers"
    team_ns_manager_description        = "Manage all %s's repositories without access to sensitive or destructive actions"
    team_ns_manager_name               = "%s Project Managers"
    team_ns_name                       = "%s"
    team_ns_ops_description            = "Manage %s's application deployments"
    team_ns_ops_env_description        = "Sign-off changes to %s %s application deployments"
    team_ns_ops_env_name               = "%s %s Operations Managers"
    team_ns_ops_name                   = "%s Operations Managers"
  }
}
