#!/usr/bin/env bash
declare kubeaudit_params=("all" "-p" "logrus")

# Download kubeaudit
if [[ -n $FORCE_INSTALL ]] || ! (command -v kubeaudit &> /dev/null); then
  show INFO "Downloading kubeaudit"

  kubeaudit_releases=$(mktemp /tmp/validate-tools/kubeaudit.releases.XXX)
  curl -s https://api.github.com/repos/Shopify/kubeaudit/releases -o "$kubeaudit_releases"

  kubeaudit_shasums_filename=$(grep "\"name\":.*checksums.txt" < "$kubeaudit_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  kubeaudit_shasums_url=$(grep "browser_download.*${kubeaudit_shasums_filename}" < "$kubeaudit_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  kubeaudit_release_url=$(grep "browser_download.*${OPSYS}_amd64" < "$kubeaudit_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  kubeaudit_release_base_url=${kubeaudit_shasums_url%"$kubeaudit_shasums_filename"}
  kubeaudit_release_filename=${kubeaudit_release_url#"$kubeaudit_release_base_url"}

  # Download files
  curl -sL -o "/tmp/validate-tools/$kubeaudit_release_filename" "$kubeaudit_release_url"
  curl -sL -o "/tmp/validate-tools/$kubeaudit_shasums_filename" "$kubeaudit_shasums_url"

  verify "kubeaudit" \
    "" \
    "/tmp/validate-tools/$kubeaudit_release_filename" \
    "" \
    "/tmp/validate-tools/$kubeaudit_shasums_filename"

  tar zxf "/tmp/validate-tools/$kubeaudit_release_filename" -C /tmp/validate-tools

  # Cleanup
  rm -rf "/tmp/validate-tools/$kubeaudit_release_filename"
  rm -rf "/tmp/validate-tools/$kubeaudit_shasums_filename"

  # Force using the installed kubeaudit
  kubeaudit() {
    /tmp/validate-tools/kubeaudit "$@"
  }
fi

show INFO "Using kubeaudit $(kubeaudit version | head -1)"

# ---------------------------------------------------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------------------------------------------------
export kubeaudit_params
