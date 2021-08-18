#!/usr/bin/env bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# This script is licensed under http://www.apache.org/licenses/LICENSE-2.0
#
# It takes a directory as its input and will run a set of static analysis checks against a set of Kubernetes yaml files
# It supports automatic installation of missing tools for Linux and Mac (AMD64)
# Use it like ./tf_validate.sh modules/backend-tfe
#
# Available options:
# DISABLE_COLORS=1          Disable colors
# FORCE_GPG_VERIFY=1        Force validating signatures for downloads that support it
# FORCE_INSTALL=1           Force installing tools (mainly to ensure they are used in their latest versions)
# IMPORT_BASE64_KEYS=1      Import public keys for checksum validation. Accepts one base64 encoded string of all keys
# SKIP_CHECKOV=1            Skip checkov tests
# SKIP_TERRAFORM_FMT=1      Skip terraform format check
# SKIP_TERRAFORM_VALIDATE=1 Skip terraform validate
# SKIP_TFLINT=1             Skip tflint
# SKIP_TFSEC=1              Skip tfsec

# shellcheck disable=SC1091
source "$SCRIPT_DIR/bash_modules/utils.sh"

# ---------------------------------------------------------------------------------------------------------------------
# Install required tools
# ---------------------------------------------------------------------------------------------------------------------
if [[ -z $SKIP_TERRAFORM_FMT || -z $SKIP_TERRAFORM_VALIDATE ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/bash_modules/jq.sh"
fi

if [[ -z $SKIP_TERRAFORM_FMT || -z $SKIP_TERRAFORM_VALIDATE ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/bash_modules/terraform.sh"
fi

if [[ -z $SKIP_TFLINT ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/bash_modules/tflint.sh"
fi

if [[ -z $SKIP_TFSEC ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/bash_modules/tfsec.sh"
fi

if [[ -z $SKIP_CHECKOV ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/bash_modules/checkov.sh"
fi

# ---------------------------------------------------------------------------------------------------------------------
# Validate single files
# ---------------------------------------------------------------------------------------------------------------------
# terraform fmt
if [[ -z $SKIP_TERRAFORM_FMT ]]; then
  echo -e "TEST - Validating format with Terraform"
  terraform -chdir="$module" fmt -check -recursive $terraform_params
fi

# tflint
if [[ -z $SKIP_TFLINT ]]; then
  echo -e "TEST - Validating format with tflint"
  tflint --init --config=.config/.tflint.hcl
  tflint --format=compact --config=.config/.tflint.hcl "$module"
fi

# tfsec
if [[ -z $SKIP_TFSEC ]]; then
  echo -e "TEST - Analyzing with tfsec"
  tfsec --concise-output $tfsec_params "$module"
fi

# terraform init
if [[ -z $SKIP_TERRAFORM_VALIDATE ]]; then
  echo -e "${INFO} Initialize module"
  terraform -chdir="$module" init $terraform_params > /dev/null
fi

# terraform validate
if [[ -z $SKIP_TERRAFORM_VALIDATE ]]; then
  echo "TEST - Validating with Terraform"
  terraform -chdir="$module" validate $terraform_params > /dev/null
fi

# checkov
if [[ -z $SKIP_CHECKOV ]]; then
  echo "TEST - Analyzing with checkov"
  checkov_config=$(find_config .checkov.yml .checkov.yaml)
  if [[ -n $checkov_config ]]; then checkov_config="--config-file ""$checkov_config"""; fi
  checkov --quiet --framework terraform -d "$module" $checkov_config
fi
