#!/usr/bin/env bash
set -euo pipefail

MONICA_DIR="/Users/wendy/work/agents-co/wendy/skills-repo/agents/monica"

found=0
for path in "$MONICA_DIR"/*; do
  [ -L "$path" ] || continue
  target="$(readlink "$path")"
  if [ "$target" = "$path" ]; then
    echo "self-referential symlink: $path" >&2
    found=1
  fi
done

if [ "$found" -ne 0 ]; then
  exit 1
fi

echo "monica agent skills have no self symlinks"
