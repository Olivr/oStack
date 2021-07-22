<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_github"></a> [github](#requirement_github)          | ~> 4.0  |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_github"></a> [github](#provider_github) | ~> 4.0  |

## Modules

No modules.

## Resources

| Name | Type |
| --- | --- |
| [github_team.children](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team.grandchildren](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team.parents](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team_membership.members](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_membership) | resource |
| [github_user.current](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :-: |
| <a name="input_teams"></a> [teams](#input_teams) | GitHub teams and their configuration. You can use the special value `data::current_user` in the `user` field to add the current GitHub user to a team. | <pre>map(object({<br> title = string<br> description = optional(string)<br> privacy = optional(string)<br> teams = optional(map(object({<br> title = string<br> description = optional(string)<br> privacy = optional(string)<br> teams = optional(map(object({<br> title = string<br> description = optional(string)<br> privacy = optional(string)<br> members = optional(set(object({<br> user = string,<br> role = string<br> })))<br> })))<br> members = optional(set(object({<br> user = string,<br> role = string<br> })))<br> })))<br> members = optional(set(object({<br> user = string,<br> role = string<br> })))<br> }))</pre> | n/a | yes |

## Outputs

| Name                                               | Description                     |
| -------------------------------------------------- | ------------------------------- |
| <a name="output_teams"></a> [teams](#output_teams) | GitHub teams that were created. |

<!-- END_TF_DOCS -->
