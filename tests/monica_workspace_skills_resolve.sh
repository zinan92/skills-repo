#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MONICA_WORKSPACE="/Users/wendy/work/agents-co/monica"

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "missing expected output: $needle" >&2
    exit 1
  fi
}

output="$(bash "$REPO_ROOT/install.sh" --dry-run --agent monica)"

assert_contains "$output" "$REPO_ROOT/skills/data/blogwatcher"
assert_contains "$output" "$REPO_ROOT/skills/data/reddit"
assert_contains "$output" "$REPO_ROOT/skills/dev/github"
assert_contains "$output" "$MONICA_WORKSPACE/.claude/skills"
assert_contains "$output" "$MONICA_WORKSPACE/.agents/skills"

echo "monica workspace dry-run routes resolve"
