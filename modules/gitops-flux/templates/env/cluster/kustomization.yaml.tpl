apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../../${base_dir}
  - sync.yaml
patchesStrategicMerge:
  - flux-system-patch.yaml
