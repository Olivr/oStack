# FAQ

## I deleted a resource manually and now Terraform won't apply anymore

You must tell Terraform the resource should be recreated. In order to do this, use the `terraform state rm` command. This command will cause Terraform to forget about the resource it created, so only use it for resources that are deleted outside of Terraform, or some charges may incur as both yourself and Terraform will forget about this resource but not your cloud provider's billing system! Example:

```sh
terraform state rm module.kube_clusters[\"my-org-staging-1\"].linode_lke_cluster.cluster
```

> Note on latest Mac OS using zsh, you should add `unsetopt nomatch` to your `~/.zshrc`
