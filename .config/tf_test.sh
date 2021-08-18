#!/usr/bin/env bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# This script is licensed under http://www.apache.org/licenses/LICENSE-2.0
#
# It takes a directory as its input and will run a set of tests against a Terraform module
# It supports automatic installation of missing tools for Linux and Mac (AMD64)
# Use it like ./tf_test.sh modules/backend-tfe
#
# Available options:
# DISABLE_COLORS=1          Disable colors
# FORCE_GPG_VERIFY=1        Force validating signatures for downloads that support it
# FORCE_INSTALL=1           Force installing tools (mainly to ensure they are used in their latest versions)
# IMPORT_BASE64_KEYS=1      Import public keys for checksum validation. Accepts one base64 encoded string of all keys
# SKIP_CHECKOV=1            Skip checkov tests
# SKIP_INPUTS_TESTS=1       Skip input tests
# SKIP_TFSEC=1              Skip tfsec
# SKIP_UNIT_TESTS=1         Skip unit tests

# shellcheck disable=SC1091
source "$SCRIPT_DIR/bash_modules/utils.sh"

# ---------------------------------------------------------------------------------------------------------------------
# Install required tools
# ---------------------------------------------------------------------------------------------------------------------

# shellcheck disable=SC1091
source "$SCRIPT_DIR/bash_modules/jq.sh"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/bash_modules/terraform.sh"

if [[ -z $SKIP_CHECKOV ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/bash_modules/checkov.sh"
fi

if [[ -z $SKIP_TFSEC ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/bash_modules/tfsec.sh"
fi

# ---------------------------------------------------------------------------------------------------------------------
# Validate single files
# ---------------------------------------------------------------------------------------------------------------------
# Cleanup previous runs
rm -rf "$module/plan.*"

# terraform init
echo "TEST - Initializing module"
terraform -chdir="$module" init $terraform_params > /dev/null

# Run tests if any
if ls -d "$module/tests/" &> /dev/null; then

  # Run inputs tests
  if [[ -z $SKIP_INPUTS_TESTS ]]; then
    find "$module/tests" -type f \( -iname '*.tfvars' -o -iname '*.tfvars.json' \) -print0 -maxdepth 1 | while IFS= read -r -d $'\0' file; do
      echo -e "${INFO} Test inputs with ${file#"$module/tests/"}"

      # tfsec
      if [[ -z $SKIP_TFSEC ]]; then
        echo -e "TEST - Analyzing with tfsec"
        tfsec --concise-output $tfsec_params --tfvars-file "$file" "$module"
      fi

      # terraform plan
      tf_plan=$(mktemp "$module/plan.XXXX")
      echo "TEST - Validating plan"
      terraform -chdir="$module" plan $terraform_params -input=false -var-file="$file" -out "$tf_plan" > /dev/null
      terraform -chdir="$module" show $terraform_params -json "$tf_plan" > "$tf_plan.json" && rm -rf "$tf_plan" > /dev/null
      grep '^{"' "$tf_plan.json" | jq '.' > "$tf_plan.pretty.json" && rm -rf "$tf_plan.json" # A weird GH actions bug injects actions metadata in the output so we filter only the lines containing JSON

      # checkov
      if [[ -z $SKIP_CHECKOV ]]; then
        echo "TEST - Validating $1${tf_plan#"$module/"}.pretty.json with checkov"
        checkov_config=$(find_config .checkov.yml .checkov.yaml)
        if [[ -n $checkov_config ]]; then checkov_config="--config-file ""$checkov_config"""; fi
        checkov --quiet --framework terraform_plan --repo-root-for-plan-enrichment "$(dirname "$tf_plan")" -f "$tf_plan.pretty.json" $checkov_config
      fi

      # Cleanup
      rm -rf "$tf_plan.pretty.json"
    done
  fi

  # Run native Terraform tests
  if [[ -z $SKIP_UNIT_TESTS ]]; then

    echo -e "${INFO} Running unit tests"

    if (ls -d "$module/tests/*/" &> /dev/null); then
      terraform -chdir="$module" test $terraform_params > /dev/null
    else
      echo -e "${WARN} No unit tests found"
    fi
  fi

else
  echo -e "${WARN} No tests folder found"
fi
