# ---------------------------------------------------------------------------------------------------------------------
# Resources
# ---------------------------------------------------------------------------------------------------------------------
resource "github_actions_secret" "secret" {
  for_each = var.secrets

  repository  = local.repo.name
  secret_name = each.key
  plaintext_value = can(
    regex("^sensitive::", each.value)
    ) ? (
    sensitive(var.sensitive_inputs[trimprefix(each.value, "sensitive::")])
    ) : (
    each.value
  )
}
