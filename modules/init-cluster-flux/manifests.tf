# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]

  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : replace(v, "./${var.base_dir}/flux-system", var.cluster_path)
    }
  ]
}

data "kubectl_file_documents" "install" {
  content = file("${path.cwd}/../${var.base_dir}/flux-system/gotk-components.yaml")
}

data "kubectl_file_documents" "sync" {
  content = file("${path.cwd}/../${var.base_dir}/flux-system/gotk-sync.yaml")
}

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "install" {
  for_each = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }

  depends_on = [
    kubernetes_namespace.flux_system,
    kubernetes_namespace.namespaces
  ]

  yaml_body = each.value
}

resource "kubectl_manifest" "sync" {
  for_each = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }

  depends_on = [
    kubernetes_namespace.flux_system,
    kubernetes_namespace.namespaces,
    kubernetes_secret.secrets,
    kubernetes_secret.deploy_keys,
    kubectl_manifest.install
  ]

  yaml_body = each.value
}
