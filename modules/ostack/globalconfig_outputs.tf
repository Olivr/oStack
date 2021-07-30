# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
# output "globalconfig" {
#   description = "Global configuration repo(s)."
#   value       = local.globalconfig_output
# }

output "globalconfig_sensitive" {
  description = "Global configuration repo(s) sensitive values."
  sensitive   = true
  value = { for provider in local.global_config_providers :
    provider => {
      vcs = {
        sensitive_inputs = try(local.globalconfig_static[provider].vcs.sensitive_inputs, {})
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalconfig_output = { for provider in local.global_config_providers :
    provider => {
      vcs_repos = local.vcs_repo_globalconfig[provider]
      initial_config = merge(
        local.globalconfig_static[provider],
        local.globalconfig_dynamic[provider],
        {
          vcs = merge(
            merge(local.globalconfig_static[provider].vcs, { sensitive_inputs = null }),
            local.globalconfig_dynamic[provider].vcs
          )
        }
      )
    }
  }
}
