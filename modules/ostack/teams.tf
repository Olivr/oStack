# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  teams = merge(
    local.global_teams,
    local.namespace_teams
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------------------------------------------------
# Global teams
locals {
  teams_prefix = var.prefix != "" ? "${var.prefix} " : ""
  global_teams = {
    global = {
      title       = "${local.teams_prefix}${local.i18n.team_global_name}"
      description = local.i18n.team_global_description
      teams = {
        global_admin = {
          title       = "${local.teams_prefix}${local.i18n.team_global_admin_name}"
          description = local.i18n.team_global_admin_description
          members     = [{ user = "data::current_user", role = "maintainer" }]
        },
        global_manager = {
          title       = "${local.teams_prefix}${local.i18n.team_global_manager_name}"
          description = local.i18n.team_global_manager_description
        },
        global_infra = {
          title       = "${local.teams_prefix}${local.i18n.team_global_infra_name}"
          description = local.i18n.team_global_infra_description
          teams = {
            global_infra_lead = {
              title       = "${local.teams_prefix}${local.i18n.team_global_infra_lead_name}"
              description = local.i18n.team_global_infra_lead_description
            }
          }
        },
        global_ops = {
          title       = "${local.teams_prefix}${local.i18n.team_global_ops_name}"
          description = local.i18n.team_global_ops_description
          teams = { for id, settings in local.environments : "global_ops_${id}" => {
            title       = format(local.i18n.team_global_ops_env_name, "${local.teams_prefix}${title(settings.name)}")
            description = format(local.i18n.team_global_ops_env_description, title(settings.name))
          } }
        },
        global_apps = {
          title       = "${local.teams_prefix}${local.i18n.team_global_apps_name}"
          description = local.i18n.team_global_apps_description
          teams = {
            global_apps_lead = {
              title       = "${local.teams_prefix}${local.i18n.team_global_apps_lead_name}"
              description = local.i18n.team_global_apps_lead_description
            }
          }
        },
      }
    },
  }

  # Namespace-specific teams
  namespace_teams = merge([for id, config in local.namespaces :
    {
      "${id}" = {
        title       = format(local.i18n.team_ns_name, "${local.teams_prefix}${config.title}")
        description = format(local.i18n.team_ns_description, config.title)
        teams = {
          "${id}_manager" = {
            title       = format(local.i18n.team_ns_manager_name, "${local.teams_prefix}${config.title}")
            description = format(local.i18n.team_ns_manager_description, config.title)
          },
          "${id}_infra" = {
            title       = format(local.i18n.team_ns_infra_name, "${local.teams_prefix}${config.title}")
            description = format(local.i18n.team_ns_infra_description, config.title)
            teams = {
              "${id}_infra_lead" = {
                title       = format(local.i18n.team_ns_infra_lead_name, "${local.teams_prefix}${config.title}")
                description = format(local.i18n.team_ns_infra_lead_description, config.title)
              }
            }
          },
          "${id}_ops" = {
            title       = format(local.i18n.team_ns_ops_name, "${local.teams_prefix}${config.title}")
            description = format(local.i18n.team_ns_ops_description, config.title)
            teams = { for env_id, env in local.environments : "${id}_ops_${env_id}" => {
              title       = format(local.i18n.team_ns_ops_env_name, "${local.teams_prefix}${config.title}", env.name)
              description = format(local.i18n.team_ns_ops_env_description, config.title, env.name)
              }
            }
          },
          "${id}_apps" = {
            title       = format(local.i18n.team_ns_apps_name, "${local.teams_prefix}${config.title}")
            description = format(local.i18n.team_ns_apps_description, config.title)
            teams = {
              "${id}_apps_lead" = {
                title       = format(local.i18n.team_ns_apps_lead_name, "${local.teams_prefix}${config.title}")
                description = format(local.i18n.team_ns_apps_lead_description, config.title)
              }
            }
          },
        }
      },

    }
  ]...)
}
