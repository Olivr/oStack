# ---------------------------------------------------------------------------------------------------------------------
# Computations
# ---------------------------------------------------------------------------------------------------------------------
locals {

  base_dir  = trim(var.base_dir, "/")
  base_path = "${path.root}/${trim(var.base_path, "/")}/${local.base_dir}"

  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]

  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : replace(v, "./${local.base_dir}/flux-system", var.cluster_path)
    }
  ]
}

data "kubectl_file_documents" "install" {
  content = file("${local.base_path}/flux-system/gotk-components.yaml")
}

data "kubectl_file_documents" "sync" {
  content = file("${local.base_path}/flux-system/gotk-sync.yaml")
}

# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "install" {
  for_each = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }

  depends_on = [
    kubectl_manifest.flux_system,
    kubectl_manifest.namespaces
  ]

  yaml_body = each.value
}

resource "kubectl_manifest" "sync" {
  for_each = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }

  depends_on = [
    kubectl_manifest.flux_system,
    kubectl_manifest.namespaces,
    kubectl_manifest.secrets,
    kubectl_manifest.deploy_keys,
    kubectl_manifest.install
  ]

  yaml_body = each.value
}
