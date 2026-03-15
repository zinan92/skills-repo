#!/usr/bin/env bash
set -euo pipefail

CANONICAL="/Users/wendy/work/agents-co/wendy/skills-repo/agents/donald/remotion-best-practices"

if [ -L "$CANONICAL" ]; then
  target="$(readlink "$CANONICAL")"
  if [ "$target" = "$CANONICAL" ]; then
    echo "donald remotion skill is self-referential: $CANONICAL" >&2
    exit 1
  fi
fi

for path in \
  /Users/wendy/work/content-co/ceo-donald/.agents/skills/remotion-best-practices \
  /Users/wendy/work/content-co/ceo-donald/.claude/skills/remotion-best-practices \
; do
  if [ ! -e "$path" ]; then
    echo "donald remotion workspace link is broken: $path" >&2
    exit 1
  fi
done

echo "donald remotion skill resolves"
