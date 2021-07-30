# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL INPUTS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "namespaces" {
  description = "Namespaces and their optional configuration. \nA namespace can be a project or a group of projects (if using a monorepo structure).\nBy default a namespace bearing the same name as your organization will be created. \nIf you want to later rename your namespaces, do not change the key name or Terraform will destroy it and create a new one from scratch. As such it is recommended to use generic key names such as ns1, ns2."
  type = map(object({
    title        = string
    name         = optional(string)
    description  = optional(string)
    environments = optional(list(string))
    repos = map(object({
      type                = string
      name                = optional(string)
      description         = optional(string)
      continuous_delivery = optional(bool)
      backend = optional(object({
        create               = optional(bool)
        provider             = optional(string)
        allow_destroy_plan   = optional(bool)
        combine_environments = optional(bool)
        description          = optional(string)
        env_vars             = optional(map(string))
        speculative_enabled  = optional(bool)
        tf_vars              = optional(map(string))
        tf_vars_hcl          = optional(map(string))
        tfe_oauth_token_id   = optional(string)
      }))
      vcs = optional(object({
        branch_default_name              = optional(string)
        branch_delete_on_merge           = optional(bool)
        branch_protection                = optional(bool)
        branch_protection_enforce_admins = optional(bool)
        branch_review_count              = optional(number)
        branch_status_checks             = optional(list(string))
        create                           = optional(bool)
        file_templates                   = optional(map(string))
        files                            = optional(map(string))
        provider                         = optional(string)
        repo_allow_merge_commit          = optional(bool)
        repo_allow_rebase_merge          = optional(bool)
        repo_allow_squash_merge          = optional(bool)
        repo_archive_on_destroy          = optional(bool)
        repo_auto_init                   = optional(bool)
        repo_enable_issues               = optional(bool)
        repo_enable_projects             = optional(bool)
        repo_enable_wikis                = optional(bool)
        repo_homepage_url                = optional(string)
        repo_is_template                 = optional(bool)
        repo_issue_labels                = optional(map(string))
        repo_private                     = optional(bool)
        repo_secrets                     = optional(map(string))
        repo_template                    = optional(string)
        repo_vulnerability_alerts        = optional(bool)
        tags                             = optional(set(string))
      }))
    }))
  }))

  default = {
    ns1 = {
      title = "Main"
      repos = {
        apps  = { type = "apps" }
        infra = { type = "infra" }
        ops   = { type = "ops" }
      }
    }
  }

  validation {
    error_message = "You must specify at least one namespace."
    condition     = var.namespaces != null && try(length(keys(var.namespaces)), 0) != 0
  }

  validation {
    error_message = "Null values are not accepted for env_vars, tfvars, tf_vars_hcl. Use empty values instead."
    condition = alltrue(flatten(
      [for namespace in values(var.namespaces) :
        [for repo in try(values(namespace.repos), {}) :
          concat(
            [for v in try(values(repo.backend.env_vars), {}) : v != null],
            [for v in try(values(repo.backend.tf_vars), {}) : v != null],
            [for v in try(values(repo.backend.tf_vars_hcl), {}) : v != null]
          )
        ]
      ]
    ))
  }

  validation {
    error_message = "Null values are not accepted for repo_secrets. Use empty values instead."
    condition = alltrue(flatten(
      [for namespace in values(var.namespaces) :
        [for repo in try(values(namespace.repos), {}) :
          [for v in try(values(repo.vcs.repo_secrets), {}) : v != null]
        ]
      ]
    ))
  }

  validation {
    error_message = "Supported repo types are apps, infra, ops."
    condition = alltrue(flatten(
      [for namespace in values(var.namespaces) :
        [for repo in try(values(namespace.repos), {}) :
          repo.type != null && contains(["apps", "infra", "ops"], repo.type)
        ]
      ]
    ))
  }

  validation {
    error_message = "Repo names must only contain alphanumeric characters. It may contain '-' but cannot start or finish with it."
    condition = alltrue(flatten(
      [for namespace in values(var.namespaces) :
        [for repo in try(values(namespace.repos), {}) :
          lookup(repo, "name", null) != null ? can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?([a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])?)*$", repo.name)) : true
        ]
      ]
    ))
  }

  validation {
    error_message = "Namespace names must only contain alphanumeric characters. It may contain '-' but cannot start or finish with it."
    condition = alltrue(flatten(
      [for namespace in values(var.namespaces) :
        lookup(namespace, "name", null) != null ? can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?([a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])?)*$", namespace.name)) : true
      ]
    ))
  }
}