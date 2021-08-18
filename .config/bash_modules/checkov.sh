#!/usr/bin/env bash

# Download checkov
if [[ -n $FORCE_INSTALL ]] || ! (command -v checkov &> /dev/null); then
  if (command -v docker &> /dev/null) && (docker version &> /dev/null); then
    checkov() {
      docker_run bridgecrew/checkov "$@"
    }

  elif command -v pip3 &> /dev/null; then
    echo -e "${INFO} Installing checkov with PIP"
    pip3 install -U checkov

  elif command -v brew &> /dev/null; then
    echo -e "${INFO} Installing checkov with Homebrew"
    brew install checkov

  else
    echo -e "${ERR} Cannot install checkov automatically"
    exit 1
  fi
fi

echo -e "${INFO} Using checkov $(checkov --version | head -1)"
