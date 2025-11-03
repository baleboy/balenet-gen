#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${REPO_ROOT}/site/build"
ENV_FILE="${REPO_ROOT}/.env"

if [[ ! -d "${BUILD_DIR}" ]]; then
  echo "Site build not found at ${BUILD_DIR}. Run 'make render' first." >&2
  exit 1
fi

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
fi

: "${FTP_HOST:?Set FTP_HOST (e.g. export FTP_HOST=example.com)}"
: "${FTP_USER:?Set FTP_USER (e.g. export FTP_USER=deploy)}"
: "${FTP_PASSWORD:?Set FTP_PASSWORD (keep this in .env or your shell, never commit it)}"

REMOTE_DIR="${FTP_TARGET_DIR:-.}"
FTP_SSL="${FTP_SSL:-true}"

if ! command -v lftp >/dev/null 2>&1; then
  echo "lftp is required for publishing. Install it (brew install lftp) and retry." >&2
  exit 1
fi

echo "Publishing ${BUILD_DIR} to ${FTP_HOST}:${REMOTE_DIR} ..."

lftp -c "
set ssl:verify-certificate false;
open -u \"${FTP_USER}\",\"${FTP_PASSWORD}\" \"${FTP_HOST}\";
set ftp:ssl-allow ${FTP_SSL};
set ftp:ssl-force ${FTP_SSL};
set ftp:ssl-protect-data ${FTP_SSL};
lcd \"${BUILD_DIR}\";
mirror -R --delete --verbose . \"${REMOTE_DIR}\";
bye
"

echo "✅ Publish complete."
