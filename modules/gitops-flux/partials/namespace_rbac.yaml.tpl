---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    toolkit.fluxcd.io/tenant: ${namespace}
  name: ${namespace}
  namespace: ${namespace}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    toolkit.fluxcd.io/tenant: ${namespace}
  name: gotk-reconciler
  namespace: ${namespace}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: User
    name: gotk:${namespace}:reconciler
  - kind: ServiceAccount
    name: ${namespace}
    namespace: ${namespace}
