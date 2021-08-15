# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  tenants_files = { for ns_id, namespace in var.tenants :
    ns_id => { for repo_id, repo in namespace.repos :
      repo_id => { for env in namespace.environments :
        "${var.environments[env].name}/kustomization.yaml" => <<-EOF
            apiVersion: kustomize.config.k8s.io/v1beta1
            kind: Kustomization
            namespace: ${namespace.name}
            resources:
              - "../${local.base_dir}"
            EOF
      } if repo.type == "ops"
    }
  }

  tenants_system_files = { for ns_id, namespace in var.tenants :
    ns_id => { for repo_id, repo in namespace.repos :
      repo_id => merge(
        {
          ".sops.yaml" = templatefile("${local.partial}/tenant_sops.yaml.tpl", {
            environments     = local.ns_environments[ns_id]
            fingerprints_env = local.ns_fingerprints_env[ns_id]
            fingerprints_all = flatten(values(local.ns_fingerprints_env[ns_id]))
          })
        },
        merge([for env in namespace.environments :
          { for cluster in var.environments[env].clusters :
            ".gpg_keys/${var.environments[env].name}-${cluster.name}.sops.pub.asc" => cluster.gpg_public_key
          }
        ]...)
      ) if repo.type == "ops"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# These variables are referenced in this file only
# ---------------------------------------------------------------------------------------------------------------------
locals {
  ns_environments = { for ns_id, namespace in var.tenants :
    ns_id => { for env_id, env in namespace.environments :
      env_id => var.environments[env_id]
    }
  }

  ns_fingerprints_env = { for ns_id, environments in local.ns_environments :
    ns_id => { for env_id, env in environments :
      env_id => [for cluster in env.clusters :
        cluster.gpg_fingerprint if cluster.gpg_fingerprint != null
      ]
    }
  }
}
