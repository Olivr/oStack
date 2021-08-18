#!/usr/bin/env bash

# This function finds a config file given the filename(s) given as arguments in the most common directories
find_config () {
  local names=( "${@}" ) # Config names

  local config=""
  local lookup_paths=(
    "$module"
    "$module/.config"
    "$(pwd)"
    "$(pwd)/.config"
    "$HOME"
    "$HOME/.config"
  )

  for lookup_path in "${lookup_paths[@]}"; do
    for name in "${names[@]}"; do
      if (ls "$lookup_path/$name" &> /dev/null); then
        config="$lookup_path/$name"
        echo -e "${INFO} Configuration found in $lookup_path/$name" >&2
        break 2
      fi
    done
  done

  echo "$config"
}
