#!/usr/bin/env bash
set -euo pipefail

workspace="${1:-${PWD}}"
ssh_dir="${HOME}/.ssh"
ssh_key="${ssh_dir}/id_ed25519"
ssh_public_key="${ssh_key}.pub"

ensure_ssh_key() {
  mkdir -p "${ssh_dir}"
  chmod 700 "${ssh_dir}"

  if [ -f "${ssh_key}" ]; then
    echo "SSH key already exists: ${ssh_key}"
  else
    ssh_comment="github-devcontainer"
    ssh-keygen -q -t ed25519 -C "${ssh_comment}" -f "${ssh_key}" -N ""
    chmod 600 "${ssh_key}"
    chmod 644 "${ssh_public_key}"
    echo "Generated SSH key: ${ssh_key}"
  fi

  if [ -f "${ssh_public_key}" ]; then
    echo
    echo "Add this public key to GitHub as an Authentication Key:"
    cat "${ssh_public_key}"
    echo
  fi
}

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

ensure_ssh_key
