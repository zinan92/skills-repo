#!/usr/bin/env bash
# install.sh — Park Skills Repo installer
#
# Structure:
#   global/openclaw/    → ~/.agents/skills/          (all OpenClaw agents)
#   global/claude-code/ → ~/.claude/skills/           (all Claude Code instances)
#   agents/<name>/      → <workspace>/.agents/skills/ (OpenClaw, agent-specific)
#                       → <workspace>/.claude/skills/ (Claude Code in that workspace)
#
# Usage:
#   ./install.sh [--dry-run] [--agent <name>] [--section global|agents|all]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false
TARGET_AGENT=""
SECTION="all"
MANIFEST_FILE="${REPO_ROOT}/manifest/install-manifest.json"
MANIFEST_ITEMS=""
SYMLINK_COUNT=0

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
    --section)   SECTION="$2"; shift 2 ;;
    -h|--help)   head -12 "$0" | tail -10; exit 0 ;;
    *)           err "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Agent → Workspace ────────────────────────────────────────
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

# ── Symlink helper ───────────────────────────────────────────
make_symlink() {
  local src="$1" dst="$2"
  if $DRY_RUN; then
    dry "$(basename "$dst")  →  $src"
    return
  fi
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    warn "Skipping (real path exists): $dst"
    return
  fi
  ln -s "$src" "$dst"
  ok "$(basename "$dst")"

  local entry="{\"type\":\"symlink\",\"src\":\"${src}\",\"dst\":\"${dst}\"}"
  MANIFEST_ITEMS="${MANIFEST_ITEMS:+${MANIFEST_ITEMS},}${entry}"
  SYMLINK_COUNT=$((SYMLINK_COUNT + 1))
}

# ── Install skills from a src dir into a target dir ─────────
install_skills_dir() {
  local src_dir="$1" target_dir="$2"
  [ -d "$src_dir" ] || return
  $DRY_RUN || mkdir -p "$target_dir"
  for skill_path in "${src_dir}"/*/; do
    [ -d "$skill_path" ] || continue
    local skill_name
    skill_name="$(basename "$skill_path")"
    make_symlink "${skill_path%/}" "${target_dir}/${skill_name}"
  done
}

# ── Section: global ──────────────────────────────────────────
install_global() {
  info "── global/openclaw → ~/.agents/skills/"
  install_skills_dir "${REPO_ROOT}/global/openclaw" "$HOME/.agents/skills"

  info "── global/claude-code → ~/.claude/skills/"
  install_skills_dir "${REPO_ROOT}/global/claude-code" "$HOME/.claude/skills"
}

# ── Section: agents ──────────────────────────────────────────
install_agent() {
  local agent="$1"
  local workspace
  workspace="$(get_workspace "$agent")"

  [ -n "$workspace" ]   || { warn "Unknown agent: $agent"; return; }
  [ -d "$workspace" ]   || { warn "Workspace not found: $workspace"; return; }

  local skills_src="${REPO_ROOT}/agents/${agent}"
  [ -d "$skills_src" ] && [ "$(ls -A "$skills_src" 2>/dev/null)" ] || {
    info "── $agent (no agent-specific skills)"
    return
  }

  info "── $agent"

  # OpenClaw: <workspace>/.agents/skills/
  install_skills_dir "$skills_src" "${workspace}/.agents/skills"

  # Claude Code: <workspace>/.claude/skills/
  install_skills_dir "$skills_src" "${workspace}/.claude/skills"
}

# ── Run ──────────────────────────────────────────────────────
if [[ "$SECTION" == "global" || "$SECTION" == "all" ]]; then
  install_global
fi

if [[ "$SECTION" == "agents" || "$SECTION" == "all" ]]; then
  if [ -n "$TARGET_AGENT" ]; then
    install_agent "$TARGET_AGENT"
  else
    for agent in $ALL_AGENTS; do
      install_agent "$agent"
    done
  fi
fi

# ── Write manifest ───────────────────────────────────────────
if ! $DRY_RUN && [ -n "$MANIFEST_ITEMS" ]; then
  mkdir -p "$(dirname "$MANIFEST_FILE")"
  cat > "$MANIFEST_FILE" <<EOF
{
  "version": "1.0.0",
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "section": "${SECTION}",
  "repo": "${REPO_ROOT}",
  "items": [${MANIFEST_ITEMS}]
}
EOF
  ok "Manifest written → manifest/install-manifest.json"
fi

echo ""
info "Done. ${SYMLINK_COUNT} symlinks."
$DRY_RUN && echo -e "${YELLOW}(dry-run — no changes made)${NC}"
