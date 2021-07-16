# ---------------------------------------------------------------------------------------------------------------------
# Multi-providers
# ---------------------------------------------------------------------------------------------------------------------
# locals {
#   clusters_backend = lookup({
#     tfe = module.clusters_backend_tfe
#   }, var.backend_provider)
# }

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  cluster_backend_secrets = {
    vcs_token = null # defined in local.clusters_backend_sensitive
  }

  clusters_backend_hcl = {
    sensitive_inputs_per_cluster = null # defined in local.clusters_backend_sensitive
    clusters = replace(jsonencode(merge([for cluster, config in local.clusters_to_create : {
      (cluster) = {
        deploy_keys = merge({ for id, config in local.ns_ops_repos :
          id => {
            name      = "flux-${config.repo_name}"
            namespace = local.namespaces[config.ns_id].name
            #namespace = "flux-system"
            public_key = base64encode(tls_private_key.ns_keys["${id}_${cluster}"].public_key_pem)
          }
          }, {
          "_clusters" = {
            name       = "flux-system"
            namespace  = "flux-system"
            public_key = base64encode(tls_private_key.cluster_keys[cluster].public_key_pem)
          }
        })
        kube_host           = local.clusters_k8s[cluster].kube_host
        kube_ca_certificate = base64encode(local.clusters_k8s[cluster].kube_ca_certificate)
        cluster_path        = "./${config.environment}/${cluster}"
      }
    }]...)), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
  }

  clusters_backend_sensitive = {
    vcs_token = var.vcs_token_write
    sensitive_inputs_per_cluster = replace(jsonencode(merge([for cluster, config in local.clusters_to_create : {
      (cluster) = merge({
        kube_token            = sensitive(local.clusters_k8s[cluster].kube_token)
        _clusters_private_key = sensitive(tls_private_key.cluster_keys[cluster].private_key_pem)
        }, { for id in keys(local.ns_ops_repos) :
        "${id}_private_key" => sensitive(tls_private_key.ns_keys["${id}_${cluster}"].private_key_pem)
      })
    }]...)), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
  }
}
