---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: kyverno
  namespace: flux-system
spec:
  interval: 10m
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./${base_dir}/kyverno
  prune: true
  validation: client
  healthChecks:
    - apiVersion: apps/v1
      kind: Deployment
      name: kyverno
      namespace: kyverno
  decryption:
    provider: sops
    secretRef:
      name: sops-gpg

---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: kyverno-policies
  namespace: flux-system
spec:
  dependsOn:
    - name: kyverno
  interval: 5m
  sourceRef:
    kind: GitRepository
    name: flux-system
  path: ./${base_dir}/kyverno/policies
  prune: true
  validation: client
  decryption:
    provider: sops
    secretRef:
      name: sops-gpg
