#!/usr/bin/env bash

# Download gotestsum
if [[ -n $FORCE_INSTALL ]] || ! (command -v gotestsum &> /dev/null); then
  show INFO "Downloading gotestsum"

  gotestsum_releases=$(mktemp /tmp/validate-tools/gotestsum.releases.XXX)
  curl -s https://api.github.com/repos/gotestyourself/gotestsum/releases -o "$gotestsum_releases"

  gotestsum_shasums_filename=$(grep "\"name\":.*checksums.txt" < "$gotestsum_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  gotestsum_shasums_url=$(grep "browser_download.*${gotestsum_shasums_filename}" < "$gotestsum_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  gotestsum_release_url=$(grep "browser_download.*${OPSYS}_amd64" < "$gotestsum_releases" | cut -d '"' -f 4 | sort -V | tail -n 1)
  gotestsum_release_base_url=${gotestsum_shasums_url%"$gotestsum_shasums_filename"}
  gotestsum_release_filename=${gotestsum_release_url#"$gotestsum_release_base_url"}

  echo $gotestsum_release_filename
  # Download files
  curl -sL -o "/tmp/validate-tools/$gotestsum_release_filename" "$gotestsum_release_url"
  curl -sL -o "/tmp/validate-tools/$gotestsum_shasums_filename" "$gotestsum_shasums_url"

  verify "gotestsum" \
    "" \
    "/tmp/validate-tools/$gotestsum_release_filename" \
    "" \
    "/tmp/validate-tools/$gotestsum_shasums_filename"

  tar zxf "/tmp/validate-tools/$gotestsum_release_filename" -C /tmp/validate-tools

  # Cleanup
  rm -rf "/tmp/validate-tools/$gotestsum_release_filename"
  rm -rf "/tmp/validate-tools/$gotestsum_shasums_filename"

  # Force using the installed gotestsum
  gotestsum() {
    /tmp/validate-tools/gotestsum "$@"
  }
fi

show INFO "Using gotestsum $(gotestsum --version | head -1)"
