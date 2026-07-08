#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"

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

echo "== LaTeX =="
cp -R "${root}/examples/latex" "${tmpdir}/latex"
(
  cd "${tmpdir}/latex"
  latexmk -pdfdvi -latex="platex %O %S" -e '$dvipdf="dvipdfmx %O -o %D %S"' -interaction=nonstopmode -halt-on-error platex-example.tex >/dev/null
  latexmk -pdfdvi -latex="uplatex %O %S" -e '$dvipdf="dvipdfmx %O -o %D %S"' -interaction=nonstopmode -halt-on-error uplatex-example.tex >/dev/null
  latexmk -lualatex -interaction=nonstopmode -halt-on-error lualatex-example.tex >/dev/null
  pdfgrep -n "Gauss" lualatex-example.pdf >/dev/null
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

echo "== Codex CLI =="
codex --version

echo "All examples completed successfully."
