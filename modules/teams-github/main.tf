# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Set defaults
  default_team = {
    description = ""
    privacy     = "closed"
    members     = {}
  }

  # Teams that should be created
  parents = { for team_id, config in var.teams :
    team_id => defaults(config, local.default_team) if config != null
  }

  children = merge(flatten([for parent_team, parent_config in local.parents :
    { for team, config in parent_config.teams :
      team => merge(defaults(config, local.default_team), { parent = parent_team }) if config != null
    } if lookup(parent_config, "teams", {}) != {}
  ])...)

  grand_children = merge(flatten([for parent_team, parent_config in local.children :
    { for team, config in parent_config.teams :
      team => merge(defaults(config, local.default_team), { parent = parent_team }) if config != null
    } if lookup(parent_config, "teams", {}) != {}
  ])...)

  teams_created = merge(github_team.parents, github_team.children, github_team.grandchildren)

  # Users to be added to teams
  prepare_memberships = merge(flatten([for team_id, config in merge(local.parents, local.children, local.grand_children) :
    { for member in try(config.members, {}) :
      "${team_id}-${member.role}-${member.user}" => merge(
        member,
        { team_id = local.teams_created[team_id].id }
      )
    }
  ])...)

  # Process special values
  memberships = { for id, member in local.prepare_memberships :
    id => member.user != "data::current_user" ? member : merge(
      member,
      { user = data.github_user.current.login }
    )
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
# Create parent teams
resource "github_team" "parents" {
  for_each = local.parents

  name        = each.value.title
  description = each.value.description
  privacy     = each.value.privacy
}

# Create children teams
resource "github_team" "children" {
  for_each = local.children

  name           = each.value.title
  description    = each.value.description
  privacy        = each.value.privacy
  parent_team_id = github_team.parents[each.value.parent].id
}

# Create grand children teams
resource "github_team" "grandchildren" {
  for_each = local.grand_children

  name           = each.value.title
  description    = each.value.description
  privacy        = each.value.privacy
  parent_team_id = github_team.children[each.value.parent].id
}

# Add users to teams
resource "github_team_membership" "members" {
  for_each = local.memberships

  depends_on = [
    github_team.parents,
    github_team.children,
    github_team.grandchildren
  ]

  team_id  = each.value.team_id
  username = each.value.user
  role     = each.value.role
}

# Get current user
data "github_user" "current" {
  username = ""
}
