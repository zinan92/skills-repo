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

mkdir -p \
  "${PROFILE_DIR}" \
  "${SOP_DIR}" \
  "${WENDY_ROOT}/agent-runtime-specs" \
  "${WORKSPACE_PATH}/.openclaw" \
  "${WORKSPACE_PATH}/inbox" \
  "${WORKSPACE_PATH}/active" \
  "${WORKSPACE_PATH}/handoff" \
  "${WORKSPACE_PATH}/archive"

if [ ! -f "${PROFILE_DIR}/AGENTS.md" ]; then
  cat > "${PROFILE_DIR}/AGENTS.md" <<'EOF'
# AGENTS.md

## Agent Name

## Job Title

## Company

## Reports To

## Responsibilities

- 

## Requirements

- 

## KPIs

- 

## Scope Boundary

### Does

- 

### Does Not

- 

## Tools & Access

### Skills

- 

### SOP References

- 

### Writable Paths

- 

### Readable Paths

- 

### Channels / Systems

- 

## Model Tier

## Schedule

## Interaction Protocol

## Escalation Rules
EOF
fi

if [ ! -f "${PROFILE_DIR}/IDENTITY.md" ]; then
  cat > "${PROFILE_DIR}/IDENTITY.md" <<'EOF'
# IDENTITY.md

- **Name:**
- **Creature:**
- **Vibe:**
- **Emoji:**
- **Focus:**
EOF
fi

if [ ! -f "${PROFILE_DIR}/SOUL.md" ]; then
  cat > "${PROFILE_DIR}/SOUL.md" <<'EOF'
# SOUL.md

## Who I Am

## My Responsibilities

## How I Work

## What I Don't Do

## Relationship
EOF
fi

if [ ! -f "${PROFILE_DIR}/HEARTBEAT.md" ]; then
  cat > "${PROFILE_DIR}/HEARTBEAT.md" <<'EOF'
# HEARTBEAT.md

## Operating Rhythm

### Daily

- 

### Weekly

- 

### Event-Driven

- 
EOF
fi

if [ ! -f "${PROFILE_DIR}/TOOLS.md" ]; then
  cat > "${PROFILE_DIR}/TOOLS.md" <<'EOF'
# TOOLS.md

## Role-Specific Skills

- 

## Baseline Skills

- 

## SOP References

- 

## Writable Paths

- 

## Readable Paths

- 

## Channels / Systems

- 
EOF
fi

if [ ! -f "${PROFILE_DIR}/USER.md" ]; then
  cat > "${PROFILE_DIR}/USER.md" <<'EOF'
# USER.md - About Your Human

_Leave blank until real usage teaches something real._

- **Name:**
- **What to call them:**
- **Timezone:**
- **Notes:**
EOF
fi

if [ ! -f "${RUNTIME_SPEC_PATH}" ]; then
  cat > "${RUNTIME_SPEC_PATH}" <<EOF
# Agent Runtime Spec - ${AGENT_SLUG}

## Identity

- Agent Name:
- Job Title:
- Company:
- Workspace Path: ${WORKSPACE_PATH}
- Reports To:

## Runtime Setup

- Model Tier:
- Required Skills:
- SOP References:
- Writable Paths:
- Readable Paths:
- Channels / Systems:

## Schedule

- Timezone:
- Work Rhythm:
- Cron / Event Trigger:
- Weekend Behavior:

## Escalation Rules

- Trigger:
- Escalate To:
- SLA / Response Window:
EOF
fi

if [ ! -f "${SOP_DIR}/README.md" ]; then
  cat > "${SOP_DIR}/README.md" <<'EOF'
# SOPs

- Add canonical SOP definitions for this agent here.
- Keep Wendy as the single source of truth.
EOF
fi

profile_files=(AGENTS.md IDENTITY.md SOUL.md HEARTBEAT.md TOOLS.md USER.md)
for file in "${profile_files[@]}"; do
  target="${WORKSPACE_PATH}/${file}"
  source="${PROFILE_DIR}/${file}"
  if [ -L "${target}" ]; then
    rm "${target}"
  elif [ -e "${target}" ]; then
    echo "Refusing to overwrite existing non-symlink: ${target}" >&2
    exit 1
  fi
  ln -s "${source}" "${target}"
done

if [ ! -f "${WORKSPACE_PATH}/.openclaw/workspace-state.json" ]; then
  cat > "${WORKSPACE_PATH}/.openclaw/workspace-state.json" <<'EOF'
{
  "version": 1
}
EOF
fi

echo "Scaffolded ${WORKSPACE_PATH}"
echo "Canonical profile: ${PROFILE_DIR}"
echo "Runtime spec: ${RUNTIME_SPEC_PATH}"
echo "SOP path: ${SOP_DIR}"
