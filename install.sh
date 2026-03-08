#!/usr/bin/env bash
# install.sh — Park Skills Repo installer
# Creates symlinks from each agent's workspace into this repo.
#
# Usage:
#   ./install.sh [--dry-run] [--agent <name>] [--platform openclaw|claude-code|all]
#
# Supported agents: wendy, monica, donald, rachel, ross, chandler, gunther
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false
TARGET_AGENT=""
PLATFORM="all"
MANIFEST_FILE="${REPO_ROOT}/manifest/install-manifest.json"
MANIFEST_ITEMS=""

# ── Colors ──────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()   { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERR ]${NC} $*"; }
dry()  { echo -e "${YELLOW}[DRY ]${NC} $*"; }

# ── Args ─────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)   DRY_RUN=true; shift ;;
    --agent)     TARGET_AGENT="$2"; shift 2 ;;
    --platform)  PLATFORM="$2"; shift 2 ;;
    -h|--help)   head -10 "$0" | tail -8; exit 0 ;;
    *)           err "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Agent → Workspace (bash 3.2 compatible) ──────────────────
get_workspace() {
  case "$1" in
    wendy)    echo "$HOME/clawd" ;;
    monica)   echo "$HOME/clawd-monica" ;;
    donald)   echo "$HOME/content-co/ceo-donald" ;;
    rachel)   echo "$HOME/content-co/researcher-rachel" ;;
    ross)     echo "$HOME/content-co/distribution-lead-ross" ;;
    chandler) echo "$HOME/content-co/seedance-expert-chandler" ;;
    gunther)  echo "$HOME/content-co/analyst-gunther" ;;
    *)        echo "" ;;
  esac
}

ALL_AGENTS="wendy monica donald rachel ross chandler gunther"

SYMLINK_COUNT=0

make_symlink() {
  local src="$1" dst="$2"
  if $DRY_RUN; then
    dry "[$(basename "$(dirname "$dst")")]  $(basename "$dst")  →  $src"
    return
  fi
  if [ -L "$dst" ]; then
    rm "$dst"   # replace stale symlink
  elif [ -e "$dst" ]; then
    warn "Skipping (real path exists): $dst"
    return
  fi
  ln -s "$src" "$dst"
  ok "$(basename "$dst")"

  local entry="{\"type\":\"symlink\",\"src\":\"${src}\",\"dst\":\"${dst}\"}"
  if [ -z "$MANIFEST_ITEMS" ]; then
    MANIFEST_ITEMS="$entry"
  else
    MANIFEST_ITEMS="${MANIFEST_ITEMS},${entry}"
  fi
  SYMLINK_COUNT=$((SYMLINK_COUNT + 1))
}

install_agent() {
  local agent="$1"
  local workspace
  workspace="$(get_workspace "$agent")"

  if [ -z "$workspace" ]; then
    warn "Unknown agent: $agent"
    return
  fi

  local skills_src="${REPO_ROOT}/agents/${agent}"
  if [ ! -d "$skills_src" ]; then
    warn "No skills folder for $agent — skipping"
    return
  fi
  if [ ! -d "$workspace" ]; then
    warn "Workspace not found for $agent ($workspace) — skipping"
    return
  fi

  info "── $agent ──────────────────────"

  # OpenClaw: <workspace>/.agents/skills/<skill>
  if [[ "$PLATFORM" == "openclaw" || "$PLATFORM" == "all" ]]; then
    local oc_dir="${workspace}/.agents/skills"
    $DRY_RUN || mkdir -p "$oc_dir"
    for skill_path in "${skills_src}"/*/; do
      [ -d "$skill_path" ] || continue
      local skill_name
      skill_name="$(basename "$skill_path")"
      make_symlink "${skill_path%/}" "${oc_dir}/${skill_name}"
    done
  fi

  # Claude Code: <workspace>/.claude/skills/<skill>
  if [[ "$PLATFORM" == "claude-code" || "$PLATFORM" == "all" ]]; then
    local cc_dir="${workspace}/.claude/skills"
    $DRY_RUN || mkdir -p "$cc_dir"
    for skill_path in "${skills_src}"/*/; do
      [ -d "$skill_path" ] || continue
      local skill_name
      skill_name="$(basename "$skill_path")"
      make_symlink "${skill_path%/}" "${cc_dir}/${skill_name}"
    done
  fi
}

# ── Run ──────────────────────────────────────────────────────
if [ -n "$TARGET_AGENT" ]; then
  install_agent "$TARGET_AGENT"
else
  for agent in $ALL_AGENTS; do
    install_agent "$agent"
  done
fi

# ── Write manifest ───────────────────────────────────────────
if ! $DRY_RUN && [ -n "$MANIFEST_ITEMS" ]; then
  mkdir -p "$(dirname "$MANIFEST_FILE")"
  cat > "$MANIFEST_FILE" <<EOF
{
  "version": "1.0.0",
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "platform": "${PLATFORM}",
  "repo": "${REPO_ROOT}",
  "items": [${MANIFEST_ITEMS}]
}
EOF
  ok "Manifest written → manifest/install-manifest.json"
fi

echo ""
info "Done. ${SYMLINK_COUNT} symlinks."
$DRY_RUN && echo -e "${YELLOW}(dry-run — no changes made)${NC}"
