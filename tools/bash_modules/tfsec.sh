#!/usr/bin/env bash
declare tfsec_params=("--concise-output")

# https://github.com/aquasecurity/tfsec/blob/master/utils/gpg_keys/
declare tfsec_key="D66B222A3EA4C25D5D1A097FC34ACEFB46EC39CE"

# Colors
if [[ -n $DISABLE_COLORS ]]; then tfsec_params+=("--no-color"); fi

# Config
tfsec_config=$(find_config .tfsec/config.json .tfsec/config.yml tfsec.yml tfsec.json .tfsec.yml .tfsec.json)
if [[ -n $tfsec_config ]]; then tfsec_params+=("--config-file" "$tfsec_config"); fi

# Download tfsec
if [[ -n $FORCE_INSTALL ]] || ! (command -v tfsec &> /dev/null); then
  show INFO "Downloading tfsec"
  tfsec_release_base_url="https://github.com/aquasecurity/tfsec/releases/latest/download/"
  tfsec_release_filename="tfsec-${OPSYS}-amd64"
  tfsec_release_sig_filename="tfsec-${OPSYS}-amd64.${tfsec_key}.sig"
  tfsec_shasums_filename="tfsec_checksums.txt"

  # Download files
  curl -sL -o "/tmp/validate-tools/$tfsec_release_filename" "$tfsec_release_base_url$tfsec_release_filename"
  curl -sL -o "/tmp/validate-tools/$tfsec_shasums_filename" "$tfsec_release_base_url$tfsec_shasums_filename"
  curl -sL -o "/tmp/validate-tools/$tfsec_release_sig_filename" "$tfsec_release_base_url$tfsec_release_sig_filename"

  verify "tfsec" \
    $tfsec_key \
    "/tmp/validate-tools/$tfsec_release_filename" \
    "/tmp/validate-tools/$tfsec_release_sig_filename" \
    "/tmp/validate-tools/$tfsec_shasums_filename" \

  mv "/tmp/validate-tools/$tfsec_release_filename" "/tmp/validate-tools/tfsec" && chmod +x "/tmp/validate-tools/tfsec"

  # Cleanup
  rm -rf "/tmp/validate-tools/$tfsec_shasums_filename"
  rm -rf "/tmp/validate-tools/$tfsec_release_sig_filename"

  # Force using the installed tfsec
  tfsec() {
    /tmp/validate-tools/tfsec "$@"
  }
fi

show INFO "Using tfsec $(tfsec -v | head -1)"

# ---------------------------------------------------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------------------------------------------------
export tfsec_params
