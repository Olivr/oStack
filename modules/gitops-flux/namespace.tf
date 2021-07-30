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
      repo_id => {} if repo.type == "ops"
    }
  }
}
