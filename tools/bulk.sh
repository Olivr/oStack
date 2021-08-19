#!/usr/bin/env bash
# shellcheck disable=SC2011,SC2012
#
# This simple script is used as a wrapper for running certain commands in bulk (ie. on all modules and templates)
# It can enable the parallel mode through https://formulae.brew.sh/formula/parallel
# Example usage from the root of the repo:
# tools/bulk.sh lint modules
# SKIP_CHECKOV=1 tools/bulk.sh lint modules
# tools/bulk.sh lint modules --parallel

set -o errexit
set -o pipefail

declare processor="xargs -L1"
if [[ ${!#} == "--parallel" ]]; then
  processor="parallel"
  echo "Running in parallel... What is displayed on your terminal may not be in the right order."
fi

[[ -n $OUTPUT_LOG_LEVEL ]] || export OUTPUT_LOG_LEVEL=PASS

function get_dirs() {
  declare -a folders

  files_relative=(${@#"$(pwd)/"})
  files_absolute=${files_relative/#/$(pwd)/}

  for file in "${files_absolute[@]}"; do
    while IFS='' read -r folder; do
      module_folder=$(cut -d/ -f2 -f3 <<< "${folder#$(pwd)}")
      folders+=("${module_folder/#/$(pwd)/}")
    done < <(dirname "$file")
  done

  echo "${folders[@]}" | tr ' ' '\n' | sort -u
}

# Format all modules (quick)
if [[ $1 == "format" && $2 == "modules" ]]; then
  terraform fmt -write -recursive modules

# Lint all modules (moderate)
elif [[ $1 == "lint" && $2 == "modules" ]]; then
  terraform fmt -write -recursive modules
  ls -d modules/*/ | $processor tools/tfvalidate.sh

# Lint all templates (moderate)
elif [[ $1 == "lint" && $2 == "templates" ]]; then
  # Checkov is too slow to be run as linting tool, instead it should be run in CI
  ls -d templates/*-infra*/ | SKIP_TERRAFORM_VALIDATE=1 SKIP_CHECKOV=1 $processor tools/tfvalidate.sh
  ls -d templates/*-ops*/ | SKIP_CHECKOV=1 $processor tools/kubevalidate.sh

# Run unit tests on all modules (moderate)
elif [[ $1 == "test" && $2 == "unit" && $3 == "modules" ]]; then
  ls -d modules/*/ | SKIP_INTEGRATION_TESTS=1 $processor tools/tftest.sh

# Run integration tests on all modules (long)
elif [[ $1 == "test" && $2 == "integration" && $3 == "modules" ]]; then
  ls -d modules/*/ | SKIP_UNIT_TESTS=1 $processor tools/tftest.sh

# Run unit and integration tests on all modules (long)
elif [[ $1 == "test" && $2 == "modules" ]]; then
  ls -d modules/*/ | $processor tools/tftest.sh

# Pre-commit hook for modules (quick)
elif [[ $1 == "pre-commit" && $2 == "modules" ]]; then

  if [[ $3 == "--add-to-commit" ]]; then
    start_index=4
    export AUTO_COMMIT=1
  else
    start_index=3
  fi

  get_dirs "${@:$start_index}" | SKIP_CHECKOV=1 $processor tools/tfvalidate.sh
  get_dirs "${@:$start_index}" | $processor tools/tfdocs.sh

# Pre-commit hook for templates (quick)
elif [[ $1 == "pre-commit" && $2 == "templates" ]]; then
  get_dirs "${@:3}" | grep "templates/.*-infra.*" | SKIP_CHECKOV=1 SKIP_TERRAFORM_VALIDATE=1 $processor tools/tfvalidate.sh
  get_dirs "${@:3}" | grep "templates/.*-ops.*" | SKIP_CHECKOV=1 $processor tools/kubevalidate.sh

fi
