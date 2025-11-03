#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SITE_DIR="${REPO_ROOT}/site"
BUILD_DIR="${SITE_DIR}/build"
BINARY="${REPO_ROOT}/.build/Build/Products/Release/balenet-gen"

if [[ ! -x "${BINARY}" ]]; then
  echo "Release binary not found at ${BINARY}. Run 'make build' first." >&2
  exit 1
fi

rm -rf "${BUILD_DIR}"

"${BINARY}" -s "${SITE_DIR}" -o build

assert_contains() {
  local file=$1
  local needle=$2
  if ! grep -Fq "${needle}" "${file}"; then
    echo "Expected '${needle}' in ${file}" >&2
    exit 1
  fi
}

assert_contains "${BUILD_DIR}/index.html" "I finally read Smart & Gets Things Done"
assert_contains "${BUILD_DIR}/index.html" 'href="/topics/gaming/"'
assert_contains "${BUILD_DIR}/index.html" 'class="post-year"'
assert_contains "${BUILD_DIR}/index.html" 'class="post-date"'
assert_contains "${BUILD_DIR}/topics/gaming/index.html" "It took me 236 hours but I finished Elden Ring!"
assert_contains "${BUILD_DIR}/about/index.html" "<main>"

echo "✅ Test passed"
