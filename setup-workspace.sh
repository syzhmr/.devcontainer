#!/usr/bin/env bash
set -euo pipefail

workspace="${1:-${PWD}}"

mkdir -p "${workspace}/Python" "${workspace}/LaTeX" "${workspace}/SageMath" "${workspace}/Lean4"

git config --global init.defaultBranch main
git config --global --add safe.directory "${workspace}"
git config --global --add safe.directory "${workspace}/Python"
git config --global --add safe.directory "${workspace}/LaTeX"
git config --global --add safe.directory "${workspace}/SageMath"
git config --global --add safe.directory "${workspace}/Lean4"

if ! git -C "${workspace}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  nested_git="$(find "${workspace}" -mindepth 2 -maxdepth 2 -name .git -type d -print -quit)"
  if [ -z "${nested_git}" ]; then
    git -C "${workspace}" init
  fi
fi
