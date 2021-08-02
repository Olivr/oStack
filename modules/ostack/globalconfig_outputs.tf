# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "globalconfig" {
  description = "Global configuration repo(s)."
  value       = lookup(local.dev, "disable_outputs", false) ? {} : local.globalconfig_output
}

output "globalconfig_sensitive" {
  description = "Global configuration repo(s) sensitive values."
  sensitive   = true
  value = lookup(local.dev, "disable_outputs", false) ? {} : { for provider, config in local.globalconfig :
    provider => try(config.vcs.sensitive_inputs, {})
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalconfig_output = { for provider, config in local.globalconfig :
    provider => {
      vcs_repo = local.vcs_repo_globalconfig[provider]
      initial_config = merge(
        config,
        {
          vcs = merge(
            config.vcs,
            { sensitive_inputs = null }
          )
        }
      )
    }
  }
}
