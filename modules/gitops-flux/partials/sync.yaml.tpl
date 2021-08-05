---
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: "${name}"
  namespace: "${namespace}"
%{if namespace != "flux-system" ~}
  labels:
    toolkit.fluxcd.io/tenant: "${namespace}"
%{endif~}
spec:
  interval: 1m
  url: "${repo_ssh_url}"
  ref:
    branch: "${branch_name}"
  secretRef:
    name: "${secret_name}"

---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: "${name}"
  namespace: "${namespace}"
  labels:
    ostack.io/type: "${type}"
%{if namespace != "flux-system" ~}
    toolkit.fluxcd.io/tenant: "${namespace}"
%{endif~}
spec:
  serviceAccountName: "${namespace}"
  interval: 1m
  sourceRef:
    kind: GitRepository
    name: "${name}"
  prune: true
  validation: client
  decryption:
    provider: sops
    secretRef:
      name: sops-gpg
