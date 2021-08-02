# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "globalops" {
  description = "Global operations repo configuration."
  value       = lookup(local.dev, "disable_outputs", false) ? null : local.globalops_outputs
}

output "globalops_files" {
  description = "Global operations repo files."
  value       = lookup(local.dev, "disable_outputs", false) ? null : local.globalops.vcs.files
}

output "globalops_files_strict" {
  description = "Global operations repo strictly tracked files."
  value       = lookup(local.dev, "disable_outputs", false) ? null : local.globalops.vcs.files_strict
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  globalops_outputs_prepare = merge(
    local.globalops, {
      vcs = merge(local.globalops.vcs, local.vcs_repo_globalops)
      backends = { for backend_id, backend in local.globalops.backends :
        backend_id => { for k, v in merge(backend, local.backends_globalops[backend_id]) :
          k => v if k != "_env"
        }
      }
      gitops = { for k, v in local.globalops.gitops :
        k => v if k != "namespaces" && k != "environments"
      }
  })

  globalops_outputs = merge(local.globalops_outputs_prepare, {
    vcs = { for k, v in local.globalops_outputs_prepare.vcs :
      k => v if k != "sensitive_inputs" && k != "repo_secrets" && k != "files" && k != "files_strict"
    }
    backends = { for backend_id, backend in local.globalops_outputs_prepare.backends :
      backend_id => { for k, v in backend :
        k => v if k != "sensitive_inputs" && k != "tf_vars" && k != "tf_vars_hcl" && k != "env_vars"
      }
    }
  })

  globalops_outputs_sensitive = {
    vcs = {
      sensitive_inputs = local.globalops_outputs_prepare.vcs.sensitive_inputs
      repo_secrets     = local.globalops_outputs_prepare.vcs.repo_secrets
    }
    backends = { for backend_id, backend in local.globalops_outputs_prepare.backends :
      backend_id => {
        env_vars         = backend.env_vars
        sensitive_inputs = backend.sensitive_inputs
        tf_vars          = backend.tf_vars
        tf_vars_hcl      = backend.tf_vars_hcl
      }
    }
  }
}
