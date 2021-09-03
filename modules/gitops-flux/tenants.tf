# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  tenants_files = { for ns_id, namespace in var.tenants :
    ns_id => { for repo_id, repo in namespace.repos :
      repo_id => { for env in namespace.environments :
        "${local.env_dir}/${var.environments[env].name}/kustomization.yaml" => <<-EOF
            apiVersion: kustomize.config.k8s.io/v1beta1
            kind: Kustomization
            namespace: ${namespace.name}
            resources:
              - "../../${local.base_dir}"
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
            fingerprints_env = namespace.gpg_keys
            fingerprints_all = flatten(values(namespace.gpg_keys)[*].fingerprint)
          })
        },
        { for key in namespace.gpg_keys :
          ".gpg_keys/${key.name}.sops.pub.asc" => key.public_key
        }
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
}
