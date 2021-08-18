#!/usr/bin/env bash

# This script is licensed under http://www.apache.org/licenses/LICENSE-2.0
#
# It takes a directory as its input and will run a set of static analysis checks against a set of Kubernetes yaml files
# It supports automatic installation of missing tools for Linux and Mac (AMD64)
# Use it like ./kube_validate.sh templates/global-ops-github/**
# Or ./kube_validate.sh templates/global-ops-github
#
# Skip check by setting the environment variables:
# SKIP_KUBEVAL
# SKIP_KUSTOMIZE
# SKIP_KUBESCORE
# SKIP_POLARIS
# SKIP_KUBEAUDIT
# SKIP_CHECKOV

set -o errexit
set -o pipefail

if [[ -z "$@" ]]; then
  echo "ERR - You must specify a directory to test"
  exit 1
fi

# ---------------------------------------------------------------------------------------------------------------------
# Install required tools
# ---------------------------------------------------------------------------------------------------------------------
# Determine OS type
if [[ "$OSTYPE" == linux* ]]; then
  opsys=linux
elif [[ "$OSTYPE" == darwin* ]]; then
  opsys=darwin
fi

mkdir -p /tmp/validate-tools
PATH=$PATH:/tmp/validate-tools

if [[ -z "$SKIP_KUBEVAL" ]] && !(command -v kubeval &> /dev/null); then
  echo "INFO - Downloading kubeval"
  curl -sL https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-${opsys}-amd64.tar.gz | tar zxf - -C /tmp/validate-tools
fi

if [[ -z "$SKIP_KUSTOMIZE" ]] && !(command -v kustomize &> /dev/null); then
  echo "INFO - Downloading kustomize"
  kustomize_release_url=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases | grep browser_download.*${opsys}_amd64 | cut -d '"' -f 4 | sort -V | tail -n 1)
  curl -sL $kustomize_release_url | tar zxf - -C /tmp/validate-tools
fi

if [[ -z "$SKIP_KUBESCORE" ]] && !(command -v kube-score &> /dev/null); then
  echo "INFO - Downloading kube-score"
  kubescore_release_url=$(curl -s https://api.github.com/repos/zegl/kube-score/releases | grep browser_download.*${opsys}_amd64 | cut -d '"' -f 4 | sort -V | tail -n 1)
  curl -sL $kubescore_release_url | tar zxf - -C /tmp/validate-tools
fi

if [[ -z "$SKIP_POLARIS" ]] && !(command -v polaris &> /dev/null); then
  echo "INFO - Downloading polaris"
  curl -sL https://github.com/fairwindsops/polaris/releases/latest/download/polaris_${opsys}_amd64.tar.gz | tar zxf - -C /tmp/validate-tools
fi

if [[ -z "$SKIP_KUBEAUDIT" ]] && !(command -v kubeaudit &> /dev/null); then
  echo "INFO - Downloading kubeaudit"
  kubeaudit_release_url=$(curl -s https://api.github.com/repos/Shopify/kubeaudit/releases | grep browser_download.*${opsys}_amd64 | cut -d '"' -f 4 | sort -V | tail -n 1)
  curl -sL $kubeaudit_release_url | tar zxf - -C /tmp/validate-tools
fi

checkov_params='--quiet --compact --framework=kubernetes --config-file /src/.config/.checkov.yaml'
checkov="checkov $checkov_params -d "
if [[ -z "$SKIP_CHECKOV" ]] && !(command -v checkov &> /dev/null); then
  if command -v docker &> /dev/null; then
    checkov="docker run -v "$(pwd)":/src bridgecrew/checkov $checkov_params -d /src/"
  elif command -v pip3 &> /dev/null; then
    echo "INFO - Installing checkov with PIP"
    pip3 install checkov
  elif command -v brew &> /dev/null; then
    echo "INFO - Installing checkov with Homebrew"
    brew install checkov
  else
    echo "ERR - Cannot install checkov automatically"
    exit 1
  fi
fi

# Install Flux CRDs to be used with kubeval
if [[ -z "$SKIP_KUBEVAL" ]]; then
  mkdir -p /tmp/validate-tools/flux-crd-schemas/master-standalone-strict
  if [[ ! $(find /tmp/validate-tools/flux-crd-schemas/master-standalone-strict -type f -name '*.json' | grep .) ]]; then
    echo "INFO - Downloading Flux OpenAPI schemas"
    curl -sL https://github.com/fluxcd/flux2/releases/latest/download/crd-schemas.tar.gz | tar zxf - -C /tmp/validate-tools/flux-crd-schemas/master-standalone-strict
  fi
fi

# ---------------------------------------------------------------------------------------------------------------------
# Validate single files
# ---------------------------------------------------------------------------------------------------------------------
# kubeval
if [[ -z "$SKIP_KUBEVAL" ]]; then
  echo "INFO - Validating with kubeval"
  kubeval --ignore-missing-schemas --strict --additional-schema-locations=file:///tmp/validate-tools/flux-crd-schemas -d "$@"
fi

if [[ -z "$SKIP_KUBESCORE" || -z "$SKIP_KUBEAUDIT" ]]; then
find "$@" -type f \( -iname '*.yaml' -o -iname '*.yml' \) -print0 | while IFS= read -r -d $'\0' file;
  do
    # kube-score
    if [[ -z "$SKIP_KUBESCORE" ]]; then
      echo "INFO - Validating $file with kube-score"
      kube-score score "$file"
    fi

    # kubeaudit
    if [[ -z "$SKIP_KUBEAUDIT" ]]; then
      echo "INFO - Validating $file with kubeaudit"
      kubeaudit all -p logrus -f "$file"
    fi
  done
fi

# polaris
if [[ -z "$SKIP_POLARIS" ]]; then
  echo "INFO - Validating with polaris"
  polaris audit --format=pretty --color=false --set-exit-code-on-danger --only-show-failed-tests --audit-path "$@" | grep -v -e '^$'
fi

# checkov
if [[ -z "$SKIP_CHECKOV" ]]; then
  echo "INFO - Validating with checkov"
  $checkov$@
fi

# ---------------------------------------------------------------------------------------------------------------------
# Validate kustomizations
# ---------------------------------------------------------------------------------------------------------------------
rm -rf /tmp/kustomize.*.yaml # Clean up previous runs
if [[ -z "$SKIP_KUSTOMIZE" ]]; then
  find "$@" -type f -name kustomization.yaml -print0 | while IFS= read -r -d $'\0' file;
  do
    echo "INFO - Validating kustomization $file"
    kustomize_build=$(file=$(mktemp /tmp/kustomize.XXX); mv $file $file.yaml; echo $file.yaml)

    kustomize build "${file/%"kustomization.yaml"}" --load-restrictor=LoadRestrictionsNone --reorder=legacy > $kustomize_build

    if [[ -z "$SKIP_KUBEVAL" ]]; then kubeval --ignore-missing-schemas --strict --additional-schema-locations=file:///tmp/validate-tools/flux-crd-schemas $kustomize_build; fi
    if [[ -z "$SKIP_KUBESCORE" ]]; then kube-score score $kustomize_build; fi
    if [[ -z "$SKIP_POLARIS" ]]; then polaris audit --format=pretty --color=false --set-exit-code-on-danger --only-show-failed-tests --audit-path $kustomize_build | grep -v -e '^$'; fi
    if [[ -z "$SKIP_CHECKOV" ]]; then $checkov$kustomize_build; fi
    if [[ -z "$SKIP_KUBEAUDIT" ]]; then kubeaudit all -p logrus -f $kustomize_build; fi

    rm -rf $kustomize_build
  done
fi
