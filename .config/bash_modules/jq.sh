#!/usr/bin/env bash

# Download jq
if [[ -n $FORCE_INSTALL ]] || ! (command -v jq &> /dev/null); then
  echo -e "${INFO} Downloading jq"

  if [[ $opsys == "darwin" ]]; then jq_opsys="osx"; else jq_opsys=$opsys; fi

  jq_release_url=$(curl -s https://api.github.com/repos/stedolan/jq/releases | grep "browser_download.*${jq_opsys}.*64" | cut -d '"' -f 4 | sort -V | tail -n 1)

  curl -sL -o /tmp/validate-tools/jq "$jq_release_url" && chmod +x /tmp/validate-tools/jq

  # Force using the installed jq
  jq() {
    /tmp/validate-tools/jq "$@"
  }
fi

echo -e "${INFO} Using $(jq --version | head -1)"
