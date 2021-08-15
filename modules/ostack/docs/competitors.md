# Alternatives to ostack

## Startup

- https://github.com/tommedema/startup-boilerplate
- https://github.com/spy4x/seed
- https://github.com/commitdev/zero

## Infrastructure

- https://www.kubestack.com/
- https://gimlet.io
- https://pico.sh/
- https://github.com/AlexsJones/kube-microcosm
- https://github.com/camptocamp/devops-stack
- https://github.com/short-d/gitops
- https://github.com/microsoft/bedrock

## Related

- https://github.com/xUnholy/k8s-gitops
- https://github.com/equinor/sdp-flux

### Home kubernetes

https://github.com/k8s-at-home/awesome-home-kubernetes https://docs.k8s-at-home.com/

- https://github.com/billimek/k8s-gitops
- https://github.com/carpenike/k8s-gitops
- https://github.com/onedr0p/home-cluster

- https://github.com/vaskozl/home-infra
- https://github.com/anthr76/infra
- https://github.com/Diaoul/home-ops
- https://github.com/nicholaswilde/home-cluster
- https://github.com/wrmilling/k3s-gitops

### Others

- https://github.com/kubernetes-sigs/kubespray Production ready Kubernetes cluster
- https://github.com/cloudogu/k8s-gitops-playground Reproducible infrastructure to showcase GitOps workflows and evaluate different GitOps Operators
- https://github.com/stealthybox/multicluster-gitops Demo gossiping Kubernetes clusters that share routes in a mesh and dns-forward their Services to each other :)

Because of Thanos my metrics from prometheus were moved to Minio running in cluster. Wasn't backing up minio so... those pretty historical graphs are now starting over from scratch. :stuck_out_tongue: Need to setup a sync from in-cluster minio to minio running on external NAS

https://github.com/alexanderisora/startuptoolbox https://github.com/cofounders/legal https://github.com/cristobalcl/awesome-startup-stack https://github.com/forter/security-101-for-saas-startups https://github.com/Ibexoft/awesome-startup-tools-list https://github.com/jasonnoahchoi/awesome-free-startup-resources https://github.com/joelparkerhenderson/pitch-deck https://github.com/KrishMunot/awesome-startup https://github.com/kuchin/awesome-cto https://github.com/leonar15/startup-checklist https://github.com/mmccaff/PlacesToPostYourStartup https://github.com/PolymerSearch/awesome-ycombinator https://github.com/rickyyean/founder-dating-ritual https://github.com/Ro5s/Startup-Starter-Pack https://github.com/slashdotdash/saas-startup-checklist https://github.com/squareboat/growth-hacking-guide https://github.com/stockandawe/saas-startup-cto-checklist https://github.com/theventurecity/data-toolkit https://github.com/trekhleb/promote-your-next-startup

## Terraform stuff

https://github.com/jml/terradiff https://github.com/minamijoyo/tfmigrate

## Kubernetes stuff

Must-have:

- Prometheus / Thanos
- Grafana https://github.com/billimek/k8s-gitops/tree/master/monitoring/grafana
- Jaeger
- Traefik / Istios https://github.com/carpenike/k8s-gitops/tree/master/cluster/crds/traefik
- cert-manager https://github.com/smallstep/step-issuer https://github.com/billimek/k8s-gitops/tree/master/cert-manager
- Flux https://github.com/billimek/k8s-gitops/tree/master/flux-system https://github.com/billimek/k8s-gitops/tree/master/flux-system-extra
- botkube https://github.com/billimek/k8s-gitops/tree/master/monitoring/botkube
- coredns https://github.com/billimek/k8s-gitops/tree/master/kube-system/coredns
- loki https://github.com/billimek/k8s-gitops/tree/master/logs/loki
- https://github.com/renovatebot/renovate

### Backup / DR

- https://github.com/vmware-tanzu/velero
- https://www.kasten.io/product/#product-k10-editions https://www.linode.com/community/questions/21181/how-to-backup-lke-volumes
- https://stash.run/

### Monitoring

- https://thanos.io/

### Serverless

- https://www.openfaas.com/blog/plonk-stack/
- https://knative.dev/
- https://github.com/knix-microfunctions/knix

### Pipeline

https://github.com/fluxcd/flagger https://github.com/werf/werf https://github.com/pipe-cd/pipe https://github.com/devtron-labs/devtron

### Databases

https://schemahero.io/databases/

### Multi tenant

https://github.com/loft-sh/kiosk

### Clean up / Health

- https://github.com/yanc0/untrak
- https://github.com/yogeshkk/K8sPurger
- https://github.com/kubesphere/kubeeye
- https://github.com/FairwindsOps/polaris
- https://github.com/infracloudio/botkube
- https://github.com/billimek/k8s-gitops/tree/master/kube-system/descheduler
- https://github.com/FairwindsOps/Pluto

### Logging

https://github.com/grafana/loki

### Secrets

- https://github.com/elastic/harp
- https://github.com/hashicorp/vault https://github.com/billimek/k8s-gitops/tree/master/kube-system/vault

### Routing

-

### Service mesh

- https://istio.io/
- https://kiali.io/

### Tracing

- https://github.com/jaegertracing/jaeger

### SaaS / Software

- https://www.pagerduty.com/
- https://github.com/lensapp/lens
- https://uptimerobot.com/
- https://www.kubecost.com/pricing

## For my home stuff

- https://github.com/monicahq/monica https://github.com/carpenike/k8s-gitops/tree/master/cluster/apps/default/monica
