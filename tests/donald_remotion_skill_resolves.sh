#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DONALD_WORKSPACE="/Users/wendy/work/content-co/ceo-donald"

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "missing expected output: $needle" >&2
    exit 1
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "unexpected output: $needle" >&2
    exit 1
  fi
}

output="$(bash "$REPO_ROOT/install.sh" --dry-run --agent donald)"

assert_contains "$output" "$REPO_ROOT/skills/content/remotion-best-practices"
assert_contains "$output" "$DONALD_WORKSPACE/.claude/skills/remotion-best-practices"
assert_contains "$output" "$DONALD_WORKSPACE/.agents/skills/remotion-best-practices"
assert_not_contains "$output" "$REPO_ROOT/agents/donald"

echo "donald remotion dry-run routes resolve"
