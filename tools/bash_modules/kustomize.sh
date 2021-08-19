#!/usr/bin/env bash

# Download kustomize
if [[ -n $FORCE_INSTALL ]] || ! (command -v kustomize &> /dev/null); then
  show INFO "Downloading kustomize"

  kustomize_releases=$(mktemp /tmp/validate-tools/kustomize.releases.XXX)
  curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases -o "$kustomize_releases"

  kustomize_shasums_filename="checksums.txt"
  kustomize_shasums_url=$(grep "browser_download.*${kustomize_shasums_filename}" < "$kustomize_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  kustomize_release_url=$(grep "browser_download.*${OPSYS}_amd64" < "$kustomize_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  kustomize_release_base_url=${kustomize_shasums_url%"$kustomize_shasums_filename"}
  kustomize_release_filename=${kustomize_release_url#"$kustomize_release_base_url"}

  # Download files
  curl -sL -o "/tmp/validate-tools/$kustomize_release_filename" "$kustomize_release_url"
  curl -sL -o "/tmp/validate-tools/$kustomize_shasums_filename" "$kustomize_shasums_url"

  verify "kustomize" \
    "" \
    "/tmp/validate-tools/$kustomize_release_filename" \
    "" \
    "/tmp/validate-tools/$kustomize_shasums_filename"

  tar zxf "/tmp/validate-tools/$kustomize_release_filename" -C /tmp/validate-tools

  # Cleanup
  rm -rf "/tmp/validate-tools/$kustomize_release_filename"
  rm -rf "/tmp/validate-tools/$kustomize_shasums_filename"

  # Force using the installed kustomize
  kustomize() {
    /tmp/validate-tools/kustomize "$@"
  }
fi

show INFO "Using kustomize $(kustomize version | head -1)"
