---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
%{ for path in paths ~}
  - "../../../../${base_dir}/${tenants_dir}/${path}"
%{ endfor ~}
patches:
  - path: ${tenants_dir}-patch.yaml
    target:
      kind: Kustomization
      labelSelector: ostack.io/type=gitops-repo
transformers:
  - prefix-kustomization.yaml
