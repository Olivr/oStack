#!/usr/bin/env bash

# https://github.com/terraform-linters/tflint/blob/master/8CE69160EB3F2FE9.key
declare tflint_key="2DA7A4B11347B217385231D1131A2054C7B3FB65"

# Download tflint
if [[ -n $FORCE_INSTALL ]] || ! (command -v tflint &> /dev/null); then
  echo -e "${INFO} Downloading tflint"
  tflint_release_base_url=https://github.com/terraform-linters/tflint/releases/latest/download/
  tflint_release_filename=tflint_${opsys}_amd64.zip
  tflint_shasums_filename=checksums.txt
  tflint_shasum_sig_filename=checksums.txt.sig

  # Download files
  curl -sL -o "/tmp/validate-tools/$tflint_release_filename" "$tflint_release_base_url$tflint_release_filename"
  curl -sL -o "/tmp/validate-tools/$tflint_shasums_filename" "$tflint_release_base_url$tflint_shasums_filename"
  curl -sL -o "/tmp/validate-tools/$tflint_shasum_sig_filename" "$tflint_release_base_url$tflint_shasum_sig_filename"

  verify "tflint" \
    $tflint_key \
    "/tmp/validate-tools/$tflint_shasums_filename" \
    "/tmp/validate-tools/$tflint_shasum_sig_filename" \
    "/tmp/validate-tools/$tflint_release_filename"

  unzip -o -q "/tmp/validate-tools/$tflint_release_filename" -d /tmp/validate-tools

  # Cleanup
  rm -rf "/tmp/validate-tools/$tflint_release_filename"
  rm -rf "/tmp/validate-tools/$tflint_shasums_filename"
  rm -rf "/tmp/validate-tools/$tflint_shasum_sig_filename"

  # Force using the installed tflint
  tflint() {
    /tmp/validate-tools/tflint "$@"
  }
fi

echo -e "${INFO} Using tflint $(tflint -v | head -1)"
