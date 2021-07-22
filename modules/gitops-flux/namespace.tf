# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  ns_files = { for ns_id, namespace in var.namespaces :
    ns_id => { for repo_id, repo in namespace.repos :
      repo_id => merge(
        {
          "${var.base_dir}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
            paths = ["delete-me.yaml"]
          })
          "${var.base_dir}/delete-me.yaml" = templatefile("${path.module}/templates/namespace/delete-me.yaml.tpl", {
            namespace = namespace.name
            repo      = repo.name
          })
        },
        { for env in namespace.environments :
          "${var.environments[env].name}/kustomization.yaml" => templatefile("${local.partial}/kustomization.yaml.tpl", {
            paths = ["../${local.base_dir}"]
          })
        }
      ) if repo.type == "ops"
    }
  }
}
