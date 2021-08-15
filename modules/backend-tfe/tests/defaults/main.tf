##
# Initalize resources
##
module "main" {
  source         = "../.."
  workspace_name = var.name
  # workspace_name         = random_pet.name.id
  workspace_organization = "romain-test"
}
