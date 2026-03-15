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

output="$(bash "$REPO_ROOT/install.sh" --dry-run)"

assert_contains "$output" "$REPO_ROOT/skills/global/using-superpowers"
assert_contains "$output" "$REPO_ROOT/skills/content/baoyu-post-to-x"
assert_contains "$output" "$REPO_ROOT/skills/dev/product-readme"
assert_contains "$output" "$REPO_ROOT/skills/data/hackernews"
assert_contains "$output" "$REPO_ROOT/skills/trading/risk-management"

echo "nested category dry-run paths detected"
