# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "namespaces" {
  description = "Full configuration for all namespaces."
  value       = lookup(local.dev, "disable_outputs", false) ? null : local.namespaces_outputs
}

output "namespaces_files" {
  description = "Namespaces files are in a separate output for easier readability of the main `namespaces` output."
  value       = lookup(local.dev, "disable_outputs", false) ? null : local.namespaces_outputs_files
}

output "namespaces_files_strict" {
  description = "Namespaces files are in a separate output for easier readability of the main `namespaces` output."
  value       = lookup(local.dev, "disable_outputs", false) ? null : local.namespaces_outputs_files_strict
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  namespaces_outputs_prepare = { for namespace_id, namespace in local.namespaces :
    namespace_id => merge(
      { for k, v in namespace :
        k => v if k != "_namespace"
      },
      {
        repos = { for repo_id, repo in namespace.repos :
          repo_id => merge(
            repo,
            {
              vcs = { for k, v in merge(repo.vcs, local.vcs_repos_namespaces["${namespace_id}_${repo_id}"]) :
                k => v if k != "_namespace" && k != "_repo"
              }
              backends = lookup(repo, "backends", null) == null ? {} : { for backend_id, backend in repo.backends :
                backend_id => merge(backend, local.backends_namespaces["${namespace_id}_${repo_id}_${backend_id}"])
              }
            }
          )
        }
      }
    )
  }

  namespaces_outputs = { for namespace_id, namespace in local.namespaces_outputs_prepare :
    namespace_id => merge(namespace,
      {
        repos = { for repo_id, repo in namespace.repos :
          repo_id => merge(repo,
            {
              vcs = { for k, v in repo.vcs :
                k => v if k != "sensitive_inputs" && k != "repo_secrets" && k != "files" && k != "files_strict"
              }
              backends = { for backend_id, backend in repo.backends :
                backend_id => { for k, v in backend :
                  k => v if k != "sensitive_inputs" && k != "tf_vars" && k != "tf_vars_hcl" && k != "env_vars"
                }
              }
            }
          )
        }
      }
    )
  }

  namespaces_outputs_sensitive = { for namespace_id, namespace in local.namespaces_outputs_prepare :
    namespace_id => { for repo_id, repo in namespace.repos :
      repo_id => {
        vcs = {
          sensitive_inputs = repo.vcs.sensitive_inputs
          repo_secrets     = repo.vcs.repo_secrets
        }
        backends = { for backend_id, backend in repo.backends :
          backend_id => {
            env_vars         = backend.env_vars
            sensitive_inputs = backend.sensitive_inputs
            tf_vars          = backend.tf_vars
            tf_vars_hcl      = backend.tf_vars_hcl
          }
        }
      }
    }
  }

  namespaces_outputs_files = { for namespace_id, namespace in local.namespaces_outputs_prepare :
    namespace_id => { for repo_id, repo in namespace.repos :
      repo_id => repo.vcs.files
    }
  }

  namespaces_outputs_files_strict = { for namespace_id, namespace in local.namespaces_outputs_prepare :
    namespace_id => { for repo_id, repo in namespace.repos :
      repo_id => repo.vcs.files_strict
    }
  }
}
