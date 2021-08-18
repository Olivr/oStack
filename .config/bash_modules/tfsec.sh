#!/usr/bin/env bash

# https://github.com/aquasecurity/tfsec/blob/master/utils/gpg_keys/signing.D66B222A3EA4C25D5D1A097FC34ACEFB46EC39CE.asc
declare tfsec_key="D66B222A3EA4C25D5D1A097FC34ACEFB46EC39CE"

# Colors
declare tfsec_params=""
if [[ -n $DISABLE_COLORS ]]; then tfsec_params="--no-color"; fi

# Download tfsec
if [[ -n $FORCE_INSTALL ]] || ! (command -v tfsec &> /dev/null); then
  echo -e "${INFO} Downloading tfsec"
  tfsec_release_base_url=https://github.com/aquasecurity/tfsec/releases/latest/download/
  tfsec_release_filename=tfsec-${opsys}-amd64
  tfsec_release_sig_filename=tfsec-${opsys}-amd64.D66B222A3EA4C25D5D1A097FC34ACEFB46EC39CE.sig
  tfsec_shasums_filename=tfsec_checksums.txt

  # Download files
  curl -sL -o "/tmp/validate-tools/$tfsec_release_filename" "$tfsec_release_base_url$tfsec_release_filename"
  curl -sL -o "/tmp/validate-tools/$tfsec_shasums_filename" "$tfsec_release_base_url$tfsec_shasums_filename"
  curl -sL -o "/tmp/validate-tools/$tfsec_release_sig_filename" "$tfsec_release_base_url$tfsec_release_sig_filename"

  verify "tfsec" \
    $tfsec_key \
    "/tmp/validate-tools/$tfsec_shasums_filename" \
    "" \
    "/tmp/validate-tools/$tfsec_release_filename" \
    "/tmp/validate-tools/$tfsec_release_sig_filename"

  mv "/tmp/validate-tools/$tfsec_release_filename" "/tmp/validate-tools/tfsec" && chmod +x "/tmp/validate-tools/tfsec"

  # Cleanup
  rm -rf "/tmp/validate-tools/$tfsec_shasums_filename"
  rm -rf "/tmp/validate-tools/$tfsec_release_sig_filename"

  # Force using the installed tfsec
  tfsec() {
    /tmp/validate-tools/tfsec "$@"
  }
fi

echo -e "${INFO} Using tfsec $(tfsec -v | head -1)"
