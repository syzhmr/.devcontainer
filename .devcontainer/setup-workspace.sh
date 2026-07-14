#!/usr/bin/env bash
set -euo pipefail

workspace="${1:-${PWD}}"
node_version="${DEVCONTAINER_NODE_VERSION:-22.22.3}"
npm_version="${DEVCONTAINER_NPM_VERSION:-10.9.8}"
github_cli_version="${DEVCONTAINER_GH_VERSION:-2.94.0}"
qmd_version="${QMD_VERSION:-2.5.3}"
shardmind_version="${SHARDMIND_VERSION:-0.1.3}"

for version in \
  "${node_version}" \
  "${npm_version}" \
  "${github_cli_version}" \
  "${qmd_version}" \
  "${shardmind_version}"; do
  if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    printf 'error: invalid pinned tool version: %s\n' "${version}" >&2
    exit 1
  fi
done

nvm_dir="${NVM_DIR:-/usr/local/share/nvm}"
if [[ -s "${nvm_dir}/nvm.sh" ]]; then
  export NVM_DIR="${nvm_dir}"
  # Dev Container lifecycle commands run in a non-interactive shell.
  # shellcheck source=/dev/null
  source "${NVM_DIR}/nvm.sh"
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  printf 'error: Node.js and npm are required; check the Node Dev Container Feature\n' >&2
  exit 1
fi

actual_node_version=$(node --version)
actual_node_version=${actual_node_version#v}
actual_npm_version=$(npm --version)
if [[ "${actual_node_version}" != "${node_version}" ]]; then
  printf 'error: expected Node.js %s, found %s\n' "${node_version}" "${actual_node_version}" >&2
  exit 1
fi
if [[ "${actual_npm_version}" != "${npm_version}" ]]; then
  printf 'error: expected npm %s, found %s\n' "${npm_version}" "${actual_npm_version}" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  printf 'error: GitHub CLI is required; check the GitHub CLI Dev Container Feature\n' >&2
  exit 1
fi
actual_github_cli_version=$(gh --version | awk 'NR == 1 { print $3 }')
if [[ "${actual_github_cli_version}" != "${github_cli_version}" ]]; then
  printf 'error: expected GitHub CLI %s, found %s\n' \
    "${github_cli_version}" "${actual_github_cli_version}" >&2
  exit 1
fi

global_root=$(npm root --global)
npm_packages=()

queue_npm_package() {
  local package_name=$1
  local expected_version=$2
  local manifest="${global_root}/${package_name}/package.json"
  local installed_version=

  if [[ -f "${manifest}" ]]; then
    installed_version=$(node -e '
      const fs = require("node:fs");
      const manifest = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
      process.stdout.write(manifest.version ?? "");
    ' "${manifest}")
  fi

  if [[ "${installed_version}" != "${expected_version}" ]]; then
    npm_packages+=("${package_name}@${expected_version}")
  fi
}

queue_npm_package "@tobilu/qmd" "${qmd_version}"
queue_npm_package "shardmind" "${shardmind_version}"

if ((${#npm_packages[@]})); then
  npm install --global --no-audit --no-fund "${npm_packages[@]}"
fi

if [[ $(qmd --version) != "qmd ${qmd_version}" ]]; then
  printf 'error: QMD version check failed\n' >&2
  exit 1
fi
if [[ $(shardmind --version) != "${shardmind_version}" ]]; then
  printf 'error: ShardMind version check failed\n' >&2
  exit 1
fi

verify_agent_memory_runtime() {
  local package_dir=$1

  (
    cd "${package_dir}"
    node --input-type=module -e '
      import { existsSync } from "node:fs";
      import { Jieba } from "@node-rs/jieba";
      import { getLoadablePath } from "sqlite-vec";

      const jieba = new Jieba();
      jieba.cut("FO", false);

      const nativePath = getLoadablePath();
      if (!existsSync(nativePath)) {
        throw new Error(`sqlite-vec native library is missing: ${nativePath}`);
      }
    '
  )
}

install_locked_node_dependencies() {
  local package_dir=$1
  local project_dir=${package_dir%/tools/tencentdb-agent-memory}
  local lock_file="${package_dir}/package-lock.json"
  local stamp_file="${package_dir}/node_modules/.devcontainer-install-state"
  local expected_hash=
  local runtime_id=
  local expected_state=
  local installed_state=

  if [[ -L "${project_dir}" \
      || -L "${project_dir}/tools" \
      || -L "${package_dir}" \
      || -L "${lock_file}" \
      || -L "${package_dir}/package.json" ]]; then
    printf 'Skipping Agent Memory dependencies through a symlink: %s\n' "${package_dir}" >&2
    return 0
  fi
  [[ -f "${lock_file}" ]] || return 0

  expected_hash=$(sha256sum "${lock_file}")
  expected_hash=${expected_hash%% *}
  runtime_id=$(node -p \
    '`${process.platform}-${process.arch}-${process.version}-abi${process.versions.modules}`')
  expected_state="${expected_hash} ${runtime_id}"
  if [[ -f "${stamp_file}" ]]; then
    IFS= read -r installed_state < "${stamp_file}" || true
  fi

  if [[ "${installed_state}" == "${expected_state}" ]] \
      && npm ls --prefix "${package_dir}" --depth=0 --silent >/dev/null 2>&1 \
      && verify_agent_memory_runtime "${package_dir}"; then
    printf 'Agent Memory dependencies are up to date\n'
    return 0
  fi

  printf 'Installing locked Agent Memory dependencies\n'
  npm ci --prefix "${package_dir}" --no-audit --no-fund
  verify_agent_memory_runtime "${package_dir}"
  printf '%s\n' "${expected_state}" > "${stamp_file}"
}

git config --global init.defaultBranch main

if git -C "${workspace}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config --global --add safe.directory "${workspace}"
fi

install_locked_node_dependencies "${workspace}/tools/tencentdb-agent-memory"
install_locked_node_dependencies "${workspace}/FO/tools/tencentdb-agent-memory"
