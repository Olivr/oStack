locals{
  kube_token = can(
    regex("^sensitive::", var.clusters["${cluster}"].kube_token)
    ) ? (
    sensitive(var.sensitive_inputs_per_cluster["${cluster}"][trimprefix(var.clusters["${cluster}"].kube_token, "sensitive::")])
    ) : (
    var.clusters["${cluster}"].kube_token
  )
}

provider "kubernetes" {
  alias                  = "${cluster}"
  host                   = var.clusters["${cluster}"].kube_host
  cluster_ca_certificate = base64decode(var.clusters["${cluster}"].kube_ca_certificate)
  token                  = local.kube_token
}

provider "kubectl" {
  alias                  = "${cluster}"
  host                   = var.clusters["${cluster}"].kube_host
  cluster_ca_certificate = base64decode(var.clusters["${cluster}"].kube_ca_certificate)
  token                  = local.kube_token
  load_config_file       = false
}

module "${cluster}" {
  source = "${module_source}"
  providers = {
    kubernetes = kubernetes.${cluster}
    kubectl    = kubectl.${cluster}
  }

  cluster_path     = var.clusters["${cluster}"].cluster_path
  base_dir         = var.clusters["${cluster}"].base_dir
  namespaces       = var.clusters["${cluster}"].namespaces
  deploy_keys      = var.clusters["${cluster}"].deploy_keys
  secrets          = var.clusters["${cluster}"].secrets
  sensitive_inputs = var.sensitive_inputs_per_cluster["${cluster}"]
}
