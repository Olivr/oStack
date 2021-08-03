# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "environments" {
  description = "Full configuration for each environment."
  value       = lookup(local.dev, "disable_outputs", false) ? null : local.environments_outputs
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  environments_outputs_prepare = { for env_id, env in local.environments :
    env_id => merge(env, {
      clusters = { for cluster_id, cluster in env.clusters :
        cluster_id => merge(cluster, try(local.clusters_k8s["${env_id}_${cluster_id}"], null))
      }
    })
  }

  environments_outputs = { for env_id, env in local.environments_outputs_prepare :
    env_id => merge(env, {
      clusters = { for cluster_id, cluster in env.clusters :
        cluster_id => { for k, v in cluster :
          k => v if k != "_env" && k != "kube_config" && k != "kube_token" && k != "kube_ca_certificate"
        }
      }
    })
  }

  environments_outputs_sensitive = { for env_id, env in local.environments_outputs_prepare :
    env_id => { for cluster_id, cluster in env.clusters :
      (cluster_id) => { for k, v in cluster :
        k => v if k == "kube_config" || k == "kube_token" || k == "kube_ca_certificate"
      }
    }
  }
}
