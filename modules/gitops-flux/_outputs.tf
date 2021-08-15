# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "repo_files" {
  description = "Files to add to the main repo. These are files that are expected to be modified by collaborators."
  value       = local.repo_files
}

output "repo_system_files" {
  description = "Files to add to the main repo. These are files that are not expected to be modified by collaborators."
  value       = local.repo_system_files
}

output "tenants_files" {
  description = "Files to add to namespace ops repos. These are files that are expected to be modified by collaborators."
  value       = local.tenants_files
}

output "tenants_system_files" {
  description = "System files to add to tenant repos. These are files that are not expected to be modified by collaborators."
  value       = local.tenants_system_files
}
