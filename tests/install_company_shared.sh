#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "missing expected output: $needle" >&2
    exit 1
  fi
}

run_and_check() {
  local agent="$1"
  local workspace="$2"

  local output
  output="$(bash "$REPO_ROOT/install.sh" --dry-run --agent "$agent")"

  assert_contains "$output" "baoyu-xhs-images  →  $REPO_ROOT/skills/content/baoyu-xhs-images"
  assert_contains "$output" "baoyu-post-to-x  →  $REPO_ROOT/skills/content/baoyu-post-to-x"
  assert_contains "$output" "baoyu-markdown-to-html  →  $REPO_ROOT/skills/content/baoyu-markdown-to-html"
  assert_contains "$output" "$workspace/.agents/skills"
  assert_contains "$output" "$workspace/.claude/skills"
}

run_and_check "donald" "/Users/wendy/work/content-co/ceo-donald"

echo "company-shared install dry-run checks passed"
