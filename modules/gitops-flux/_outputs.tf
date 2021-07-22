# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "global_files" {
  description = "Files to add to global ops repo."
  value       = local.global_files
}

output "ns_files" {
  description = "Files to add to namespace ops repos."
  value       = local.ns_files
}
