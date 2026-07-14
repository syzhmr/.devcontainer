#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"
node_version="${DEVCONTAINER_NODE_VERSION:-22.22.3}"
npm_version="${DEVCONTAINER_NPM_VERSION:-10.9.8}"
github_cli_version="${DEVCONTAINER_GH_VERSION:-2.94.0}"
qmd_version="${QMD_VERSION:-2.5.3}"
shardmind_version="${SHARDMIND_VERSION:-0.1.3}"

assert_equal() {
  local actual=$1
  local expected=$2
  local description=$3

  if [[ "${actual}" != "${expected}" ]]; then
    printf 'error: expected %s %s, found %s\n' \
      "${description}" "${expected}" "${actual}" >&2
    exit 1
  fi
}

cleanup() {
  rm -rf "${tmpdir}"
}
trap cleanup EXIT

echo "== Python =="
python "${root}/examples/python/hello_math.py"

echo "== SageMath =="
sage "${root}/examples/sage/example.sage"

echo "== Lean =="
(
  cd "${root}/examples/lean"
  lean Basic.lean
)

echo "== Node.js =="
assert_equal "$(node --version)" "v${node_version}" "Node.js"
assert_equal "$(npm --version)" "${npm_version}" "npm"
node --experimental-strip-types "${root}/examples/node/typescript-example.ts"
assert_equal "$(qmd --version)" "qmd ${qmd_version}" "QMD"
assert_equal "$(shardmind --version)" "${shardmind_version}" "ShardMind"

echo "== LaTeX =="
cp -R "${root}/examples/latex" "${tmpdir}/latex"
(
  cd "${tmpdir}/latex"
  latexmk -pdfdvi -latex="platex %O %S" -e '$dvipdf="dvipdfmx %O -o %D %S"' -interaction=nonstopmode -halt-on-error platex-example.tex >/dev/null
  latexmk -pdfdvi -latex="uplatex %O %S" -e '$dvipdf="dvipdfmx %O -o %D %S"' -interaction=nonstopmode -halt-on-error uplatex-example.tex >/dev/null
  latexmk -pdfdvi -latex="uplatex %O %S" -e '$dvipdf="dvipdfmx %O -o %D %S"' -interaction=nonstopmode -halt-on-error fo-uplatex-example.tex >/dev/null
  latexmk -lualatex -interaction=nonstopmode -halt-on-error lualatex-example.tex >/dev/null
  pdfgrep -n "Gauss" lualatex-example.pdf >/dev/null
  pdfinfo fo-uplatex-example.pdf >/dev/null
  pdftotext fo-uplatex-example.pdf fo-uplatex-example.txt
  pdftoppm -f 1 -l 1 -singlefile -png \
    fo-uplatex-example.pdf fo-uplatex-example-preview >/dev/null 2>&1
)

echo "== Jupyter =="
jupyter --version

echo "== OCR =="
tesseract --version >/dev/null
tesseract --list-langs | grep -Fxq "eng"
tesseract --list-langs | grep -Fxq "jpn"
tesseract --list-langs | grep -Fxq "jpn_vert"
tesseract --list-langs | grep -Fxq "osd"
python - <<'PY'
import cv2
print(cv2.__version__)
PY

echo "== Research workflow tools =="
for command_name in upbibtex mendex pdfinfo pdftotext pdftoppm realpath; do
  command -v "${command_name}" >/dev/null
done
realpath "${tmpdir}" >/dev/null
assert_equal "$(gh --version | awk 'NR == 1 { print $3 }')" \
  "${github_cli_version}" "GitHub CLI"
ssh -V 2>&1 | grep -q "OpenSSH"
magick -version | grep -q "ImageMagick 7"
rsync --version | grep -q "rsync  version"
jq --version >/dev/null
file --version >/dev/null
tmux -V >/dev/null

echo "== Codex CLI =="
codex --version

echo "All examples completed successfully."
