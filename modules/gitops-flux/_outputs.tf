# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "global_files" {
  description = "Files to add to global ops repo."
  value       = local.global_files
}

output "global_files_strict" {
  description = "Files to add to global ops repo and that should be tracked for changes."
  value       = local.global_files_strict
}

output "ns_files" {
  description = "Files to add to namespace ops repos."
  value       = local.ns_files
}

output "ns_files_strict" {
  description = "Files to add to namespace ops repos and that should be tracked for changes."
  value       = local.ns_files_strict
}
