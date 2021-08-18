#!/usr/bin/env bash

set -o errexit
set -o pipefail

# Prepare temp path
mkdir -p /tmp/validate-tools
PATH=$PATH:/tmp/validate-tools

# ---------------------------------------------------------------------------------------------------------------------
# Check for errors preventing script to run properly
# ---------------------------------------------------------------------------------------------------------------------
if [[ -z $1 ]]; then
  echo -e "${ERR} You must specify a directory to test"
  exit 1
else
  # Module absolute path
  module=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
fi

if [[ -n $FORCE_GPG_VERIFY ]] && ! ( (command -v gpg &> /dev/null) && (command -v shasum &> /dev/null) ); then
  echo -e "${ERR} FORCE_GPG_VERIFY is set but gpg and/or shasum are not installed"
  exit 1
fi

# ---------------------------------------------------------------------------------------------------------------------
# Import public keys to GPG
# ---------------------------------------------------------------------------------------------------------------------
if [[ -n $IMPORT_BASE64_KEYS ]]; then
  if command -v gpg &> /dev/null; then
    echo -n "$IMPORT_BASE64_KEYS" | base64 -d | gpg --quiet --import
  else
    echo -e "${ERR} IMPORT_BASE64_KEYS is set but gpg is not installed"
    exit 1
  fi
fi

# ---------------------------------------------------------------------------------------------------------------------
# Common functions
# ---------------------------------------------------------------------------------------------------------------------

# Determine OS type
if [[ "$OSTYPE" == linux* ]]; then
  opsys="linux"
elif [[ "$OSTYPE" == darwin* ]]; then
  opsys="darwin"
fi

# Message types
if [[ -z $DISABLE_COLORS ]]; then
  INFO="\033[0;36mINFO\033[0m -"
  WARN="\033[0;33mWARN\033[0m -"
  ERR="\033[0;31mERR\033[0m -"
else
  INFO="INFO -"
  WARN="WARN -"
  ERR="ERR -"
fi

# This function finds a config file given the filename(s) given as arguments in the most common directories
find_config () {
  local names=( "${@}" ) # Config names

  local config=""
  local lookup_paths=(
    "$module"
    "$module/.config"
    "$(pwd)"
    "$(pwd)/.config"
    "$HOME"
    "$HOME/.config"
  )

  for lookup_path in "${lookup_paths[@]}"; do
    for name in "${names[@]}"; do
      if (ls "$lookup_path/$name" &> /dev/null); then
        config="$lookup_path/$name"
        echo -e "${INFO} Configuration found in $lookup_path/$name" >&2
        break 2
      fi
    done
  done

  echo "$config"
}

# This function converts local path arguments to be used as mounted paths
docker_run () {
  local docker_image=$1   # Docker image name
  local args=( "${@:2}" ) # Arguments to pass to the program

  checkov_params=""
  docker_params=""

  for arg in "${args[@]}"; do
    if [[ $arg == "/"* ]]; then
      new_arg="/src/$(basename "$arg")"
      docker_params+=" -v ""$arg"":""$new_arg"""
      checkov_params+=" $new_arg"
    else checkov_params+=" $arg"
    fi
  done

  docker run ${docker_params#" "} "$docker_image" ${checkov_params#" "}
}

# This function verifies if a file is signed (and valid)
verify () {
  local name=$1              # Friendly name for info/error messages
  local key_fingerprint=$2   # Public key fingerprint (must be imported already)
  local shasums_file=$3      # Checksums file
  local shasums_sig_file=$4  # Signature of the checksums
  local release_file=$5      # Release file to verify
  local release_sig_file=$6  # Signature of the release file

  # If GPG and shasum are installed, proceed with checksum verification
  if (command -v gpg &> /dev/null) && (command -v shasum &> /dev/null); then

    # Proceed only if key is already imported
    if (gpg --list-keys "$key_fingerprint" &> /dev/null); then

      # Verify release signature
      if [[ -n $release_sig_file && -n $release_file ]]; then
        if (gpg --verify "$release_sig_file" "$release_file" &> /dev/null); then
          echo -e "${INFO} $(basename "$release_file") signature verified"
        else
          echo -e "${ERR} $release_file is not signed by $name ($key_fingerprint)"
          exit 1
        fi
      fi

      # Verify checksum signature
      if [[ -n $shasums_sig_file && $shasums_file ]]; then
        if (gpg --verify "$shasums_sig_file" "$shasums_file" &> /dev/null); then
          echo -e "${INFO} $(basename "$shasums_file") signature verified"
        else
          echo -e "${ERR} $shasums_file is not signed by $name ($key_fingerprint)"
          exit 1
        fi
      fi

      # Verify checksum
      if [[ -n $shasums_file && $release_file ]]; then
        if (< "$shasums_file" grep "$(shasum -a 256 "$release_file" | cut -d ' ' -f 1)" &> /dev/null); then
          echo -e "${INFO} $(basename "$release_file") checksum verified"
        else
          echo -e "${ERR} $(basename "$release_file") does not match a checksum in $(basename "$shasums_file")"
          exit 1
        fi
      fi

    else
      echo -e "${WARN} $name's public key is not present on your system"

      # Continue if FORCE_GPG_VERIFY is not set
      if [[ -z $FORCE_GPG_VERIFY ]]; then
        echo -e "${WARN} Proceeding without verifying $name download"
      else
        echo -e "${ERR} Cannot proceed because FORCE_GPG_VERIFY is set"
        exit 1
      fi
    fi
  fi
}
