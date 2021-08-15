# Bootstrap your infrastructure

This repo contains a template to bootstrap your organization's infrastructure using [oStack](https://ostack.io).

It is part of our [Get Started](https://github.com/Olivr/oStack/blob/docs/get-started.md) guide.

## How to use it

1. Remove the current README.md file, so your repo now displays the content of docs/README.md

2. Edit the configuration in [oStack.tf](oStack.tf)

> If your Terraform Cloud organization or your GitHub organization do not have the same names as `organization_name`, don't forget to edit `backend_organization_name` and `vcs_organization_name` respectively

## Costs

The default configuration sets up a Kubernetes cluster with 2 nodes.

This translates to a cost of **$20** per month (prorated).

- [Get $100 credit valid for 60-days with a new **Linode** account](https://www.linode.com/?r=b1756a97d0b7a32dd4137465808b36d705698cbc)
- [Get $100 credit valid for 60-days with a new **DigitalOcean** account](https://m.do.co/c/647d31cfbfd7)

Of course, as you change your configuration and your stack evolves, these costs will evolve as well 🤷

## Warning

Never set the apply method to `Auto apply` in Terraform Cloud for this repo, it would be too dangerous because it manages your whole infrastructure. You should always review every plan before applying.
