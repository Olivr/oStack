apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../${base_dir}
patches:
  - path: ${tenants_dir}-patch.yaml
    target:
      kind: Kustomization
      labelSelector: type=gitops-repo
