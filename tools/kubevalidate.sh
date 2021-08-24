#!/usr/bin/env bash
# kubevalidate v1.0.0
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#
# This script is licensed under http://www.apache.org/licenses/LICENSE-2.0
#
# It takes a directory as its input and will run a set of static analysis checks against a set of Kubernetes yaml files
# It supports automatic installation of missing tools for Linux and Mac (AMD64)
#
# Use it like ./kube_validate.sh templates/global-ops-github
#
# Available options:
# AUTO_FIX=1                Enable auto-fixing with kube-audit
# DISABLE_COLORS=1          Disable colors for this script and as much as possible for the called programs
# FORCE_INSTALL=1           Force installing tools (mainly to ensure they are used in their latest versions)
# FORCE_VERIFY_DOWNLOAD=1   Force validating signatures for downloads that support it
# IMPORT_KEYS_BASE64=""     Import public keys for checksum validation. Accepts one base64 encoded string of all keys
# IMPORT_KEYS_DIR="./keys"  Import public keys for checksum validation. Accepts a path to a directory containing public key files
# OUTPUT_LOG_LEVEL=PASS     Set output log level for this script and as much as possible for the called programs (INFO (default), PASS, WARN, ERR)
# SKIP_CHECKOV=1            Skip running checkov
# SKIP_KUBEAUDIT=1          Skip running kubeaudit
# SKIP_KUBESCORE=1          Skip running kube-score
# SKIP_KUBEVAL=1            Skip running kubeval
# SKIP_KUSTOMIZE=1          Skip building and testing kustomize files
# SKIP_POLARIS=1            Skip running polaris

source "$SCRIPT_DIR/bash_modules/utils.sh"

show "" "$(printf '=%.0s' {1..80})"
echo "Validating $1"
show "" "$(printf '=%.0s' {1..80})"

# ---------------------------------------------------------------------------------------------------------------------
# Required tools
# ---------------------------------------------------------------------------------------------------------------------
if [[ -z $SKIP_KUBEVAL ]]; then
  source "$SCRIPT_DIR/bash_modules/kubeval.sh"
fi

if [[ -z $SKIP_KUSTOMIZE ]]; then
  source "$SCRIPT_DIR/bash_modules/kustomize.sh"
fi

if [[ -z $SKIP_KUBESCORE ]]; then
  source "$SCRIPT_DIR/bash_modules/kube-score.sh"
fi

if [[ -z $SKIP_POLARIS ]]; then
  source "$SCRIPT_DIR/bash_modules/polaris.sh"
fi

if [[ -z $SKIP_KUBEAUDIT ]]; then
  source "$SCRIPT_DIR/bash_modules/kubeaudit.sh"
fi

if [[ -z $SKIP_CHECKOV ]]; then
  source "$SCRIPT_DIR/bash_modules/checkov.sh"
fi

# ---------------------------------------------------------------------------------------------------------------------
# Validate single files
# ---------------------------------------------------------------------------------------------------------------------
show ""

# kubeval
if [[ -z $SKIP_KUBEVAL ]]; then
  show INFO "Validating $module with kubeval"
  kubeval "${kubeval_params[@]}" -d "$module"
fi

if [[ -z $SKIP_KUBESCORE || -z $SKIP_KUBEAUDIT ]]; then
  while IFS= read -r -d $'\0' file;
  do
    # kube-score
    if [[ -z "$SKIP_KUBESCORE" ]]; then
      show INFO "Validating ${file#"$module"} with kube-score"
      kube-score score "${kubescore_params[@]}" "$file"
      show PASS "Kube-score validation for ${file#"$module"}"
    fi

    # kubeaudit
    if [[ -n $AUTO_FIX ]]; then
      kubeaudit autofix -f "$file"
    fi

    if [[ -z $SKIP_KUBEAUDIT ]]; then
      show INFO "Validating ${file#"$module"} with kubeaudit"
      kubeaudit "${kubeaudit_params[@]}" -f "$file"
      show PASS "Kubeaudit validation for ${file#"$module"}"
    fi
  done < <(find "$module" -type f \( -iname '*.yaml' -o -iname '*.yml' \) -not -path "*/.*" -print0)
fi

# polaris
if [[ -z $SKIP_POLARIS ]]; then
  show INFO "Validating $module with polaris"
  out=$(mktemp); polaris audit "${polaris_params[@]}" --audit-path "$module" > "$out" || (cat "$out" && rm -f "$out" & false);
  show PASS "Polaris validation for $module"
fi

# checkov
if [[ -z $SKIP_CHECKOV ]]; then
  show INFO "Analyzing $module with checkov"
  out=$(mktemp); checkov "${checkov_params[@]}" --framework kubernetes -d "$module" > "$out" || (cat "$out" && rm -f "$out" & false)
  show PASS "Checkov analysis for $module"
fi

# ---------------------------------------------------------------------------------------------------------------------
# Validate kustomizations
# ---------------------------------------------------------------------------------------------------------------------
# Clean up previous runs
rm -f /tmp/kustomize.*.yaml

if [[ -z $SKIP_KUSTOMIZE ]]; then
  while IFS= read -r -d $'\0' file; do
    printf "\nValidating kustomization %s\n" "${file#"$module"}"

    kustomize_build=$(build=$(mktemp /tmp/kustomize.XXX); mv "$build" "$build.yaml"; echo "$build.yaml")

    show INFO "Building with kustomize"
    kustomize build "${file/%"kustomization.yaml"}" --load-restrictor=LoadRestrictionsNone --reorder=legacy > "$kustomize_build"

    if [[ -z $SKIP_KUBEVAL ]]; then
      show INFO "Validating with kubeval"
      kubeval "${kubeval_params[@]}" --filename "$file" < "$kustomize_build"
    fi

    if [[ -z $SKIP_KUBESCORE ]]; then
      show INFO "Validating with kube-score"
      kube-score score --ignore-container-cpu-limit --ignore-container-memory-limit "${kubescore_params[@]}" "$kustomize_build"
      show PASS "Kube-score validation"
    fi

    if [[ -z $SKIP_POLARIS ]]; then
      show INFO "Validating with polaris"
      out=$(mktemp); polaris audit "${polaris_params[@]}" --audit-path "$kustomize_build" > "$out" || (cat "$out" && rm -f "$out" & false)
      show PASS "Polaris validation"
    fi

    if [[ -z $SKIP_CHECKOV ]]; then
      show INFO "Analyzing with checkov"
      out=$(mktemp); checkov "${checkov_params[@]}" --framework kubernetes -f "$kustomize_build" > "$out" || (cat "$out" && rm -f "$out" & false)
      show PASS "Checkov analysis"
    fi

    # kubeaudit
    if [[ -z $SKIP_KUBEAUDIT ]]; then
      show INFO "Validating with kubeaudit"
      kubeaudit "${kubeaudit_params[@]}" -f "$kustomize_build"
      show PASS "Kubeaudit validation"
    fi

    rm -f "$kustomize_build"
  done < <(find "$module" -type f -name kustomization.yaml -print0)
fi

show ""
