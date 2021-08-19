#!/usr/bin/env bash
declare checkov_params=("--quiet")

# Config
checkov_config=$(find_config .checkov.yml .checkov.yaml checkov.yml checkov.yaml)
if [[ -n $checkov_config ]]; then checkov_params+=("--config-file" "$checkov_config"); fi

# Download checkov
if [[ -n $FORCE_INSTALL ]] || ! (command -v checkov &> /dev/null); then
  if (command -v docker &> /dev/null) && (docker version &> /dev/null); then
    checkov() {
      docker_run bridgecrew/checkov "$@"
    }

  elif command -v pip3 &> /dev/null; then
    show INFO "Installing checkov with PIP"
    pip3 install -U checkov > /dev/null

  elif command -v brew &> /dev/null; then
    show INFO "Installing checkov with Homebrew"
    brew install checkov > /dev/null

  else
    show ERR "Cannot install checkov automatically"
    exit 1
  fi
fi

show INFO "Using checkov $(checkov --version | head -1)"

# ---------------------------------------------------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------------------------------------------------
export checkov_params
