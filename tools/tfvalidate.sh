#!/usr/bin/env bash
# tfvalidate v1.0.0
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#
# This script is licensed under http://www.apache.org/licenses/LICENSE-2.0
#
# It takes a directory as its input and will run a set of static analysis checks against a set of Kubernetes yaml files
# It supports automatic installation of missing tools for Linux and Mac (AMD64)
#
# Use it like ./tf_validate.sh modules/backend-tfe
#
# Available options:
# DISABLE_COLORS=1          Disable colors for this script and as much as possible for the called programs
# FORCE_INSTALL=1           Force installing tools (mainly to ensure they are used in their latest versions)
# FORCE_VERIFY_DOWNLOAD=1   Force validating signatures for downloads that support it
# IMPORT_KEYS_BASE64=""     Import public keys for checksum validation. Accepts one base64 encoded string of all keys
# IMPORT_KEYS_DIR="./keys"  Import public keys for checksum validation. Accepts a path to a directory containing public key files
# OUTPUT_LOG_LEVEL=PASS     Set output log level for this script and as much as possible for the called programs (INFO (default), PASS, WARN, ERR)
# SKIP_CHECKOV=1            Skip running checkov
# SKIP_TERRAFORM_FMT=1      Skip checking format with terraform
# SKIP_TERRAFORM_VALIDATE=1 Skip running terraform validate
# SKIP_TFLINT=1             Skip running tflint
# SKIP_TFSEC=1              Skip running tfsec

source "$SCRIPT_DIR/bash_modules/utils.sh"

show "" "$(printf '=%.0s' {1..80})"
echo "Validating $1"
show "" "$(printf '=%.0s' {1..80})"

# ---------------------------------------------------------------------------------------------------------------------
# Required tools
# ---------------------------------------------------------------------------------------------------------------------
if [[ -z $SKIP_TERRAFORM_FMT || -z $SKIP_TERRAFORM_VALIDATE ]]; then
  source "$SCRIPT_DIR/bash_modules/jq.sh"
fi

if [[ -z $SKIP_TERRAFORM_FMT || -z $SKIP_TERRAFORM_VALIDATE ]]; then
  source "$SCRIPT_DIR/bash_modules/terraform.sh"
fi

if [[ -z $SKIP_TFLINT ]]; then
  source "$SCRIPT_DIR/bash_modules/tflint.sh"
fi

if [[ -z $SKIP_TFSEC ]]; then
  source "$SCRIPT_DIR/bash_modules/tfsec.sh"
fi

if [[ -z $SKIP_CHECKOV ]]; then
  source "$SCRIPT_DIR/bash_modules/checkov.sh"
fi

# ---------------------------------------------------------------------------------------------------------------------
# Validate module
# ---------------------------------------------------------------------------------------------------------------------
show ""

# terraform fmt
if [[ -z $SKIP_TERRAFORM_FMT ]]; then
  show INFO "Validating format with Terraform"
  terraform -chdir="$module" fmt -check -recursive "${terraform_params[@]}"
  show PASS "Terraform format validation"
fi

# tflint
if [[ -z $SKIP_TFLINT ]]; then
  show INFO "Validating format with tflint"
  tflint --init "${tflint_params[@]}"
  tflint "${tflint_params[@]}" "$module"
  show PASS "Tflint validation"
fi

# tfsec
if [[ -z $SKIP_TFSEC ]]; then
  show INFO "Analyzing with tfsec"
  tfsec "${tfsec_params[@]}" "$module"
  show PASS "Tfsec validation"
fi

# terraform init
if [[ -z $SKIP_TERRAFORM_VALIDATE ]]; then
  show INFO "Initialize module"
  terraform -chdir="$module" init "${terraform_params[@]}" > /dev/null
fi

# terraform validate
if [[ -z $SKIP_TERRAFORM_VALIDATE ]]; then
  show INFO "Validating with Terraform"
  terraform -chdir="$module" validate "${terraform_params[@]}" > /dev/null
  show PASS "Terraform validation"
fi

# checkov
if [[ -z $SKIP_CHECKOV ]]; then
  show INFO "Analyzing with checkov"
  out=$(mktemp); checkov "${checkov_params[@]}" --framework terraform -d "$module" > "$out" || (cat "$out" && rm -f "$out" & false)
  show PASS "Checkov analysis"
fi

show ""
