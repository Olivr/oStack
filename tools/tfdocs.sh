#!/usr/bin/env bash
# Folder containing the generated files
declare docs_folder="docs"

module=${1%/}
module_relative=${module#"$(pwd)/"}
module_absolute=${module_relative/#/$(pwd)/}
docs_absolute=${docs_folder/#/$module_absolute/}

echo "INFO - Generating docs for $module_relative"

# Get changed file names between two folders
get_changed_files() {
  diff_out=$(mktemp)
  diff --brief --recursive "$1" "$2" > "$diff_out"
  (grep "^Only in" | awk '{print $NF}') < "$diff_out"
  (grep "differ$" | awk '{print $(NF-1)}' | xargs basename) < "$diff_out"
}

# Ensure the docs folder(s) exist
mkdir -p "$docs_absolute"

# Copy file to temp folder for diff
temp_dir=$(mktemp -d)
cp -a "$docs_absolute/." "$temp_dir"

# Generate docs
terraform-docs "$module" > /dev/null

# Format changed files
while IFS= read -r file; do
  if [[ -f "$docs_absolute/$file" ]]; then
    yarn prettier --config .prettierrc.json --write "$docs_absolute/$file" > /dev/null
  fi
done < <(get_changed_files "$docs_absolute" "$temp_dir")

# Add to git
while IFS= read -r file; do
  if [[ -n $AUTO_COMMIT ]]; then
    git add "$docs_absolute/$file" > /dev/null
    echo "INFO - Added $file to your commit"
  else
    echo "INFO - $file was updated"
  fi
done < <(get_changed_files "$docs_absolute" "$temp_dir")

