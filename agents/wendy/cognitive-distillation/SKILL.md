---
name: cognitive-distillation
description: "Four-layer cognitive distillation system. Use when performing daily reviews, recording decisions, extracting patterns, or updating principles. Transforms raw data into durable wisdom through systematic compression: Raw → Episodic → Semantic → Principles."
---

# Cognitive Distillation

## Overview

A four-layer system that transforms raw information into durable principles through progressive compression. Each layer distills the one below it.

```
L4: PRINCIPLES.md        ← 原子原则 (每周 review)
L3: memory/patterns.md   ← 认知模式 (每日蒸馏)
L2: memory/decisions/    ← 决策日志 (实时记录)
L1: memory/*.md + Obsidian ← 原始数据 (自动积累)
```

## The Four Layers

### Layer 1: Raw Data (原始数据)
**Files:** `memory/YYYY-MM-DD.md`, Obsidian briefings, conversation logs
**Update:** Continuous / automatic
**Purpose:** Capture everything. Don't filter at this stage.

Already handled by OpenClaw's memory flush + cron briefings.

### Layer 2: Episodic Memory (事件 + 决策日志)
**Files:** `memory/decisions/YYYY-MM-DD-<topic>.md`
**Update:** Whenever a significant decision is made
**Purpose:** Record WHY, not just WHAT.

**Decision log template:**
```markdown
# Decision: <title>
Date: YYYY-MM-DD
Context: <what situation triggered this decision>
Options:
  1. <option A> — pros / cons
  2. <option B> — pros / cons
  3. <option C> — pros / cons
Selected: <which option>
Reason: <why this one>
Expected outcome: <what we expect to happen>
Actual outcome: <filled in later>
Lesson: <filled in later>
```

**When to create a decision log:**
- Architecture or design choices
- Trading decisions (entry/exit thesis)
- Tool/framework selections
- Strategy pivots
- Any choice Park explicitly deliberates on

### Layer 3: Semantic Memory (认知模式)
**File:** `memory/patterns.md`
**Update:** Daily distillation cron (22:00)
**Purpose:** Extract recurring patterns from L1 + L2.

**Format:**
```markdown
# Patterns

## Park's Working Style
- <observation> (first noted: YYYY-MM-DD, confirmed: N times)

## Market Patterns
- <pattern> (evidence: ...)

## System/Engineering Patterns
- <pattern> (evidence: ...)

## Anti-Patterns (things that failed)
- <what> → <why it failed> (date)
```

**Rules:**
- Only add patterns observed 2+ times
- Include counter-evidence when it exists
- Mark confidence: 🟢 strong / 🟡 emerging / 🔴 challenged
- Remove or downgrade patterns that get contradicted

### Layer 4: Core Principles (原子原则)
**File:** `PRINCIPLES.md` (workspace root)
**Update:** Weekly review (Sunday 20:00)
**Purpose:** The most compressed, highest-value knowledge.

**Format:**
```markdown
# Principles

## Investing
- **<principle>** — <one-line explanation> [weight: 1-10] [last validated: date]

## Building
- **<principle>** — <one-line explanation> [weight: 1-10] [last validated: date]

## Meta / Thinking
- **<principle>** — <one-line explanation> [weight: 1-10] [last validated: date]
```

**Rules:**
- Max 30 principles total (forces prioritization)
- Each must be actionable (not platitude)
- Weight reflects confidence (1=hypothesis, 10=proven)
- Weekly review: validate, challenge, merge, or remove
- New principle needs 3+ supporting observations from L3

## Distillation Processes

### Daily Distillation (每日蒸馏, 22:00)
1. Read today's L1 data (memory/YYYY-MM-DD.md, conversation history)
2. Read any new L2 decision logs
3. Ask three questions:
   - What did we learn today that we didn't know yesterday?
   - Was any existing pattern (L3) confirmed or challenged?
   - Did any decision (L2) produce an unexpected outcome?
4. Update `memory/patterns.md` if warranted
5. Post summary to 🧠 Meta topic for Park to review

### Weekly Principle Review (每周原则审查, Sunday 20:00)
1. Read all L3 pattern updates from the past week
2. Read all L2 decision outcomes
3. For each existing principle in L4:
   - Was it validated this week? → update date
   - Was it challenged? → note evidence, consider downgrade
   - Is it redundant with another? → merge
4. Any new pattern strong enough (3+ observations) to become a principle?
5. Post review to 🧠 Meta topic

### Heartbeat Check (每次 heartbeat)
Quick scan: is there an unlogged significant decision from recent conversation?
If yes: create L2 decision log.
If no: pass.

## Integration with OpenClaw

**Cron jobs needed:**
- Daily distillation: `0 22 * * *` → isolated agentTurn
- Weekly review: `0 20 * * 0` → isolated agentTurn

**Files to create on first run:**
```
mkdir -p memory/decisions
touch memory/patterns.md
touch PRINCIPLES.md
```

## Key Principles of This Skill

- **Compression over accumulation** — The goal is less data, more wisdom
- **Evidence-based** — No principle without supporting observations
- **Mutable** — Principles can be wrong. Downgrade or remove when contradicted
- **Human-in-the-loop** — Park reviews weekly; the system proposes, Park decides
- **Model-upgrade amplified** — More data + better model = deeper distillation
