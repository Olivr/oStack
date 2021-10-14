---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: "${name}"
  namespace: "flux-system"
spec:
  interval: 1m
  sourceRef:
    kind: GitRepository
    name: "flux-system"
  path: ./${overlay_path}
  prune: true
  validation: client
  decryption:
    provider: sops
    secretRef:
      name: sops-gpg
