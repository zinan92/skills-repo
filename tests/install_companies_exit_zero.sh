#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if ! bash "$REPO_ROOT/install.sh" --dry-run --agent donald >/tmp/install-companies.out 2>/tmp/install-companies.err; then
  echo "install.sh --dry-run --agent donald exited non-zero" >&2
  cat /tmp/install-companies.out >&2 || true
  cat /tmp/install-companies.err >&2 || true
  exit 1
fi

echo "company-shared install exits zero"
