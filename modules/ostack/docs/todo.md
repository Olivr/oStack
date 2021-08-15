## How to update?

- Main stack updated through Terraform module that contains static versions of software (updated through dependabot)
- don't update template repos

## Todos

- Put back client validation on kyverno
- Github action to open pull requests from \_config repository
- Header in all files managed by Terraform
- Add prometheus/Thanos/Grafana
- Write documentation
- Create dev cluster configuration
- Add branch status checks for Terraform cloud repos (\_clusters and -infra) and verify branch protection
- Add init-cluster module_versions & allow to specify both in config

## Development/maintenance

- How to maintain template repos? Create other branch?
- How to run E2E tests on main repo and template repos?
- Use giant mono-repo and copybara to create main and template repos?
