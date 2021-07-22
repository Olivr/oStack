apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: gitops-repo
spec:
  path: ./${environment}
