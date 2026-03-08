#!/usr/bin/env bash
# uninstall.sh — Remove all symlinks tracked by install.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
MANIFEST_FILE="${REPO_ROOT}/manifest/install-manifest.json"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERR ]${NC} $*"; }

if [ ! -f "$MANIFEST_FILE" ]; then
  err "No manifest found at $MANIFEST_FILE — nothing to uninstall"
  exit 1
fi

python3 - "$MANIFEST_FILE" <<'EOF'
import json, os, sys

manifest_path = sys.argv[1]
with open(manifest_path) as f:
    data = json.load(f)

removed = 0
for item in data.get("items", []):
    dst = item["dst"]
    if os.path.islink(dst):
        os.remove(dst)
        print(f"\033[0;32m[ OK ]\033[0m Removed: {dst}")
        removed += 1
    elif os.path.exists(dst):
        print(f"\033[1;33m[WARN]\033[0m Not a symlink, skipping: {dst}")
    else:
        print(f"\033[1;33m[WARN]\033[0m Already gone: {dst}")

print(f"\nRemoved {removed} symlinks.")
EOF
