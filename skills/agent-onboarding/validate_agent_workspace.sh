#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <agent_slug> <workspace_path>" >&2
  exit 1
fi

AGENT_SLUG="$1"
WORKSPACE_PATH="$2"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WENDY_ROOT="$(cd "${SCRIPT_DIR}/../../../../" && pwd)"
PROFILE_DIR="${WENDY_ROOT}/agent-profiles/${AGENT_SLUG}"
RUNTIME_SPEC_PATH="${WENDY_ROOT}/agent-runtime-specs/${AGENT_SLUG}.md"
SOP_DIR="${WENDY_ROOT}/sops/${AGENT_SLUG}"

required_workspace_paths=(
  "${WORKSPACE_PATH}/AGENTS.md"
  "${WORKSPACE_PATH}/IDENTITY.md"
  "${WORKSPACE_PATH}/SOUL.md"
  "${WORKSPACE_PATH}/HEARTBEAT.md"
  "${WORKSPACE_PATH}/TOOLS.md"
  "${WORKSPACE_PATH}/USER.md"
  "${WORKSPACE_PATH}/.openclaw/workspace-state.json"
  "${WORKSPACE_PATH}/inbox"
  "${WORKSPACE_PATH}/active"
  "${WORKSPACE_PATH}/handoff"
  "${WORKSPACE_PATH}/archive"
)

for path in "${required_workspace_paths[@]}"; do
  if [ ! -e "${path}" ]; then
    echo "Missing required workspace path: ${path}" >&2
    exit 1
  fi
done

required_canonical_paths=(
  "${PROFILE_DIR}/AGENTS.md"
  "${PROFILE_DIR}/IDENTITY.md"
  "${PROFILE_DIR}/SOUL.md"
  "${PROFILE_DIR}/HEARTBEAT.md"
  "${PROFILE_DIR}/TOOLS.md"
  "${PROFILE_DIR}/USER.md"
  "${RUNTIME_SPEC_PATH}"
  "${SOP_DIR}/README.md"
)

for path in "${required_canonical_paths[@]}"; do
  if [ ! -e "${path}" ]; then
    echo "Missing required canonical path: ${path}" >&2
    exit 1
  fi
done

profile_files=(AGENTS.md IDENTITY.md SOUL.md HEARTBEAT.md TOOLS.md USER.md)
for file in "${profile_files[@]}"; do
  workspace_file="${WORKSPACE_PATH}/${file}"
  expected_target="${PROFILE_DIR}/${file}"
  if [ ! -L "${workspace_file}" ]; then
    echo "Expected symlink in workspace: ${workspace_file}" >&2
    exit 1
  fi
  actual_target="$(readlink "${workspace_file}")"
  if [ "${actual_target}" != "${expected_target}" ]; then
    echo "Symlink target mismatch for ${workspace_file}: ${actual_target}" >&2
    exit 1
  fi
done

required_agents_sections=(
  "## Agent Name"
  "## Job Title"
  "## Company"
  "## Reports To"
  "## Responsibilities"
  "## Requirements"
  "## KPIs"
  "## Scope Boundary"
  "## Tools & Access"
  "## Model Tier"
  "## Schedule"
  "## Interaction Protocol"
  "## Escalation Rules"
)

for section in "${required_agents_sections[@]}"; do
  if ! rg -Fq "${section}" "${PROFILE_DIR}/AGENTS.md"; then
    echo "Missing AGENTS.md section: ${section}" >&2
    exit 1
  fi
done

if ! rg -Fq '"version": 1' "${WORKSPACE_PATH}/.openclaw/workspace-state.json"; then
  echo "workspace-state.json missing version marker" >&2
  exit 1
fi

if ! rg -Fq '## Runtime Setup' "${RUNTIME_SPEC_PATH}"; then
  echo "Runtime spec missing required section" >&2
  exit 1
fi

echo "Validated ${WORKSPACE_PATH}"
