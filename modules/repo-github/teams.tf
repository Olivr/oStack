# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  teams_to_create = merge([for permission, teams in var.team_permissions :
    { for team in teams :
      format("%s_%s", team, permission) => {
        team       = team
        permission = permission
      }
    } if try(length(teams), 0) > 0
  ]...)
}

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "github_team_repository" "permissions" {
  for_each = local.teams_to_create

  repository = local.repo.name
  team_id    = var.teams[each.value.team].id
  permission = each.value.permission
}
