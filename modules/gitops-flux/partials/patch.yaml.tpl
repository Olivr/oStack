---
$patch: ${patch_type}
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: "${kind}"
metadata:
%{ for k,v in metadata ~}
  ${k}: "${v}"
%{ endfor ~}
%{ if length(spec) > 0 ~}
spec:
%{ for k,v in spec ~}
  ${k}: "${v}"
%{ endfor ~}
%{ endif ~}
