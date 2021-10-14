#!/usr/bin/env bash
# tftest v1.0.0
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#
# This script is licensed under http://www.apache.org/licenses/LICENSE-2.0
#
# It takes a directory as its input and will run a set of tests against a Terraform module
# It supports automatic installation of missing tools for Linux and Mac (AMD64)
#
# Use it like ./tf_test.sh modules/backend-tfe
#
# Available options:
# DISABLE_COLORS=1          Disable colors for this script and as much as possible for the called programs
# FORCE_INSTALL=1           Force installing tools (mainly to ensure they are used in their latest versions)
# FORCE_VERIFY_DOWNLOAD=1   Force validating signatures for downloads that support it
# IMPORT_KEYS_BASE64=""     Import public keys for checksum validation. Accepts one base64 encoded string of all keys
# IMPORT_KEYS_DIR="./keys"  Import public keys for checksum validation. Accepts a path to a directory containing public key files
# OUTPUT_LOG_LEVEL=PASS     Set output log level for this script and as much as possible for the called programs (INFO (default), PASS, WARN, ERR)
# SKIP_CHECKOV=1            Skip running checkov
# SKIP_TFSEC=1              Skip running tfsec
# SKIP_UNIT_TESTS=1         Skip running unit tests
# SKIP_INTEGRATION_TESTS=1  Skip running integration tests

source "$SCRIPT_DIR/bash_modules/utils.sh"

show "" "$(printf '=%.0s' {1..80})"
echo "Testing $1"
show "" "$(printf '=%.0s' {1..80})"

# ---------------------------------------------------------------------------------------------------------------------
# Required tools
# ---------------------------------------------------------------------------------------------------------------------
source "$SCRIPT_DIR/bash_modules/jq.sh"
source "$SCRIPT_DIR/bash_modules/terraform.sh"

if [[ -z $SKIP_CHECKOV ]]; then
  source "$SCRIPT_DIR/bash_modules/checkov.sh"
fi

if [[ -z $SKIP_TFSEC ]]; then
  source "$SCRIPT_DIR/bash_modules/tfsec.sh"
fi

if [[ -z $SKIP_INTEGRATION_TESTS ]]; then
  source "$SCRIPT_DIR/bash_modules/gotestsum.sh"
fi

# ---------------------------------------------------------------------------------------------------------------------
# Validate single files
# ---------------------------------------------------------------------------------------------------------------------
# Cleanup previous runs
rm -f "$module"/plan.*
show ""

test_folder="$module/tests"

# terraform init
show INFO "Initializing module"
terraform -chdir="$module" init "${terraform_params[@]}" > /dev/null

# Run tests if any
if ls -d "$test_folder" &> /dev/null; then

  # Run inputs tests
  if [[ -z $SKIP_UNIT_TESTS ]]; then
    while IFS= read -r -d $'\0' file; do

      printf "Test inputs with %s\n" "${file#"$test_folder/"}"

      # tfsec
      if [[ -z $SKIP_TFSEC ]]; then
        show INFO "Analyzing with tfsec"
        tfsec "${tfsec_params[@]}" --tfvars-file "$file" "$module"
        show PASS "Tfsec analysis"
      fi

      # terraform plan
      tf_plan=$(plan=$(mktemp "$module/plan.XXXX"); mv "$plan" "$plan.out"; echo "$plan.out")
      show INFO "Validating plan"
      terraform -chdir="$module" plan "${terraform_params[@]}" -input=false -var-file="$file" -out "$tf_plan" > /dev/null
      terraform -chdir="$module" show "${terraform_params[@]}" -json "$tf_plan" > "$tf_plan.json" && rm -f "$tf_plan" > /dev/null
      grep '^{"' "$tf_plan.json" | jq '.' > "$tf_plan.pretty.json" && rm -f "$tf_plan.json" # A weird GH actions bug injects actions metadata in the output so we filter only the lines containing JSON
      show PASS "Terraform plan"

      # checkov
      if [[ -z $SKIP_CHECKOV ]]; then
        show INFO "Analyzing with checkov"
        out=$(mktemp); checkov "${checkov_params[@]}" --framework terraform_plan --repo-root-for-plan-enrichment "$(dirname "$tf_plan")" -f "$tf_plan.pretty.json" > "$out" || (cat "$out" && rm -f "$out" & false)
        show PASS "Checkov analysis"
      fi

      # Cleanup
      rm -f "$tf_plan.pretty.json"
    done < <(find "$test_folder" -type f \( -iname '*.tfvars' -o -iname '*.tfvars.json' \) -print0 -maxdepth 1)
  fi

  # Run integration tests
  if [[ -z $SKIP_INTEGRATION_TESTS ]]; then
    printf "Running integration tests\n"

    # Native Terraform tests https://www.terraform.io/docs/language/modules/testing-experiment.html
    if ls -d "$test_folder"/*/ &> /dev/null && [[ $(find "$test_folder"/*/ -name '*.tf' -print -quit) ]]; then
      terraform -chdir="$module" test "${terraform_params[@]}" > /dev/null
    else
      no_tf_tests=1
    fi

    # Go tests (most likely terratest)
    if [[ $(find "$test_folder" -maxdepth 1 -name '*_test.go' -print -quit) ]]; then
      (
        cd "$test_folder"
        go mod download
        gotestsum --format testname --max-fails 1
      )
    else
      no_go_tests=1
    fi

    if [[ -n $no_tf_tests && -n $no_go_tests ]]; then
      show WARN "No integration tests found"
    fi
  fi

else
  if [[ -z $SKIP_UNIT_TESTS || -z $SKIP_INTEGRATION_TESTS ]]; then show WARN "No tests folder found"; fi
fi

echo ""
