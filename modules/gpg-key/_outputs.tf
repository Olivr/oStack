# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "private_key" {
  description = "Private key in armored format."
  value       = trimspace(module.private_key.stdout)
  sensitive   = true
}

output "public_key" {
  description = "Public key in armored format."
  value       = trimspace(module.public_key.stdout)
}

output "fingerprint" {
  description = "Key fingerprint."
  value       = trimspace(module.fingerprint.stdout)
}
