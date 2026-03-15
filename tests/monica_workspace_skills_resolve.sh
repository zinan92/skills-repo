#!/usr/bin/env bash
set -euo pipefail

found=0

for dir in \
  /Users/wendy/work/agents-co/monica/.agents/skills \
  /Users/wendy/work/agents-co/monica/.claude/skills \
; do
  for path in "$dir"/*; do
    [ -L "$path" ] || continue
    if [ ! -e "$path" ]; then
      echo "broken workspace skill symlink: $path" >&2
      found=1
    fi
  done
done

if [ "$found" -ne 0 ]; then
  exit 1
fi

echo "monica workspace skill symlinks resolve"
