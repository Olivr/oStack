# ---------------------------------------------------------------------------------------------------------------------
# Exported variables
# These variables are used in other files
# ---------------------------------------------------------------------------------------------------------------------
locals {
  repo_system_files = merge(
    local.repo_gpg,
    local.repo_infra,
    local.repo_infra_local,
    local.repo_infra_cluster_init,
    local.repo_base,
    local.repo_flux,
    local.repo_kyverno,
    local.repo_tenants,
    local.repo_environments_strict,
  )

  repo_files = local.repo_environments
}

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
# Generate manifests used by Flux
data "flux_install" "main" {
  target_path    = local.system_dir
  network_policy = false
}

data "flux_sync" "main" {
  target_path = "${local.system_dir}/flux-system"
  url         = var.repo_ssh_url
  branch      = var.branch_name
}

# ---------------------------------------------------------------------------------------------------------------------
# Computations
# These variables are referenced in this file only
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # Setup SOPS
  repo_fingerprints_clusters = { for env_id, env in var.environments :
    env_id => { for cluster_id, cluster in env.clusters :
      cluster_id => cluster.gpg_fingerprint if cluster.gpg_fingerprint != null
    }
  }

  repo_fingerprints_env = { for env_id, cluster_fingerprints in local.repo_fingerprints_clusters :
    env_id => flatten(values(cluster_fingerprints))
  }

  repo_gpg = merge(
    {
      ".sops.yaml" = templatefile("${local.partial}/repo_sops.yaml.tpl", {
        environments     = var.environments
        fingerprints_env = local.repo_fingerprints_env
        fingerprints_all = flatten(values(local.repo_fingerprints_env))
      })
    },
    merge([for env in var.environments :
      { for cluster in env.clusters :
        ".gpg_keys/${env.name}-${cluster.name}.sops.pub.asc" => cluster.gpg_public_key
      }
    ]...)
  )

  # Init cluster file for remote clusters
  repo_infra = merge([for env in var.environments :
    { for cluster in env.clusters :
      "${local.infra_dir}/${env.name}-${cluster.name}/main.tf" => templatefile("${path.module}/templates/infra/remote.tf.tpl", {
        base_dir      = local.system_dir
        base_path     = "../../.."
        cluster_path  = "./${local.env_dir}/${env.name}/${local.clusters_dir}/${cluster.name}/${local.system_dir}"
        deploy_keys   = replace(jsonencode(var.deploy_keys[cluster.name]), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
        module_source = local.cluster_init_path != null ? "../shared-modules/init-cluster" : var.init_cluster.module_source
        namespaces    = join("\",\"", local.environment_tenants[env.name])
        secrets       = replace(jsonencode(var.secrets[cluster.name]), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
      })
    }
  ]...)

  repo_infra_local = {
    "${local.infra_dir}/_ci/main.tf" = templatefile("${path.module}/templates/infra/ci.tf.tpl", {
      base_dir      = local.system_dir
      deploy_keys   = replace(jsonencode(var.deploy_keys["_ci"]), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
      module_source = local.cluster_init_path != null ? "../shared-modules/init-cluster" : var.init_cluster.module_source
      namespaces    = join("\",\"", keys(local.tenants))
      secrets       = replace(jsonencode(var.secrets["_ci"]), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
    })

    "${local.infra_dir}/_dev/main.tf" = templatefile("${path.module}/templates/infra/dev.tf.tpl", {
      vcs_providers = local.vcs_providers
      base_dir      = local.system_dir
      deploy_keys   = replace(jsonencode(var.deploy_keys["_dev"]), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
      module_source = local.cluster_init_path != null ? "../shared-modules/init-cluster" : var.init_cluster.module_source
      namespaces    = join("\",\"", keys(local.tenants))
      secrets       = replace(jsonencode(var.secrets["_dev"]), "/(\".*?\"):/", "$1 = ") # https://brendanthompson.com/til/2021/3/hcl-enabled-tfe-variables
    })
  }

  # If the init module is a path (as opposed to a remote module), load all files from the path
  repo_infra_cluster_init = local.cluster_init_path != null ? { for path in fileset(local.cluster_init_path, "**") :
    "${local.infra_dir}/shared-modules/init-cluster/${path}" => file("${local.cluster_init_path}/${path}")
  } : {}

  # Base directory (_ostack)
  repo_base = {
    "${local.system_dir}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
      paths = [
        "flux-system",
        "kyverno/sync.yaml",
      ]
    })
  }

  # Flux system files
  repo_flux = {
    "${local.system_dir}/flux-system/gotk-components.yaml" = data.flux_install.main.content
    "${local.system_dir}/flux-system/gotk-sync.yaml"       = data.flux_sync.main.content
    "${local.system_dir}/flux-system/notifications.yaml" = contains(local.commit_status_providers, var.commit_status_provider) ? templatefile("${local.partial}/commit_status.yaml.tpl", {
      name          = "flux-system"
      namespace     = "flux-system"
      provider      = var.commit_status_provider
      repo_http_url = var.commit_status_http_url
      secret_name   = "vcs-token"
    }) : "# Not supported with ${var.commit_status_provider}"
    "${local.system_dir}/flux-system/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
      paths = [
        "gotk-components.yaml",
        "gotk-sync.yaml",
        contains(local.commit_status_providers, var.commit_status_provider) ? "notifications.yaml" : null
      ]
    })
  }

  # Kyverno
  repo_kyverno = {
    "${local.system_dir}/kyverno/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
      paths = ["https://raw.githubusercontent.com/kyverno/kyverno/v1.3.6/definitions/release/install.yaml"]
    })
    "${local.system_dir}/kyverno/policies/disallow-default-namespace.yaml" = file("${path.module}/templates/kyverno/policies/disallow-default-namespace.yaml")
    "${local.system_dir}/kyverno/policies/flux-multi-tenancy.yaml" = templatefile("${path.module}/templates/kyverno/policies/flux-multi-tenancy.yaml.tpl", {
      #excluded_tenants = [for tenant in local.tenants : tenant.name if !tenant.tenants_isolation]
      excluded_tenants = []
    })
    "${local.system_dir}/kyverno/sync.yaml" = templatefile("${path.module}/templates/kyverno/sync.yaml.tpl", {
      base_dir = local.system_dir
    })
  }

  # Tenants configuration
  repo_tenants = merge(flatten([for tenant, config in local.tenants :
    {
      "${local.system_dir}/${local.tenants_dir}/${tenant}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = [
          "namespace.yaml",
          "rbac.yaml",
          "sync.yaml",
          "notifications.yaml"
        ]
      })
      "${local.system_dir}/tenants/${tenant}/namespace.yaml" = templatefile("${local.partial}/namespace.yaml.tpl", {
        namespace = tenant
      })
      "${local.system_dir}/${local.tenants_dir}/${tenant}/rbac.yaml" = templatefile("${local.partial}/tenant_rbac.yaml.tpl", {
        namespace = tenant
      })
      "${local.system_dir}/${local.tenants_dir}/${tenant}/sync.yaml" = join("\n", [for repo in values(config.repos) :
        templatefile("${local.partial}/sync.yaml.tpl", {
          branch_name  = repo.vcs.branch_default_name
          name         = repo.name
          namespace    = tenant
          repo_ssh_url = repo.vcs.repo_ssh_url
          secret_name  = "flux-${repo.name}"
          type         = "gitops-repo"
        }) if repo.type == "ops"
      ])
      "${local.system_dir}/${local.tenants_dir}/${tenant}/notifications.yaml" = join("\n", [for repo in values(config.repos) :
        templatefile("${local.partial}/commit_status.yaml.tpl", {
          name          = repo.name
          namespace     = tenant
          provider      = repo.vcs.provider
          repo_http_url = repo.vcs.repo_http_url
          secret_name   = "vcs-token-${repo.name}"
        }) if repo.type == "ops" && contains(local.commit_status_providers, repo.vcs.provider)
      ])
    }
  ])...)

  # Environments configuration
  repo_environments_strict = merge(flatten([for env in values(var.environments) : merge(
    {
      "${local.env_dir}/${env.name}/${local.system_dir}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = ["../../../${local.system_dir}", "sync.yaml"]
      })
      "${local.env_dir}/${env.name}/${local.system_dir}/sync.yaml" = templatefile("${path.module}/templates/env/sync.yaml.tpl", {
        env_name     = env.name
        tenants_dir  = local.tenants_dir
        tenants_path = "${local.env_dir}/${env.name}/${local.system_dir}/${local.tenants_dir}"
      })
      "${local.env_dir}/${env.name}/${local.overlay_dir}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = ["../../../${local.base_dir}"]
      })

      # Tenants
      "${local.env_dir}/${env.name}/${local.system_dir}/${local.tenants_dir}/${local.tenants_dir}-patch.yaml" = templatefile("${local.partial}/patch.yaml.tpl", {
        kind       = "Kustomization"
        metadata   = { name = "gitops-repo" }
        patch_type = "merge"
        spec       = { path = "./${local.env_dir}/${env.name}" }
      })
      "${local.env_dir}/${env.name}/${local.system_dir}/${local.tenants_dir}/kustomization.yaml" = templatefile("${path.module}/templates/env/tenants/kustomization.yaml.tpl", {
        paths       = local.environment_tenants[env.name]
        tenants_dir = local.tenants_dir
        base_dir    = local.system_dir
      })
      "${local.env_dir}/${env.name}/${local.system_dir}/${local.tenants_dir}/prefix-kustomization.yaml" = templatefile("${path.module}/templates/env/tenants/prefix-kustomization.yaml.tpl", {
        name = env.name
      })
    },

    # Clusters
    merge([for cluster in values(env.clusters) : {
      "${local.env_dir}/${env.name}/${local.clusters_dir}/${cluster.name}/${local.overlay_dir}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = ["../../../${local.overlay_dir}"]
      })
      "${local.env_dir}/${env.name}/${local.clusters_dir}/${cluster.name}/${local.system_dir}/kustomization.yaml" = templatefile("${path.module}/templates/env/cluster/kustomization.yaml.tpl", {
        base_dir = local.system_dir
      })
      "${local.env_dir}/${env.name}/${local.clusters_dir}/${cluster.name}/${local.system_dir}/flux-system-patch.yaml" = templatefile("${local.partial}/patch.yaml.tpl", {
        kind       = "Kustomization"
        metadata   = { name = "flux-system", namespace = "flux-system" }
        patch_type = "merge"
        spec       = { path = "./${local.env_dir}/${env.name}/${local.clusters_dir}/${cluster.name}/${local.system_dir}" }
      })
      "${local.env_dir}/${env.name}/${local.clusters_dir}/${cluster.name}/${local.system_dir}/sync.yaml" = templatefile("${path.module}/templates/env/cluster/sync.yaml.tpl", {
        name         = cluster.name
        overlay_path = "${local.env_dir}/${env.name}/${local.clusters_dir}/${cluster.name}/${local.overlay_dir}"
      })
    }]...))
  ])...)

  # Environments configuration
  repo_environments = merge(flatten([for env in values(var.environments) : merge(
    {
      "${local.env_dir}/${env.name}/${local.overlay_dir}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = ["../../../${local.base_dir}"]
      })
    },
    merge([for cluster in values(env.clusters) : {
      "${local.env_dir}/${env.name}/${local.clusters_dir}/${cluster.name}/${local.overlay_dir}/kustomization.yaml" = templatefile("${local.partial}/kustomization.yaml.tpl", {
        paths = ["../../../${local.overlay_dir}"]
      })
    }]...))
  ])...)
}
