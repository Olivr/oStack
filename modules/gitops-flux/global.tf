# ---------------------------------------------------------------------------------------------------------------------
# Main variables
# ---------------------------------------------------------------------------------------------------------------------
locals {
  global_files_strict = merge(
    local.global_infra,
    local.global_infra_local,
    local.global_infra_clusters_merged,
    local.global_infra_cluster_init,
    local.global_base,
    local.global_flux,
    local.global_kyverno,
    local.global_tenants,
    local.global_environments_strict,
  )

  global_files = local.global_environments
}

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
# Generate manifests used by Flux
data "flux_install" "main" {
  target_path    = local.base_dir
  network_policy = false
}

data "flux_sync" "main" {
  target_path = "${local.base_dir}/flux-system"
  url         = var.global.vcs.ssh_url
  branch      = var.global.vcs.branch_default_name
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  combined_infra = var.global.backends[keys(var.global.backends)[0]].combine_environments

  global_infra = merge([for backend in values(var.global.backends) :
    {
      "${trim(backend.vcs_working_directory, "/")}/_inputs.tf"    = file("${path.module}/templates/global/infra/_inputs.tf.tpl")
      "${trim(backend.vcs_working_directory, "/")}/_providers.tf" = file("${path.module}/templates/global/infra/_providers.tf.tpl")
    }
  ]...)

  # Workaround to allow for static variable resolution (Terraform needs to know at least the keys)
  # We identify the keys first, then the values and then we merge the two maps together
  global_infra_clusters = merge(distinct(flatten([for backend_id, backend in var.global.backends :
    [for env_id, env in var.environments :
      [for cluster in values(env.clusters) :
        { "${trim(backend.vcs_working_directory, "/")}/${cluster.name}.tf" = "" }
      ] if backend_id == env_id || backend.combine_environments
    ]
  ]))...)

  global_infra_clusters_values = merge(distinct(flatten([for backend_id, backend in var.global.backends :
    [for env_id, env in var.environments :
      [for cluster in values(env.clusters) :
        {
          "${trim(backend.vcs_working_directory, "/")}/${cluster.name}.tf" = templatefile("${path.module}/templates/global/infra/cluster.tf.tpl", {
            base_dir      = local.base_dir
            base_path     = backend.combine_environments ? "../.." : "../../.."
            cluster       = cluster.name
            cluster_path  = "./${env.name}/${cluster.name}/${local.base_dir}"
            deploy_keys   = replace(jsonencode(var.deploy_keys[cluster.name]), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
            module_source = local.cluster_init_path != null ? (backend.combine_environments ? "./modules/init-cluster" : "../shared-modules/init-cluster") : var.cluster_init_module
            namespaces    = join("\",\"", local.environment_tenants[env.name])
            secrets       = replace(jsonencode(var.secrets[cluster.name]), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
          })
        }
      ] if backend_id == env_id || backend.combine_environments
    ]
  ]))...)

  global_infra_clusters_merged = { for file_path in keys(local.global_infra_clusters) :
    file_path => local.global_infra_clusters_values[file_path]
  }

  # Init cluster file for local clusters (CI and dev)
  global_infra_local = {
    "${local.infra_dir}/_local/_providers.tf"         = file("${path.module}/templates/global/infra/_providers.tf.tpl")
    "${local.infra_dir}/_local/terraform.tfvars.json" = var.local_var_template
    "${local.infra_dir}/_local/main.tf" = templatefile("${path.module}/templates/global/infra/_local.tpl", {
      base_dir      = local.base_dir
      deploy_keys   = replace(jsonencode(var.deploy_keys["_ci"]), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
      module_source = local.cluster_init_path != null ? (local.combined_infra ? "../modules/init-cluster" : "../shared-modules/init-cluster") : var.cluster_init_module
      namespaces    = join("\",\"", keys(local.tenants))
    })
  }

  # If the init module is a path (as opposed to a remote module), load all files from the path
  global_infra_cluster_init = local.cluster_init_path != null ? { for path in fileset(local.cluster_init_path, "**") :
    "${local.infra_dir}/${local.combined_infra ? "" : "shared-"}modules/init-cluster/${path}" => file("${local.cluster_init_path}/${path}")
  } : {}

  # Base directory (_ostack)
  global_base = {
    "${local.base_dir}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
      paths = [
        "flux-system",
        "kyverno/sync.yaml",
      ]
    })
  }

  # Flux system files
  global_flux = {
    "${local.base_dir}/flux-system/gotk-components.yaml" = data.flux_install.main.content
    "${local.base_dir}/flux-system/gotk-sync.yaml"       = data.flux_sync.main.content
    "${local.base_dir}/flux-system/notifications.yaml" = contains(local.commit_status_providers, var.global.vcs.provider) ? templatefile("${local.partial}/commit_status.yaml.tpl", {
      name          = "flux-system"
      namespace     = "flux-system"
      provider      = var.global.vcs.provider
      repo_http_url = var.global.vcs.http_url
      secret_name   = "vcs-token"
    }) : "# Not supported with ${var.global.vcs.provider}"
    "${local.base_dir}/flux-system/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
      paths = [
        "gotk-components.yaml",
        "gotk-sync.yaml",
        contains(local.commit_status_providers, var.global.vcs.provider) ? "notifications.yaml" : null
      ]
    })
  }

  # Kyverno
  global_kyverno = {
    "${local.base_dir}/kyverno/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
      paths = ["https://raw.githubusercontent.com/kyverno/kyverno/v1.3.6/definitions/release/install.yaml"]
    })
    "${local.base_dir}/kyverno/policies/disallow-default-namespace.yaml" = file("${path.module}/templates/global/base/kyverno/policies/disallow-default-namespace.yaml")
    "${local.base_dir}/kyverno/policies/flux-multi-tenancy.yaml" = templatefile("${path.module}/templates/global/base/kyverno/policies/flux-multi-tenancy.yaml.tpl", {
      #excluded_tenants = [for tenant in local.tenants : tenant.name if !tenant.tenant_isolation]
      excluded_tenants = []
    })
    "${local.base_dir}/kyverno/sync.yaml" = templatefile("${path.module}/templates/global/base/kyverno/sync.yaml.tpl", {
      base_dir = local.base_dir
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
          branch_name  = repo.vcs.branch_default_name
          name         = repo.name
          namespace    = tenant
          repo_ssh_url = repo.vcs.ssh_url
          secret_name  = "flux-${repo.name}"
          type         = "gitops-repo"
        }) if repo.type == "ops"
      ])
      "${local.base_dir}/${local.tenants_dir}/${tenant}/notifications.yaml" = join("\n", [for repo in values(config.repos) :
        templatefile("${local.partial}/commit_status.yaml.tpl", {
          name          = repo.name
          namespace     = tenant
          provider      = repo.vcs.provider
          repo_http_url = repo.vcs.http_url
          secret_name   = "vcs-token-${repo.name}"
        }) if repo.type == "ops" && contains(local.commit_status_providers, repo.vcs.provider)
      ])
    }
  ])...)

  # Environments configuration
  global_environments_strict = merge(flatten([for env in values(var.environments) : merge(
    {
      "${env.name}/${local.base_dir}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = ["../../${local.base_dir}", "sync.yaml"]
      })
      "${env.name}/${local.base_dir}/sync.yaml" = templatefile("${path.module}/templates/global/env/sync.yaml.tpl", {
        env_name    = env.name
        tenants_dir = local.tenants_dir
        base_dir    = local.base_dir
      })
      "${env.name}/_overlays/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = ["../../_base"]
      })

      # Tenants
      "${env.name}/${local.base_dir}/${local.tenants_dir}/${local.tenants_dir}-patch.yaml" = templatefile("${local.partial}/patch.yaml.tpl", {
        kind       = "Kustomization"
        metadata   = { name = "gitops-repo" }
        patch_type = "merge"
        spec       = { path = "./${env.name}" }
      })
      "${env.name}/${local.base_dir}/${local.tenants_dir}/kustomization.yaml" = templatefile("${path.module}/templates/global/env/tenants/kustomization.yaml.tpl", {
        paths       = local.environment_tenants[env.name]
        tenants_dir = local.tenants_dir
        base_dir    = local.base_dir
      })
      "${env.name}/${local.base_dir}/${local.tenants_dir}/prefix-kustomization.yaml" = templatefile("${path.module}/templates/global/env/tenants/prefix-kustomization.yaml.tpl", {
        name = env.name
      })
    },

    # Clusters
    merge([for cluster in values(env.clusters) : {
      "${env.name}/${cluster.name}/_overlays/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = ["../../_overlays"]
      })
      "${env.name}/${cluster.name}/${local.base_dir}/kustomization.yaml" = templatefile("${path.module}/templates/global/env/cluster/kustomization.yaml.tpl", {
        base_dir = local.base_dir
      })
      "${env.name}/${cluster.name}/${local.base_dir}/flux-system-patch.yaml" = templatefile("${local.partial}/patch.yaml.tpl", {
        kind       = "Kustomization"
        metadata   = { name = "flux-system", namespace = "flux-system" }
        patch_type = "merge"
        spec       = { path = "./${env.name}/${cluster.name}/${local.base_dir}" }
      })
      "${env.name}/${cluster.name}/${local.base_dir}/sync.yaml" = templatefile("${path.module}/templates/global/env/cluster/sync.yaml.tpl", {
        name = cluster.name
        env  = env.name
      })
    }]...))
  ])...)

  # Environments configuration
  global_environments = merge(flatten([for env in values(var.environments) : merge(
    {
      "${env.name}/_overlays/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = ["../../_base"]
      })
    },
    merge([for cluster in values(env.clusters) : {
      "${env.name}/${cluster.name}/_overlays/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = ["../../_overlays"]
      })
    }]...))
  ])...)
}
