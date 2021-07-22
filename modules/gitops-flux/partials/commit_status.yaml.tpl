---
apiVersion: notification.toolkit.fluxcd.io/v1beta1
kind: Provider
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  type: ${provider}
  address: ${repo_http_url}
  secretRef:
    name: ${secret_name}

---
apiVersion: notification.toolkit.fluxcd.io/v1beta1
kind: Alert
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  providerRef:
    name: ${name}
  eventSeverity: info
  eventSources:
    - kind: Kustomization
      name: "*"
      %{ if source_namespace != "" }namespace: ${source_namespace}%{ endif ~}
