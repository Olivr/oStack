# This file is a placeholder
# It can be deleted safely once Kubernetes resources are added in this folder
# Don't forget to modify kustomization.yaml when you do so
apiVersion: v1
involvedObject:
  apiVersion: v1
  kind: Namespace
  namespace: ${namespace}
  name: ${namespace}
kind: Event
message: ${repo} is ready
metadata:
  name: ${namespace}-${repo}-initialized
reason: info
type: Normal
