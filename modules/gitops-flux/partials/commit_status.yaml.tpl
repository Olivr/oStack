---
apiVersion: notification.toolkit.fluxcd.io/v1beta1
kind: Provider
metadata:
  name: "${name}"
  namespace: flux-system
%{if namespace != "flux-system" ~}
  labels:
    toolkit.fluxcd.io/tenant: "${namespace}"
%{endif~}
spec:
  type: "${provider}"
  address: "${repo_http_url}"
  secretRef:
    name: "${secret_name}"

---
apiVersion: notification.toolkit.fluxcd.io/v1beta1
kind: Alert
metadata:
  name: "${name}"
  namespace: flux-system
%{if namespace != "flux-system" ~}
  labels:
    toolkit.fluxcd.io/tenant: "${namespace}"
%{endif~}
spec:
  providerRef:
    name: "${name}"
  eventSeverity: info
  eventSources:
    - kind: Kustomization
      name: "*"
%{ if namespace != "flux-system" ~}
      namespace: "${namespace}"
%{ endif ~}
