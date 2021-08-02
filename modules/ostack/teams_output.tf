# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "teams_flat" {
  description = "Teams created, per provider in flat format."
  value       = lookup(local.dev, "disable_outputs", false) ? {} : local.teams_outputs_flat
}

output "teams_tree" {
  description = "Teams created, per provider in hierarchical format."
  value       = lookup(local.dev, "disable_outputs", false) ? {} : local.teams_outputs_tree
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  teams_outputs_flat_prepare = merge(flatten(
    [for parent_id, parent in local.teams :
      concat(
        [
          {
            (parent_id) = {
              title       = parent.title
              description = parent.description
              members     = lookup(parent, "members", [])
              children    = keys(lookup(parent, "teams", {}))
              parent      = null
            }
          }
        ],
        [for child_id, child in lookup(parent, "teams", {}) :
          concat(
            [
              {
                (child_id) = {
                  title       = child.title
                  description = child.description
                  members     = lookup(child, "members", [])
                  children    = keys(lookup(child, "teams", {}))
                  parent      = parent_id
                }
              }
            ],
            [for grand_child_id, grand_child in lookup(child, "teams", {}) :
              {
                (grand_child_id) = {
                  title       = grand_child.title
                  description = grand_child.description
                  members     = lookup(grand_child, "members", [])
                  children    = []
                  parent      = child_id
                }
              }
            ]
          )
        ]
      )
    ]
  )...)

  teams_outputs_flat = { for provider in keys(local.vcs_teams) :
    provider => { for team_id, team in local.teams_outputs_flat_prepare :
      team_id => merge(
        team,
        local.vcs_teams[provider].teams[team_id]
      )
    }
  }

  teams_outputs_tree = { for provider in keys(local.vcs_teams) :
    provider => { for parent_id, parent in local.teams :
      parent_id => merge(
        parent,
        local.vcs_teams[provider].teams[parent_id],
        { for child_id, child in lookup(parent, "teams", {}) :
          child_id => merge(
            child,
            local.vcs_teams[provider].teams[child_id],
            { for grand_child_id, grand_child in lookup(child, "teams", {}) :
              grand_child_id => merge(
                grand_child,
                local.vcs_teams[provider].teams[grand_child_id]
              )
            }
          )
        }
      )
    }
  }
}
