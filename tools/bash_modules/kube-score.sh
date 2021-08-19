#!/usr/bin/env bash

# Download kubescore
if [[ -n $FORCE_INSTALL ]] || ! (command -v kube-score &> /dev/null); then
  show INFO "Downloading kubescore"

  kubescore_releases=$(mktemp /tmp/validate-tools/kubescore.releases.XXX)
  curl -s https://api.github.com/repos/zegl/kube-score/releases -o "$kubescore_releases"

  kubescore_shasums_filename="checksums.txt"
  kubescore_shasums_url=$(grep "browser_download.*${kubescore_shasums_filename}" < "$kubescore_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  kubescore_release_url=$(grep "browser_download.*${OPSYS}_amd64" < "$kubescore_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  kubescore_release_base_url=${kubescore_shasums_url%"$kubescore_shasums_filename"}
  kubescore_release_filename=${kubescore_release_url#"$kubescore_release_base_url"}

  # Download files
  curl -sL -o "/tmp/validate-tools/$kubescore_release_filename" "$kubescore_release_url"
  curl -sL -o "/tmp/validate-tools/$kubescore_shasums_filename" "$kubescore_shasums_url"

  verify "kubescore" \
    "" \
    "/tmp/validate-tools/$kubescore_release_filename" \
    "" \
    "/tmp/validate-tools/$kubescore_shasums_filename"

  tar zxf "/tmp/validate-tools/$kubescore_release_filename" -C /tmp/validate-tools

  # Cleanup
  rm -rf "/tmp/validate-tools/$kubescore_release_filename"
  rm -rf "/tmp/validate-tools/$kubescore_shasums_filename"

  # Force using the installed kubescore
  kubescore() {
    /tmp/validate-tools/kube-score "$@"
  }
fi

show INFO "Using kube-score $(kube-score version | head -1)"
