apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: flux-multi-tenancy
spec:
  validationFailureAction: enforce
  rules:
    - name: serviceAccountName
      exclude:
        resources:
          namespaces:
            - flux-system
%{ for tenant in excluded_tenants ~}
            - "${tenant}"
%{ endfor ~}
      match:
        resources:
          kinds:
            - Kustomization
            - HelmRelease
      validate:
        message: ".spec.serviceAccountName is required"
        pattern:
          spec:
            serviceAccountName: "?*"
    - name: sourceRefNamespace
      exclude:
        resources:
          namespaces:
            - flux-system
      match:
        resources:
          kinds:
            - Kustomization
            - HelmRelease
      validate:
        message: "spec.sourceRef.namespace must be the same as metadata.namespace"
        deny:
          conditions:
            - key: "{{request.object.spec.sourceRef.namespace}}"
              operator: NotEquals
              value: "{{request.object.metadata.namespace}}"
