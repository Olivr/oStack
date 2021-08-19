#!/usr/bin/env bash
declare kubeval_params=("--ignored-path-patterns" "(^|/)\." "--ignore-missing-schemas" "--strict" "--additional-schema-locations" "file:///tmp/validate-tools/flux-crd-schemas")

# Download kubeval
if [[ -n $FORCE_INSTALL ]] || ! (command -v kubeval &> /dev/null); then
  show INFO "Downloading kubeval"

  kubeval_release_base_url="https://github.com/instrumenta/kubeval/releases/latest/download/"
  kubeval_release_filename="kubeval-${OPSYS}-amd64.tar.gz"
  kubeval_shasums_filename="checksums.txt"

  # Download files
  curl -sL -o "/tmp/validate-tools/$kubeval_release_filename" "$kubeval_release_base_url$kubeval_release_filename"
  curl -sL -o "/tmp/validate-tools/$kubeval_shasums_filename" "$kubeval_release_base_url$kubeval_shasums_filename"

  verify "kubeval" \
    "" \
    "/tmp/validate-tools/$kubeval_release_filename" \
    "" \
    "/tmp/validate-tools/$kubeval_shasums_filename"

  tar zxf "/tmp/validate-tools/$kubeval_release_filename" -C /tmp/validate-tools

  # Cleanup
  rm -rf "/tmp/validate-tools/$kubeval_release_filename"
  rm -rf "/tmp/validate-tools/$kubeval_shasums_filename"

  # Force using the installed kubeval
  kubeval() {
    /tmp/validate-tools/kubeval "$@"
  }
fi

# Install Flux CRDs to be used with kubeval
mkdir -p /tmp/validate-tools/flux-crd-schemas
if ! find /tmp/validate-tools/flux-crd-schemas -type f -name '*.json' | grep -q "."; then
  show INFO "Downloading Flux OpenAPI schemas"
  curl -sL https://github.com/fluxcd/flux2/releases/latest/download/crd-schemas.tar.gz | tar zxf - -C /tmp/validate-tools/flux-crd-schemas
fi

show INFO "Using kubeval $(kubeval --version | head -1)"

# ---------------------------------------------------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------------------------------------------------
export kubeval_params
