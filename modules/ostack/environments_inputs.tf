# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL INPUTS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "environments" {
  description = <<-DESC
    Environment names and their optional configuration.
    Each environment contains one or more Kubernetes clusters.
    If you want to later rename your environments, do not change the key name or Terraform will destroy it and create a new one from scratch which will have dramatic effects on your deployments.
    For this reason, it is recommended to use generic key names for both environments and clusters, you can name both by using the `name` parameter.
    By default a staging environment is created with one cluster using the default cluster configuration on your default cloud provider
    DESC
  type = map(object({
    name                = optional(string)
    promotion_order     = optional(number)
    continuous_delivery = optional(bool)
    clusters = map(object({
      name            = optional(string)
      autoscale       = optional(bool)
      create          = optional(bool)
      gpg_fingerprint = optional(string)
      gpg_public_key  = optional(string)
      kube_version    = optional(string)
      nodes           = optional(map(number))
      provider        = optional(string)
      region          = optional(string)
      tags            = optional(set(string))
      kube_config = optional(object({
        ca_certificate = string
        host           = string
        token          = string
      }))
    }))
  }))

  default = {
    stage = {
      name = "staging"
      clusters = {
        cluster1 = {}
      }
    }
  }

  validation {
    error_message = "You must specify at least one environment."
    condition     = var.environments != null && try(length(keys(var.environments)), 0) != 0
  }

  validation {
    error_message = "You must specify at least one cluster. If you manage it outside of oStack, you need to specify a value for `kube_config` or set `create` to false."
    condition     = alltrue([for env in values(var.environments) : length(keys(env.clusters)) > 0])
  }

  validation {
    error_message = "If providing a custom GPG key for a cluster, you must specify both gpg_public_key and gpg_fingerprint."
    condition = alltrue(flatten(
      [for env in values(var.environments) :
        [for cluster in values(env.clusters) :
          (lookup(cluster, "gpg_fingerprint", null) == null && lookup(cluster, "gpg_public_key", null) == null) || (lookup(cluster, "gpg_fingerprint", null) != null && lookup(cluster, "gpg_public_key", null) != null)
        ]
      ]
    ))
  }

  validation {
    error_message = "Cluster names must match the regex /^[a-z0-9-]+$/."
    condition = alltrue(flatten(
      [for env in values(var.environments) :
        [for id, cluster in env.clusters :
          can(regex("^[a-z0-9-]+$", lookup(cluster, "name", null) != null ? cluster.name : id))
        ]
      ]
    ))
  }

  validation {
    error_message = "Environment names must only contain alphanumeric characters. It may contain '-' but cannot start or finish with it."
    condition = alltrue(flatten(
      [for env in values(var.environments) :
        lookup(env, "name", null) != null ? can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?([a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])?)*$", env.name)) : true
      ]
    ))
  }
}
