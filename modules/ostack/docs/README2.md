# \_stack

PolyStartup's stack using GitOps and DevOps, integrated. 🤝

Generated from [oStack](https://ostack.io) with the help of [Oliv'r](https://olivr.com).

## Purpose of this repo

It manages the overall infrastructure needed to run the stack including clusters, git repos, teams, etc.

**Before making any changes** to this repo, it is **mandatory** to read and understand [how the stack works](overview.md).

## Naming conventions

- **Local** environment: Developer machine
- **Staging** environment: Production-like, maybe unstable environment where automated and manual testing take place
- **Production** environment: Stable environment used by customers
- **workspace**: Group of related projects

When naming resources, please follow this naming convention whenever possible and applicable:

`polystartup-workspace-environment-resourcename`

## Kubernetes clusters

There is one cluster per environment.

Local cluster instructions are located in [docs/local-cluster.md](local-cluster.md)

Remote clusters are defined in [clusters.tf](clusters.tf)

| Environments | Cluster name |
| --- | --- |
| Staging | [polystartup-staging](https://cloud.linode.com/kubernetes/clusters/9010/summary) |
| Production | [polystartup-production](https://cloud.linode.com/kubernetes/clusters/7831/summary) |

## GitOps repos

There is one repo per workspace.

### main-operations

|  | Local | Pull Requests | Staging | Production |
| --- | --- | --- | --- | --- |
| Branch | \* | \* | staging | production |
| k8s cluster | [kind-kind](local-cluster.md) | Disabled (cost-savings) | [polystartup-staging](#kubernetes-clusters) | [polystartup-production](#kubernetes-clusters) |
| k8s workspace | main |  | main | main |

## DevOps repos

There is one repo per workspace.

### main-apps

|  | Local | Pull Requests | Staging | Production |
| --- | --- | --- | --- | --- |
| Branch | \* | \* | staging | production |
| k8s cluster | [kind-kind](local-cluster.md) | [polystartup-staging](#kubernetes-clusters) | [polystartup-staging](#kubernetes-clusters) | [polystartup-production](#kubernetes-clusters) |
| k8s workspace | main | main-pr-\* | main | main |

## Domain names

- polystartup.com

## Making changes to PolyStartup's stack

A few common changes have been parametrized in [config.auto.tfvars](config.auto.tfvars)

To apply your changes to the stack, just open a pull request and ask an admin to merge it.

### Add an environment

```hcl
# List of other environments.
other_environments = ["dev"]
```

Mainly, this will create:

- A new Kubernetes cluster for the added environment(s)
- Environment branches in the GitOps and DevOps repos

> You cannot remove the staging and production environments unless you change the code. However, any other environment that you add can be as easily destroyed.

### Add a workspace

```hcl
# List of workspace names (a workspace contains several related projects).
# Use only letters and numbers to maximize compatibility across every system.
workspaces = ["main", "other"]
```

This will create:

- A new DevOps repo
- A new GitOps repo

> To protect from accidental deletion, if you try to remove a workspace, Terraform will throw an error. You will need to manually remove the two repos first.

### Other customizations

Just dive into the easy-to-read, declarative Terraform code of this repo and use the [Terraform docs](https://www.terraform.io/docs/)

## Modules

We are making use of modules as much as possible. Keeping the official modules will ensure easy upgrades. But this is your stack and it must evolve with your startup. If you need something else, search in the module repo issues and in the [official Keybase channel](https://keybase.io/team/olivr), maybe someone already discussed it.

If not, you have two options:

- Fork the module's code, make your changes and use your fork. This will allow you to update your code easily should the original module be updated.

  > If you think your changes could benefit the community, **please do submit** a pull request!

- Copy the module code in a folder under [/modules](/modules) and make your changes. This will allow you to manage all your stack code within one repo, but will make updating from the original module code harder.

  > You can do this quickly with [degit](https://www.npmjs.com/package/degit): `npx degit olivr/some-module modules/some-module`

## Upgrading

[oStack](https://ostack.io) is continuously evolving. However, for stability and predictability reasons, PolyStartup's stack has been version locked at the time it was created.

There are two ways to upgrade:

- Automatically via [Oliv'r](https://olivr.com) (recommended)
- [Manually](manual-upgrade.md)
