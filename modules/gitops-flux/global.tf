# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  global_files = { for path, content in merge(
    local.global_infra,
    local.global_infra_clusters,
    local.global_infra_cluster_init,
    local.global_flux,
    local.global_tenants_base,
    local.global_tenants,
    local.global_environments,
  ) : path => content if content != null && content != "" && content != "\n" }
}

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
# Generate manifests used by Flux
data "flux_install" "main" {
  target_path    = "_base"
  network_policy = false
}

data "flux_sync" "main" {
  target_path = "_base/flux-system"
  url         = var.global.ssh_url
  branch      = var.global.branch_default_name
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  global_infra = {
    "${local.infra_dir}/_inputs.tf"    = file("${path.module}/templates/global/_infra/_inputs.tf.tpl")
    "${local.infra_dir}/_providers.tf" = file("${path.module}/templates/global/_infra/_providers.tf.tpl")
  }

  # Create one cluster init file per cluster
  global_infra_clusters = merge(flatten([for env in values(var.environments) : [
    for cluster in values(env.clusters) : {
      "${local.infra_dir}/${cluster.name}.tf" = templatefile("${path.module}/templates/global/_infra/cluster.tf.tpl", {
        cluster       = cluster.name
        module_source = local.cluster_init_path != null ? "./modules/init-cluster" : var.cluster_init_module
    }) }
    ]
  ])...)

  # If the init module is a path (as opposed to a remote module), load all files from the path
  global_infra_cluster_init = local.cluster_init_path != null ? { for path in fileset(local.cluster_init_path, "**") :
    "${local.infra_dir}/modules/init-cluster/${path}" => file("${local.cluster_init_path}/${path}")
  } : {}

  # Flux system files
  global_flux = {
    "${local.base_dir}/flux-system/gotk-components.yaml" = data.flux_install.main.content
    "${local.base_dir}/flux-system/gotk-sync.yaml"       = data.flux_sync.main.content
    "${local.base_dir}/flux-system/notifications.yaml" = contains(local.commit_status_providers, var.global.provider) ? templatefile("${local.partial}/commit_status.yaml.tpl", {
      name             = "flux-system"
      namespace        = "flux-system"
      provider         = var.global.provider
      repo_http_url    = var.global.http_url
      secret_name      = "vcs-token"
      source_namespace = ""
    }) : null
    "${local.base_dir}/flux-system/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
      paths = [
        "gotk-components.yaml",
        "gotk-sync.yaml",
        contains(local.commit_status_providers, var.global.provider) ? "notifications.yaml" : null
      ]
    })
  }

  # Tenants base kustomization
  global_tenants_base = {
    "${local.base_dir}/${local.tenants_dir}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
      paths = keys(local.tenants)
    })
  }

  # Tenants configuration
  global_tenants = merge(flatten([for tenant, config in local.tenants :
    {
      "${local.base_dir}/${local.tenants_dir}/${tenant}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = [
          "namespace.yaml",
          "rbac.yaml",
          "sync.yaml",
          "notifications.yaml"
        ]
      })
      "${local.base_dir}/tenants/${tenant}/namespace.yaml" = templatefile("${local.partial}/namespace.yaml.tpl", {
        namespace = tenant
      })
      "${local.base_dir}/${local.tenants_dir}/${tenant}/rbac.yaml" = templatefile("${local.partial}/namespace_rbac.yaml.tpl", {
        namespace = tenant
      })
      "${local.base_dir}/${local.tenants_dir}/${tenant}/sync.yaml" = join("\n", [for repo in values(config.repos) :
        templatefile("${local.partial}/sync.yaml.tpl", {
          name         = repo.name
          namespace    = tenant
          repo_ssh_url = repo.vcs.ssh_url
          branch_name  = repo.vcs.branch_default_name
          secret_name  = "flux-${repo.name}"
          type         = "gitops-repo"
        }) if repo.type == "ops"
      ])
      "${local.base_dir}/${local.tenants_dir}/${tenant}/notifications.yaml" = join("\n", [for repo in values(config.repos) :
        templatefile("${local.partial}/commit_status.yaml.tpl", {
          name             = repo.name
          namespace        = "flux-system"
          provider         = repo.vcs.provider
          repo_http_url    = repo.vcs.http_url
          secret_name      = "vcs-token-${repo.name}"
          source_namespace = tenant
        }) if repo.type == "ops" && contains(local.commit_status_providers, repo.vcs.provider)
      ])
    }
  ])...)

  # Environments configuration
  global_environments = merge(flatten([for env in values(var.environments) : merge({
    "${env.name}/${local.base_dir}/kustomization.yaml" = templatefile("${path.module}/templates/global/env/_base/kustomization.yaml.tpl", {
      base_dir    = local.base_dir
      tenants_dir = local.tenants_dir
    })
    "${env.name}/${local.base_dir}/${local.tenants_dir}-patch.yaml" = templatefile("${path.module}/templates/global/env/_base/tenants-patch.yaml.tpl", {
      environment = env.name
    }) }, merge(
    [for cluster in values(env.clusters) : {
      "${env.name}/${cluster.name}/kustomization.yaml" = templatefile("${path.module}/templates/global/env/cluster/kustomization.yaml.tpl", {
        base_dir = local.base_dir
      })
      "${env.name}/${cluster.name}/flux-system-patch.yaml" = templatefile("${path.module}/templates/global/env/cluster/flux-system-patch.yaml.tpl", {
        environment = env.name
        cluster     = cluster.name
      })
      "${env.name}/${cluster.name}/notifications-patch.yaml" = templatefile("${path.module}/templates/global/env/cluster/notifications-patch.yaml.tpl", {
        cluster = cluster.name
      }) }
    ]...))
  ])...)
}
