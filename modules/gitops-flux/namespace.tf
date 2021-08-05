# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  ns_files = { for ns_id, namespace in var.namespaces :
    ns_id => { for repo_id, repo in namespace.repos :
      repo_id => merge(
        {
          # "${var.base_dir}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
          #   paths = ["delete-me.yaml"]
          # })
          # "${var.base_dir}/delete-me.yaml" = templatefile("${path.module}/templates/namespace/delete-me.yaml.tpl", {
          #   namespace = namespace.name
          #   repo      = repo.name
          # })
        },
        { for env in namespace.environments :
          "${var.environments[env].name}/kustomization.yaml" => <<-EOF
            apiVersion: kustomize.config.k8s.io/v1beta1
            kind: Kustomization
            namespace: ${namespace.name}
            resources:
              - "../_base"
            EOF
        }
      ) if repo.type == "ops"
    }
  }

  ns_files_strict = { for ns_id, namespace in var.namespaces :
    ns_id => { for repo_id, repo in namespace.repos :
      repo_id => merge(
        {
          ".sops.yaml" = templatefile("${local.partial}/ns_sops.yaml.tpl", {
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
# ---------------------------------------------------------------------------------------------------------------------
locals {
  ns_environments = { for ns_id, namespace in var.namespaces :
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
