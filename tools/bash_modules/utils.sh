#!/usr/bin/env bash

set -o errexit
set -o pipefail

# ---------------------------------------------------------------------------------------------------------------------
# Check for errors preventing script to run properly
# ---------------------------------------------------------------------------------------------------------------------
if [[ -z $1 ]]; then
  echo "You must specify a directory to test"
  exit 1
fi

# Module absolute path
declare module
module=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
module=${module%/}

if [[ ! -d "$module" ]]; then
  echo "Cannot find directory $module"
  exit 1
fi

if [[ -n $FORCE_VERIFY_DOWNLOAD ]] && ! ( (command -v gpg &> /dev/null) && (command -v shasum &> /dev/null) ); then
  echo "FORCE_VERIFY_DOWNLOAD is set but gpg and/or shasum are not installed"
  exit 1
fi

# Prepare temp path
mkdir -p /tmp/validate-tools
PATH=$PATH:/tmp/validate-tools

# Determine OS type
if [[ "$OSTYPE" == linux* ]]; then
  OPSYS="linux"
elif [[ "$OSTYPE" == darwin* ]]; then
  OPSYS="darwin"
fi

# ---------------------------------------------------------------------------------------------------------------------
# Common functions
# ---------------------------------------------------------------------------------------------------------------------
# Display a message on the terminal
show () {
  local type=$1           # Message type
  local message="${*:2}"  # Message to display

  local INFO="\033[0;36mINFO\033[0m -"
  local PASS="\033[0;32mPASS\033[0m -"
  local WARN="\033[0;33mWARN\033[0m -"
  local ERR="\033[0;31mERR\033[0m -"

  if [[ -n $DISABLE_COLORS ]]; then
    # Shellcheck wants to use an associative array but it is not available on bash 3.2 (default on Mac)
    # shellcheck disable=SC2034
    local INFO="INFO -"
    # shellcheck disable=SC2034
    local PASS="PASS -"
    # shellcheck disable=SC2034
    local WARN="WARN -"
    # shellcheck disable=SC2034
    local ERR="ERR -"
  fi

  if [[ $OUTPUT_LOG_LEVEL == "PASS" && (-z $type || $type == "INFO") ]]; then return;
  elif [[ $OUTPUT_LOG_LEVEL == "WARN" && (-z $type || $type == "INFO" || $type == "PASS") ]]; then return;
  elif [[ $OUTPUT_LOG_LEVEL == "ERR" && (-z $type || $type == "INFO" || $type == "PASS" || $type == "WARN") ]]; then return;
  else
    if [[ -z $type ]]; then
      echo -e "$type$message"
    elif [[ -z ${!type} ]]; then
      echo -e "$type - $message"
    else
      echo -e "${!type} $message"
    fi
  fi
}

# This function finds a config file given the filename(s) given as arguments in the most common directories
find_config () {
  local names=("${@}")    # Config names

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
        show INFO "Configuration found in $lookup_path/$name" >&2
        break 2
      fi
    done
  done

  echo "$config"
}

# This function converts local path arguments to be used as mounted paths
docker_run () {
  local docker_image=$1   # Docker image name
  local args=("${@:2}")   # Arguments to pass to the program

  checkov_params=()
  docker_params=()

  for arg in "${args[@]}"; do
    if [[ $arg == "/"* ]]; then
      new_arg="/src/$(basename "$arg")"
      docker_params+=("-v" "$arg:$new_arg")
      checkov_params+=("$new_arg")
    else checkov_params+=("$arg")
    fi
  done

  docker run "${docker_params[@]}" "$docker_image" "${checkov_params[@]}"
}

# This function verifies if a file is signed (and valid)
verify () {
  local name=$1              # Friendly name for info/error messages
  local key_fingerprint=$2   # Public key fingerprint (must be imported already)
  local release_file=$3      # Release file to verify
  local release_sig_file=$4  # Signature of the release file
  local shasums_file=$5      # Checksums file
  local shasums_sig_file=$6  # Signature of the checksums

  # Verify signatures
  if [[ -n $shasums_sig_file || $release_sig_file ]]; then

    # If GPG and shasum are installed, proceed with checksum verification
    if (command -v gpg &> /dev/null); then

      # Proceed only if key is already imported
      if (gpg --list-keys "$key_fingerprint" &> /dev/null); then

        # Verify release signature
        if [[ -n $release_sig_file && -n $release_file ]]; then
          if (gpg --verify "$release_sig_file" "$release_file" &> /dev/null); then
            show INFO "$(basename "$release_file") signature verified"
          else
            show ERR "$release_file is not signed by $name ($key_fingerprint)"
            exit 1
          fi
        fi

        # Verify checksum signature
        if [[ -n $shasums_sig_file && $shasums_file ]]; then
          if (gpg --verify "$shasums_sig_file" "$shasums_file" &> /dev/null); then
            show INFO "$(basename "$shasums_file") signature verified"
          else
            show ERR "$shasums_file is not signed by $name ($key_fingerprint)"
            exit 1
          fi
        fi

      else
        show WARN "$name's public key is not present on your system"

        # Continue if FORCE_VERIFY_DOWNLOAD is not set
        if [[ -z $FORCE_VERIFY_DOWNLOAD ]]; then
          show WARN "Proceeding without verifying signature for $name"
        else
          show ERR "Cannot proceed because FORCE_VERIFY_DOWNLOAD is set"
          exit 1
        fi
      fi
    fi
  fi

  # Verify checksum
  if [[ -n $shasums_file && $release_file ]]; then
    if (command -v shasum &> /dev/null); then
      if (< "$shasums_file" grep "$(shasum -a 256 "$release_file" | cut -d ' ' -f 1)" &> /dev/null); then
        show INFO "$(basename "$release_file") checksum verified"
      else
        show ERR "$(basename "$release_file") does not match a checksum in $(basename "$shasums_file")"
        exit 1
      fi
    elif [[ -z $FORCE_VERIFY_DOWNLOAD ]]; then
        show WARN "Proceeding without verifying checksum for $name"
    else
      show ERR "Cannot proceed because FORCE_VERIFY_DOWNLOAD is set"
      exit 1
    fi
  fi
}

# ---------------------------------------------------------------------------------------------------------------------
# Import public keys to GPG
# ---------------------------------------------------------------------------------------------------------------------
if [[ -n $IMPORT_KEYS_BASE64 ]]; then
  if command -v gpg &> /dev/null; then
    echo -n "$IMPORT_KEYS_BASE64" | base64 -d | gpg --quiet --import
  else
    show ERR "IMPORT_KEYS_BASE64 is set but gpg is not installed"
    exit 1
  fi
fi

if [[ -n $IMPORT_KEYS_DIR ]]; then
  if [[ -d "$IMPORT_KEYS_DIR" ]]; then
    if command -v gpg &> /dev/null; then
      gpg --import --quiet "${IMPORT_KEYS_DIR%/}"/*
    else
      show ERR "IMPORT_KEYS_DIR is set but gpg is not installed"
      exit 1
    fi
  else
    show ERR "$IMPORT_KEYS_DIR does not exist"
    exit 1
  fi
fi
# ---------------------------------------------------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------------------------------------------------
export OPSYS
export module
export PATH
