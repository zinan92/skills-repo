#!/usr/bin/env bash
# install.sh — Park Skills Repo installer (flat structure)
#
# Structure:
#   skills/<skill-name>/SKILL.md  — each skill has platform + scope frontmatter
#
# Routing is driven by SKILL.md frontmatter:
#   platform: claude-code | openclaw | both
#   scope:    global | agent:<name> | company:<company>
#
# Usage:
#   ./install.sh [--dry-run] [--agent <name>]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false
TARGET_AGENT=""
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
    -h|--help)   head -12 "$0" | tail -10; exit 0 ;;
    *)           err "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Agent → Workspace ────────────────────────────────────────
get_workspace() {
  case "$1" in
    wendy)    echo "/Users/wendy/work/agents-co/wendy" ;;
    monica)   echo "/Users/wendy/work/agents-co/monica" ;;
    donald)   echo "/Users/wendy/work/content-co/ceo-donald" ;;
    rachel)   echo "/Users/wendy/work/content-co/researcher-rachel" ;;
    ross)     echo "/Users/wendy/work/content-co/distribution-lead-ross" ;;
    chandler) echo "/Users/wendy/work/content-co/seedance-expert-chandler" ;;
    gunther)  echo "/Users/wendy/work/content-co/analyst-gunther" ;;
    echo)     echo "/Users/wendy/work/trading-co/echo" ;;
    justin)   echo "/Users/wendy/work/data-co/JUSTIN-quant-workspace" ;;
    vincent)  echo "/Users/wendy/work/data-co/VINCENT-qual-workspace" ;;
    michelle) echo "/Users/wendy/work/trading-co/newsletter-michelle" ;;
    *)        echo "" ;;
  esac
}

# ── Company → Agents ─────────────────────────────────────────
get_company_agents() {
  case "$1" in
    content-co)  echo "donald rachel ross chandler gunther" ;;
    data-co)     echo "justin vincent" ;;
    trading-co)  echo "echo michelle" ;;
    agents-co)   echo "wendy monica" ;;
    *)           echo "" ;;
  esac
}

# ── Symlink helper ───────────────────────────────────────────
make_symlink() {
  local src="$1" dst="$2"
  if $DRY_RUN; then
    dry "$(basename "$dst")  →  $src  =>  $dst"
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

# ── Read frontmatter field from SKILL.md ─────────────────────
read_frontmatter() {
  local file="$1" field="$2"
  # Extract value between --- delimiters
  sed -n '/^---$/,/^---$/p' "$file" | grep "^${field}:" | head -1 | sed "s/^${field}:[[:space:]]*//"
}

# ── Install a single skill to a target dir ───────────────────
install_skill_to() {
  local skill_path="$1" target_dir="$2"
  local skill_name
  skill_name="$(basename "$skill_path")"
  $DRY_RUN || mkdir -p "$target_dir"
  make_symlink "${skill_path}" "${target_dir}/${skill_name}"
}

# ── Route a skill based on platform + scope ──────────────────
route_skill() {
  local skill_path="$1" platform="$2" scope="$3"

  if [[ "$scope" == "global" ]]; then
    # Global skills go to home-level dirs
    if [[ "$platform" == "claude-code" || "$platform" == "both" ]]; then
      install_skill_to "$skill_path" "$HOME/.claude/skills"
    fi
    if [[ "$platform" == "openclaw" || "$platform" == "both" ]]; then
      install_skill_to "$skill_path" "$HOME/.agents/skills"
    fi

  elif [[ "$scope" == agent:* ]]; then
    local agent_name="${scope#agent:}"
    # Filter by --agent if specified
    if [[ -n "$TARGET_AGENT" && "$TARGET_AGENT" != "$agent_name" ]]; then
      return
    fi
    local workspace
    workspace="$(get_workspace "$agent_name")"
    [ -n "$workspace" ] || { warn "Unknown agent: $agent_name"; return; }
    [ -d "$workspace" ] || { warn "Workspace not found: $workspace"; return; }

    if [[ "$platform" == "claude-code" || "$platform" == "both" ]]; then
      install_skill_to "$skill_path" "${workspace}/.claude/skills"
    fi
    if [[ "$platform" == "openclaw" || "$platform" == "both" ]]; then
      install_skill_to "$skill_path" "${workspace}/.agents/skills"
    fi

  elif [[ "$scope" == company:* ]]; then
    local company="${scope#company:}"
    local agents
    agents="$(get_company_agents "$company")"
    [ -n "$agents" ] || { warn "Unknown company: $company"; return; }

    for agent_name in $agents; do
      # Filter by --agent if specified
      if [[ -n "$TARGET_AGENT" && "$TARGET_AGENT" != "$agent_name" ]]; then
        continue
      fi
      local workspace
      workspace="$(get_workspace "$agent_name")"
      [ -n "$workspace" ] || continue
      [ -d "$workspace" ] || { warn "Workspace not found: $workspace ($agent_name)"; continue; }

      if [[ "$platform" == "claude-code" || "$platform" == "both" ]]; then
        install_skill_to "$skill_path" "${workspace}/.claude/skills"
      fi
      if [[ "$platform" == "openclaw" || "$platform" == "both" ]]; then
        install_skill_to "$skill_path" "${workspace}/.agents/skills"
      fi
    done
  else
    warn "Unknown scope: $scope (skill: $(basename "$skill_path"))"
  fi
}

# ── Main: scan all skills ────────────────────────────────────
info "Scanning skills/ for SKILL.md frontmatter..."
echo ""

for skill_dir in "${REPO_ROOT}"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  skill_md="${skill_dir}SKILL.md"

  if [ ! -f "$skill_md" ]; then
    warn "No SKILL.md in ${skill_name}, skipping"
    continue
  fi

  platform="$(read_frontmatter "$skill_md" "platform")"
  scope="$(read_frontmatter "$skill_md" "scope")"

  if [ -z "$platform" ] || [ -z "$scope" ]; then
    warn "Missing platform/scope in ${skill_name}/SKILL.md, skipping"
    continue
  fi

  info "── ${skill_name} (${platform}, ${scope})"
  route_skill "${skill_dir%/}" "$platform" "$scope"
done

# ── Write manifest ───────────────────────────────────────────
if ! $DRY_RUN && [ -n "$MANIFEST_ITEMS" ]; then
  mkdir -p "$(dirname "$MANIFEST_FILE")"
  cat > "$MANIFEST_FILE" <<EOF
{
  "version": "2.0.0",
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "repo": "${REPO_ROOT}",
  "items": [${MANIFEST_ITEMS}]
}
EOF
  ok "Manifest written → manifest/install-manifest.json"
fi

echo ""
info "Done. ${SYMLINK_COUNT} symlinks."
if $DRY_RUN; then
  echo -e "${YELLOW}(dry-run — no changes made)${NC}"
fi
