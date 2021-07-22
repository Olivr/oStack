# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "github_repository_deploy_key" "deploy_keys" {
  for_each = var.deploy_keys

  repository = local.repo.name
  title      = each.value.title
  read_only  = try(each.value.read_only, true)
  key = can(
    regex("^sensitive::", each.value.ssh_key)
    ) ? (
    sensitive(var.sensitive_inputs[trimprefix(each.value.ssh_key, "sensitive::")])
    ) : (
    each.value.ssh_key
  )
}
