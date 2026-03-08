# park-skills-repo

Single source of truth for all Park agent skills. Version controlled, symlink-installed.

## Structure

```
agents/
├── wendy/       # Wendy's skills (21 skills)
├── monica/      # Monica's skills (8 skills)
├── donald/      # Donald's skills
├── rachel/      # Rachel's skills
├── ross/        # Ross's skills
├── chandler/    # Chandler's skills
└── gunther/     # Gunther's skills
```

## How Skills Work

Each agent's skills live in `agents/<name>/`. The installer creates symlinks into two locations per agent:

- **OpenClaw**: `<workspace>/.agents/skills/<skill>/` — picked up by OpenClaw and Pi harnesses
- **Claude Code**: `<workspace>/.claude/skills/<skill>/` — picked up by Claude Code instances launched in that workspace

Editing a skill in this repo = immediately live for all agents using it (no reinstall needed).

## Agent → Workspace Mapping

| Agent    | Workspace                                    |
|----------|----------------------------------------------|
| wendy    | `~/clawd`                                    |
| monica   | `~/clawd-monica`                             |
| donald   | `~/content-co/ceo-donald`                   |
| rachel   | `~/content-co/researcher-rachel`             |
| ross     | `~/content-co/distribution-lead-ross`        |
| chandler | `~/content-co/seedance-expert-chandler`      |
| gunther  | `~/content-co/analyst-gunther`               |

## Install

```bash
# Preview (dry-run)
bash install.sh --dry-run

# Install all agents, both platforms
bash install.sh

# Install one agent only
bash install.sh --agent wendy

# Install for OpenClaw only
bash install.sh --platform openclaw
```

## Uninstall

```bash
bash uninstall.sh
```

Only removes symlinks tracked in `manifest/install-manifest.json`. Original files in this repo are never touched.

## Adding a New Skill

1. Create `agents/<agent>/<skill-name>/SKILL.md`
2. Commit and push
3. Re-run `bash install.sh --agent <agent>` (idempotent — replaces existing symlinks)

## Relationship with skill-chain

`skill-chain` (`~/skill-chain`) is a separate dev-workflow pipeline framework with its own skills (triage, writing-plans, mvu-execution). This repo is for agent role/personality skills. They are complementary and do not overlap.

## Platform Support

| Harness      | Discovery path                          |
|--------------|-----------------------------------------|
| OpenClaw     | `<workspace>/.agents/skills/`           |
| Claude Code  | `<workspace>/.claude/skills/`           |
| Pi           | `<workspace>/.agents/skills/` (same)   |
