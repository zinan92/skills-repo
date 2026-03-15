---
name: agent-onboarding
description: Use when Wendy is onboarding a brand-new OpenClaw agent, defining a fresh role before first use, or preparing a new agent environment with canonical profile files, SOP ownership, skills assignment, and runtime setup. Use for new agent initialization only. Do not use for re-onboarding, legacy migration, or historical cleanup.
platform: both
scope: agent:wendy
---

# Agent Onboarding

Create a clean, standardized environment for a brand-new agent.

This skill is for `new agent initialization` only. It does not migrate old workspaces, reconstruct memory, or retrofit legacy agents.

## Core Model

Split onboarding into two layers:

- `agent-runtime-spec` = canonical operating definition stored under Wendy
- `agent-runtime-state` = live execution surface stored in the target agent workspace

Wendy owns the single source of truth for:

- agent profiles
- SOPs
- skills management
- runtime specs

The target agent workspace only owns:

- `.openclaw/workspace-state.json`
- `inbox/`
- `active/`
- `handoff/`
- `archive/`
- symlinks to canonical profile files

## Required Input Spec

Collect and freeze these fields before creating anything:

1. `Agent Name`
2. `Job Title`
3. `Company`
4. `Reports To`
5. `Workspace Path`
6. `Responsibilities`
7. `Requirements`
8. `KPIs`
9. `Scope Boundary`
10. `Tools & Access`
11. `Model Tier`
12. `Schedule`
13. `Interaction Protocol`
14. `Escalation Rules`

Use `spec-template.md` as the intake form.

## Core Rules

- Create one clear role, not a blended job title.
- Allow only one direct manager in `Reports To`.
- Put canonical definitions under Wendy, not inside the target workspace.
- Do not invent memory or usage history for unused agents.
- Do not create fake work logs, fake learnings, or fake user context.
- Standardize the environment first; personality and SOP nuance can be refined later.
- If scope or access is unclear, stop and resolve that before scaffolding.
- Do not create independent copies of profile markdown files in the target workspace.

## Canonical Paths Under Wendy

For agent slug `<agent-slug>`, store canonical definitions here:

- `/Users/wendy/work/agents-co/wendy/agent-profiles/<agent-slug>/`
- `/Users/wendy/work/agents-co/wendy/agent-runtime-specs/<agent-slug>.md`
- `/Users/wendy/work/agents-co/wendy/sops/<agent-slug>/`

## Target Workspace Structure

Every new agent workspace must contain:

- symlinked `AGENTS.md`
- symlinked `IDENTITY.md`
- symlinked `SOUL.md`
- symlinked `HEARTBEAT.md`
- symlinked `TOOLS.md`
- symlinked `USER.md`
- `.openclaw/workspace-state.json`
- `inbox/`
- `active/`
- `handoff/`
- `archive/`

## File Mapping

### `AGENTS.md`

This is the operating contract. It must contain:

- Agent Name
- Job Title
- Company
- Reports To
- Responsibilities
- Requirements
- KPIs
- Scope Boundary
- Tools & Access
- Model Tier
- Schedule
- Interaction Protocol
- Escalation Rules

### `IDENTITY.md`

Keep it short:

- Name
- Creature / role label
- Vibe
- Emoji
- Focus

### `SOUL.md`

Define:

- who the agent is
- what it owns
- how it works
- what it does not do
- relationship to neighboring roles

### `HEARTBEAT.md`

Define recurring operating rhythm only:

- daily checks
- scheduled tasks
- queue hygiene
- escalation checks

Do not fabricate a heartbeat schedule if the agent is event-driven. Write `event-driven` instead.

### `TOOLS.md`

Record:

- role-specific skills
- standard baseline skills
- access rules
- writable directories
- readable directories
- channels / threads / systems the agent may use

### `agent-runtime-spec`

This lives under Wendy and defines:

- workspace path
- model tier
- schedule
- required skills
- SOP references
- writable/readable paths
- channels / systems
- escalation expectations

### `USER.md`

Leave as a blank, real-use placeholder. Do not prefill personal memory.

## Workflow

1. Freeze the onboarding spec in `spec-template.md` format.
2. Choose an `agent-slug`.
3. Run `./scaffold_agent_workspace.sh <agent-slug> <workspace_path>`.
4. Fill the canonical profile files, SOP placeholder, and runtime spec under Wendy.
5. Run `./validate_agent_workspace.sh <agent-slug> <workspace_path>`.
6. Install or link required skills and report remaining manual setup.

## Output Format

When onboarding is complete, report in this structure:

```markdown
## New Agent
- Name:
- Job Title:
- Canonical Profile:
- Runtime Spec:
- Workspace:
- Reports To:

## Installed Structure
- canonical profile: complete / incomplete
- runtime spec: complete / incomplete
- runtime state: complete / incomplete
- skills: installed / pending
- SOP placeholders: complete / incomplete

## Open Items
- [remaining manual step]
```

## Anti-Patterns

- Treating re-org migration as onboarding
- Creating memory files for an unused agent
- Leaving `Scope Boundary` vague
- Giving the agent multiple bosses
- Installing skills without documenting access boundaries
- Creating a workspace before deciding the owner and path
- Treating workspace-local markdown files as the source of truth

## Quick Reference

- Spec template: `spec-template.md`
- Scaffold script: `scaffold_agent_workspace.sh`
- Validation script: `validate_agent_workspace.sh`
- Eval prompts: `evals.json`
