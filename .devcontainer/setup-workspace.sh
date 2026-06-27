#!/usr/bin/env bash
set -euo pipefail

workspace="${1:-${PWD}}"

git config --global init.defaultBranch main

if git -C "${workspace}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config --global --add safe.directory "${workspace}"
fi
