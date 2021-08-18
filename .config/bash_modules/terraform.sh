#!/usr/bin/env bash

# https://www.hashicorp.com/security#hashicorps-current-and-previous-pgp-public-keys
declare hashicorp_key="C874011F0AB405110D02105534365D9472D7468F"

# Colors
declare terraform_params=""
if [[ -n $DISABLE_COLORS ]]; then terraform_params="-no-color"; fi

# Download terraform
if [[ -n $FORCE_INSTALL ]] || ! (command -v terraform &> /dev/null); then
  echo -e "${INFO} Downloading terraform"
  terraform_releases=$(mktemp /tmp/validate-tools/terraform.releases.XXX)
  curl -s https://releases.hashicorp.com/terraform/index.json -o "$terraform_releases"

  terraform_release_filename=$(< "$terraform_releases" jq -r '[.versions | with_entries(select(.key | test("^[0-9.]+$")))[]] | sort_by(.version|split(".")|map(tonumber)) | last | .builds[] | select(.os == "'${opsys}'" and .arch == "amd64") | .filename')
  terraform_shasums_filename=$(< "$terraform_releases" jq -r '[.versions | with_entries(select(.key | test("^[0-9.]+$")))[]] | sort_by(.version|split(".")|map(tonumber)) | last | .shasums')
  terraform_shasum_sig_filename=$(< "$terraform_releases" jq -r '[.versions | with_entries(select(.key | test("^[0-9.]+$")))[]] | sort_by(.version|split(".")|map(tonumber)) | last | .shasums_signature')
  terraform_release_url=$(< "$terraform_releases" jq -r '[.versions | with_entries(select(.key | test("^[0-9.]+$")))[]] | sort_by(.version|split(".")|map(tonumber)) | last | .builds[] | select(.os == "'${opsys}'" and .arch == "amd64") | .url')
  terraform_release_base_url=${terraform_release_url%"$terraform_release_filename"}

  # Cleanup
  rm -rf "$terraform_releases"

  # Download files
  curl -sL -o "/tmp/validate-tools/$terraform_release_filename" "$terraform_release_url"
  curl -sL -o "/tmp/validate-tools/$terraform_shasums_filename" "$terraform_release_base_url$terraform_shasums_filename"
  curl -sL -o "/tmp/validate-tools/$terraform_shasum_sig_filename" "$terraform_release_base_url$terraform_shasum_sig_filename"

  verify "Terraform" \
    $hashicorp_key \
    "/tmp/validate-tools/$terraform_shasums_filename" \
    "/tmp/validate-tools/$terraform_shasum_sig_filename" \
    "/tmp/validate-tools/$terraform_release_filename"

  unzip -o -q "/tmp/validate-tools/$terraform_release_filename" -d /tmp/validate-tools

  # Cleanup
  rm -rf "/tmp/validate-tools/$terraform_release_filename"
  rm -rf "/tmp/validate-tools/$terraform_shasums_filename"
  rm -rf "/tmp/validate-tools/$terraform_shasum_sig_filename"

  # Force using the installed Terraform
  terraform() {
    /tmp/validate-tools/terraform "$@"
  }
fi

echo -e "${INFO} Using $(terraform -v | head -1)"
