# Overview

## Concept

[oStack](https://ostack.io) is a Git-based stack where the whole stack (infrastructure, operations and applications) is represented **as code**, versioned in Git. This makes it easy to know what was/is/will be deployed at any given time, by all the teams.

_oStack_ comes with best practices for [trunk-based development](https://trunkbaseddevelopment.com/) using [short-lived "feature" branches](https://trunkbaseddevelopment.com/short-lived-feature-branches/) just like in the [GitHub flow](https://guides.github.com/introduction/flow/).

## Roles

Throughout _oStack_, we refer to human actors as their role. These are inspired by the [Open Application Model personas](https://github.com/oam-dev/spec/blob/master/introduction.md#personas-introduction). For each of the roles below, _oStack_ also uses a special **lead** role which is used in cases where approvals are required.

### Application Developers

The application developer creates a web application and defines its characteristics.

### Operations Managers

The operation manager or the platform itself instantiate that application, and configures it with operational traits, such as autoscaling.

### Infrastructure Managers

The infrastructure manager decides which underlying workload types and operational capabilities are available on the platform to handle the deployment and operations

## Environments

There are two types of environments:

- **Long-lived** environments are "always on" and are not meant to be deleted.
- **Short-lived** environments are only temporary and can exist from a few seconds to a few days.

### <!-- auto_environment-name-production -->Production<!-- auto_environment-name-production -->

<!-- auto_environment-name-production -->Production<!-- auto_environment-name-production --> is a **long-lived** environment running specific versions of each app (usually the latest or second latest released version).

### <!-- auto_environment-name-staging -->Staging<!-- auto_environment-name-staging -->

<!-- auto_environment-name-staging -->Staging<!-- auto_environment-name-staging --> is a **long-lived** environment always running the latest released versions of each app. It is meant to be used for human testing before being deployed to production.

> If CD is enabled, <!-- auto_environment-name-staging -->Staging<!-- auto_environment-name-staging --> and <!-- auto_environment-name-production -->Production<!-- auto_environment-name-production --> will always run the same app versions, but <!-- auto_environment-name-staging -->Staging<!-- auto_environment-name-staging --> will always contain test data.

### Pull requests

For each pull request (PR) in an [apps](#apps) repo, a **short-lived** environment is created to be used for human testing. It is deleted when the PR is merged or closed.

### Tests

Some tests (integration, load, etc.) may need to run in a specific environment, that is created when the test starts and destroyed once the test is complete. These are **short-lived**.

## Kubernetes clusters

Out of the box, _oStack_ creates one Kubernetes (k8s) cluster per long-lived environment. This means 2 clusters are provisioned: [production](#production) and [staging](#staging).

The staging cluster is also used to host all short-lived environments.

## Repositories

```text
        Stack Layers              Repositories

+--------------------------+
|      cloud provider      <----- infra
|                          |
| +----------------------+ |
| |      k8s cluster     <------- ops
| |                      | |
| | +------------------+ | |
| | |    application   <--------- apps
| | +------------------+ | |
| |                      | |
| +----------------------+ |
|                          |
+--------------------------+
```

### infra

This repo contains the current state of all pieces of infrastructure, including the provisioning of Kubernetes clusters.

- **Methodology**: [Infrastructure-as-code](https://www.hashicorp.com/resources/what-is-infrastructure-as-code)
- **Main technologies**: [Terraform](https://www.terraform.io/intro/index.html), [Terraform Cloud](https://www.hashicorp.com/products/terraform/editions/cloud)

### ops

This repo contains the current state of everything that is deployed **inside** Kubernetes clusters.

- **Methodology**: [GitOps](https://www.weave.works/technologies/gitops/) ([pull-based](https://www.weave.works/blog/why-is-a-pull-vs-a-push-pipeline-important))
- **Main technologies**: [Kustomize](https://kustomize.io/), [GitOps Toolkit](https://toolkit.fluxcd.io/)
- **Example structure**:

  ```text
  bases
  ├─ my-app
  │  └─ kustomization.yaml
  └─ ...
  overlays
  ├─ production
  │  ├─ my-app
  │  │  ├─ kustomization.yaml
  │  │  └─ service.yaml
  │  └─ ...
  ├─ staging
  │  ├─ my-app
  │  │  └─ kustomization.yaml
  │  └─ ...
  └─ ...
  ```

### apps

This repo contains the current state of your application along with every version of it.

- **Methodology**: [DevOps](https://newrelic.com/devops/what-is-devops)
- **Main technologies**: [Nx](https://nx.dev/), [Tilt](https://tilt.dev/), [Kind](https://kind.sigs.k8s.io/)
- **Example structure**:

  ```text
  apps
  ├─ my-app
  │  ├─ deploy
  │  │  ├─ deployment.yaml
  │  │  └─ service.yaml
  │  ├─ src
  │  │  └─ ...
  │  └─ ...
  └─ ...
  ...
  ```

## workspaces

The default repo templates are structured as monorepos, so most startups will use only the default workspace. But, if you want to technically and semantically separate different lines of work or if you don't like monorepos, you can add more workspaces.

Each workspace correspond to a set of repos and their associated resources are prefixed with the workspace name as much as possible.

For example, a workspace for a Growth Hacking line of work might be named "**growth**" and would consist of:

- **growth-apps** repo
- **growth-ops** repo
- **growth-infra** repo (if required)
- **growth** workspace on the **production** k8s cluster
- **growth** workspace on the **staging** k8s cluster
- Any short-lived environment will be prefixed by **growth** (eg. _growth-pr-35_)

## Default flow

The flow described here is what you get out of the box, but many parts can be tweaked.

### Feature development

1. [Application developers](#application-developers) create pull requests on the _apps_ repo.
2. **Automatically**, tests are run to ensure PR's can be merged safely and more tests are run after the merge.

### Release management

3. **Automatically** once a PR is merged, a new release is created as a git tag in the _apps_ repo and Docker images are built from the release code and pushed to the Docker registry.
4. **Automatically**, pull requests to bump the release to the latest version are opened in the _ops_ repo for each long-lived environment.

### Deployment management

5. - _CD enabled_: **Automatically**, each PR created in the previous step is merged.

   - _CD disabled_: [Application operators](#application-operators) can tweak the PR created in the previous step and are responsible for merging it manually.

6. **Automatically**, the changes will be deployed within a few minutes according to your chosen deployment strategy.
