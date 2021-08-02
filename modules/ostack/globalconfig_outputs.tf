# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "globalconfig" {
  description = "Global configuration repo(s)."
  value       = lookup(local.dev, "disable_outputs", false) ? null : local.globalconfig_outputs
}

output "globalconfig_files" {
  description = "Global configuration repo(s) files."
  value       = lookup(local.dev, "disable_outputs", false) ? null : local.globalconfig_outputs_files
}

output "globalconfig_files_strict" {
  description = "Global configuration repo(s) strictly tracked files."
  value       = lookup(local.dev, "disable_outputs", false) ? null : local.globalconfig_outputs_files_strict
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalconfig_outputs = { for provider, config in local.globalconfig :
    provider => merge(config, {
      vcs = { for k, v in merge(config.vcs, local.vcs_repo_globalconfig[provider]) :
        k => v if k != "sensitive_inputs" && k != "repo_secrets" && k != "files" && k != "files_strict"
      }
    })
  }

  globalconfig_outputs_sensitive = { for provider, config in local.globalconfig :
    provider => {
      sensitive_inputs = try(config.vcs.sensitive_inputs, {})
      repo_secrets     = try(config.vcs.repo_secrets, {})
    }
  }

  globalconfig_outputs_files = { for provider, config in local.globalconfig :
    provider => try(config.vcs.files, {})
  }

  globalconfig_outputs_files_strict = { for provider, config in local.globalconfig :
    provider => try(config.vcs.files_strict, {})
  }
}
