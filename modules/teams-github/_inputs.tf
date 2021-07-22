# ---------------------------------------------------------------------------------------------------------------------
# Required inputs
# These parameters must be specified.
# ---------------------------------------------------------------------------------------------------------------------
variable "teams" {
  description = "GitHub teams and their configuration. You can use the special value `data::current_user` in the `user` field to add the current GitHub user to a team."
  type = map(object({
    title       = string
    description = optional(string)
    privacy     = optional(string)
    teams = optional(map(object({
      title       = string
      description = optional(string)
      privacy     = optional(string)
      teams = optional(map(object({
        title       = string
        description = optional(string)
        privacy     = optional(string)
        members = optional(set(object({
          user = string,
          role = string
        })))
      })))
      members = optional(set(object({
        user = string,
        role = string
      })))
    })))
    members = optional(set(object({
      user = string,
      role = string
    })))
  }))
}
