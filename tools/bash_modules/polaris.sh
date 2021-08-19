#!/usr/bin/env bash
declare polaris_params=("--format=pretty" "--set-exit-code-on-danger" "--only-show-failed-tests")

# Colors
if [[ -n $DISABLE_COLORS ]]; then polaris_params+=("--color=false"); fi

# Config
polaris_config=$(find_config .polaris.yml .polaris.yaml polaris.yml polaris.yaml)
if [[ -n $polaris_config ]]; then polaris_params+=("--config" "$polaris_config"); fi

# Download polaris
if [[ -n $FORCE_INSTALL ]] || ! (command -v polaris &> /dev/null); then
  show INFO "Downloading polaris"

  polaris_releases=$(mktemp /tmp/validate-tools/polaris.releases.XXX)
  curl -s https://api.github.com/repos/FairwindsOps/polaris/releases -o "$polaris_releases"

  polaris_shasums_filename="checksums.txt"
  polaris_shasums_url=$(grep "browser_download.*${polaris_shasums_filename}" < "$polaris_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  polaris_release_url=$(grep "browser_download.*${OPSYS}_amd64" < "$polaris_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  polaris_release_base_url=${polaris_shasums_url%"$polaris_shasums_filename"}
  polaris_release_filename=${polaris_release_url#"$polaris_release_base_url"}

  # Download files
  curl -sL -o "/tmp/validate-tools/$polaris_release_filename" "$polaris_release_url"
  curl -sL -o "/tmp/validate-tools/$polaris_shasums_filename" "$polaris_shasums_url"

  verify "polaris" \
    "" \
    "/tmp/validate-tools/$polaris_release_filename" \
    "" \
    "/tmp/validate-tools/$polaris_shasums_filename"

  tar zxf "/tmp/validate-tools/$polaris_release_filename" -C /tmp/validate-tools

  # Cleanup
  rm -rf "/tmp/validate-tools/$polaris_release_filename"
  rm -rf "/tmp/validate-tools/$polaris_shasums_filename"

  # Force using the installed polaris
  polaris() {
    /tmp/validate-tools/polaris "$@"
  }
fi

show INFO "Using polaris $(polaris version | head -1)"

# ---------------------------------------------------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------------------------------------------------
export polaris_params
