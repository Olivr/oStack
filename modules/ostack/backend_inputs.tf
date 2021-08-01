# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL INPUTS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
# Infrastructure backend
variable "backend_organization_name" {
  description = "Backend organization name."
  type        = string
  default     = null
}

variable "backend_default_provider" {
  description = "Default backend provider."
  type        = string
  default     = "tfe"

  validation {
    error_message = "Variable backend_default_provider cannot be null."
    condition     = var.backend_default_provider != null
  }

  validation {
    error_message = "You must specify a supported backend provider."
    condition     = contains(["tfe"], var.backend_default_provider)
  }
}

variable "backend_configuration_base" {
  description = "Base backend configuration per provider."
  default     = { tfe = {} }
  type = map(object({
    allow_destroy_plan    = optional(bool)
    separate_environments = optional(bool)
    env_vars              = optional(map(string))
    speculative_enabled   = optional(bool)
    tf_vars               = optional(map(string))
    tf_vars_hcl           = optional(map(string))
    tfe_oauth_token_id    = optional(string)
  }))

  validation {
    error_message = "Variable backend_configuration_base cannot be null."
    condition     = var.backend_configuration_base != null
  }

  validation {
    error_message = "You must specify only supported backend providers."
    condition = alltrue([for provider in keys(var.backend_configuration_base) :
      contains(["tfe"], provider)
    ])
  }

  validation {
    error_message = "You must specify tfe_oauth_token_id (VCS OAuth connection ID https://www.terraform.io/docs/cloud/vcs/index.html)."
    condition     = contains(keys(var.backend_configuration_base), "tfe") ? lookup(var.backend_configuration_base.tfe, "tfe_oauth_token_id", null) != null : true
  }

  validation {
    error_message = "Null values are not accepted for env_vars, tfvars, tf_vars_hcl. Use empty values instead."
    condition = alltrue(flatten(
      [for config in values(var.backend_configuration_base) :
        concat(
          [for v in try(values(config.env_vars), {}) : v != null],
          [for v in try(values(config.tf_vars), {}) : v != null],
          [for v in try(values(config.tf_vars_hcl), {}) : v != null]
        )
      ]
    ))
  }
}
