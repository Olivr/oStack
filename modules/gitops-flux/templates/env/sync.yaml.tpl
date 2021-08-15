---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: "${env_name}-${tenants_dir}"
  namespace: "flux-system"
spec:
  dependsOn:
    - name: kyverno-policies
  interval: 1m
  sourceRef:
    kind: GitRepository
    name: "flux-system"
  path: ./${env_name}/${base_dir}/${tenants_dir}
  prune: true
  validation: client
  decryption:
    provider: sops
    secretRef:
      name: sops-gpg
