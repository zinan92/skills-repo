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

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "unexpected output: $needle" >&2
    exit 1
  fi
}

output="$(bash "$REPO_ROOT/install.sh" --dry-run --agent monica)"

assert_contains "$output" "$REPO_ROOT/skills/data/hackernews"
assert_contains "$output" "$REPO_ROOT/skills/dev/github"
assert_not_contains "$output" "$REPO_ROOT/agents/monica"
assert_not_contains "$output" "$REPO_ROOT/companies/content-co"

echo "monica dry-run uses nested category sources only"
