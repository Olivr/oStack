apiVersion: builtin
kind: PrefixSuffixTransformer
metadata:
  name: customPrefixer
prefix: "${name}-"
fieldSpecs:
  - apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
    kind: Kustomization
    path: metadata/name
