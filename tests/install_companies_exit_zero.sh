#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if ! bash "$REPO_ROOT/install.sh" --section companies >/tmp/install-companies.out 2>/tmp/install-companies.err; then
  echo "install.sh --section companies exited non-zero" >&2
  cat /tmp/install-companies.out >&2 || true
  cat /tmp/install-companies.err >&2 || true
  exit 1
fi

echo "company-shared install exits zero"
