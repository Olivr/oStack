apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../${base_dir}
patchesStrategicMerge:
  - flux-system-patch.yaml
patches:
  - path: notifications-patch.yaml
    target:
      kind: Alert
