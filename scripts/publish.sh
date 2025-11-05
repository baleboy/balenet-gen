#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/site/build"
PUBLISH_BRANCH="${GITHUB_PAGES_BRANCH:-gh-pages}"
COMMIT_MESSAGE_DEFAULT="Publish site $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
COMMIT_MESSAGE="${GITHUB_PAGES_COMMIT_MESSAGE:-$COMMIT_MESSAGE_DEFAULT}"

if [[ ! -d "${BUILD_DIR}" ]]; then
  echo "Site build not found at ${BUILD_DIR}. Run 'make render' first." >&2
  exit 1
fi

pushd "${REPO_ROOT}" >/dev/null

if ! git show-ref --verify --quiet "refs/heads/${PUBLISH_BRANCH}"; then
  if git ls-remote --exit-code origin "${PUBLISH_BRANCH}" >/dev/null 2>&1; then
    git fetch origin "${PUBLISH_BRANCH}:${PUBLISH_BRANCH}" >/dev/null 2>&1
  fi
fi

WORKTREE_DIR="$(mktemp -d -t balenet-gen-pages-XXXXXX)"
cleanup() {
  git worktree remove --force "${WORKTREE_DIR}" >/dev/null 2>&1 || rm -rf "${WORKTREE_DIR}"
}
trap cleanup EXIT

if git show-ref --verify --quiet "refs/heads/${PUBLISH_BRANCH}"; then
  git worktree add --force --checkout "${WORKTREE_DIR}" "${PUBLISH_BRANCH}" >/dev/null
else
  git worktree add --force --detach "${WORKTREE_DIR}" >/dev/null
  pushd "${WORKTREE_DIR}" >/dev/null
  git checkout --orphan "${PUBLISH_BRANCH}" >/dev/null
  git reset --hard >/dev/null
  popd >/dev/null
fi

rsync -a --delete --exclude '.git' "${BUILD_DIR}/" "${WORKTREE_DIR}/"

pushd "${WORKTREE_DIR}" >/dev/null

if git status --porcelain | grep -q '.'; then
  git add -A
  git commit -m "${COMMIT_MESSAGE}"
  git push -u origin "${PUBLISH_BRANCH}"
  echo "✅ Published to ${PUBLISH_BRANCH}"
else
  echo "No changes to publish."
fi

popd >/dev/null
popd >/dev/null
