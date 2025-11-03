#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="${REPO_ROOT}/Fixtures/basic-site"
BUILD_DIR="${FIXTURE}/build"
BINARY="${REPO_ROOT}/.build/Build/Products/Release/balenet-gen"

if [[ ! -x "${BINARY}" ]]; then
  echo "Release binary not found at ${BINARY}. Run 'make build' first." >&2
  exit 1
fi

rm -rf "${BUILD_DIR}"

"${BINARY}" -s "${FIXTURE}" -o "${BUILD_DIR}"

assert_contains() {
  local file=$1
  local needle=$2
  if ! grep -q "${needle}" "${file}"; then
    echo "Expected '${needle}' in ${file}" >&2
    exit 1
  fi
}

assert_contains "${BUILD_DIR}/index.html" "Hello World"
assert_contains "${BUILD_DIR}/about/index.html" "smoke test"
assert_contains "${BUILD_DIR}/work/index.html" "Sample Project"
assert_contains "${BUILD_DIR}/posts/hello/index.html" "hello world"

echo "✅ Smoke test passed"
