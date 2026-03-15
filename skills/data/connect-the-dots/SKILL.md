---
name: connect-the-dots
description: "Knowledge orchestration for Obsidian vault. Use when: daily scan of new KB articles, updating MOC files, maintaining Vault Index, connecting new knowledge to existing, or evaluating article relevance. Runs as daily cron and on-demand when Park sends research requests."
platform: both
scope: agent:wendy
---

# Connect the Dots

Knowledge orchestration skill — scan new content, judge relevance, connect to existing knowledge, maintain MOC structure, update Vault Index.

## Core Principle

**You are the brain, not the librarian.** Monica collects and files. You connect, judge, and produce insight. Every new piece of knowledge must be woven into the existing web, or explicitly discarded.

## Vault Structure

```
~/work/agents-co/knowledge-graph/                    ← Obsidian vault
├── _system/                         ← L3: Principles (always loaded)
├── MOC/                             ← Map of Content (hub nodes)
│   ├── MOC-AI-Agent.md              ← Main hub → 5 sub-MOCs
│   ├── MOC-AI-Memory.md
│   ├── MOC-AI-Workflow.md
│   ├── MOC-AI-MultiAgent.md
│   ├── MOC-AI-Skills.md
│   ├── MOC-AI-Security.md
│   ├── MOC-Trading.md               ← Polymarket / CN / US / Crypto / Commodities
│   └── MOC-Media.md                 ← Content creation / Business
├── research/                        ← Monica's output (individual articles)
├── people/                          ← People profiles
├── tools/                           ← Tool evaluations
├── vault-index.md                   ← One-line summary per note (for fast scan)
└── briefings/                       ← Daily raw output (L1, not in MOC)
```

## Workflows

### 1. Daily Scan (cron trigger)

Run daily. Scan new articles added in last 24h.

```
Step 1: Find new files
  find ~/work/agents-co/knowledge-graph/research -name "*.md" -mtime -1

Step 2: For each new file:
  a. Read TL;DR + Key Takeaways + tags
  b. Determine which MOC(s) it belongs to
  c. Add article row to MOC table (title | one-line summary | relevance)
  d. Add MOC backlink to article's 连接 section
  e. Find 2-3 existing articles it connects to → add [[双向链接]] if missing
  f. Add one-line entry to vault-index.md

Step 3: Cross-pollinate
  - Any pattern emerging across today's articles? (3+ articles touching same theme)
  - If yes → note it in memory/patterns.md
  - If a new sub-theme is forming (5+ articles) → consider proposing new MOC

Step 4: Output summary (for daily distillation)
  - X new articles scanned
  - Key connections found
  - Any emerging patterns
```

### 2. On-Demand: Link Processing (Park sends URL to Wendy)

```
Step 1: Read content (web_fetch / summarize / whisper)

Step 2: Judge relevance (1-10)
  ≤ 4 → Tell Park "不太相关：[reason]". Stop.
  5-7 → Light note (TL;DR + 要点 + tags). Save to research/.
  8-10 → Full research note (Monica template). Save to research/.

Step 3: Connect
  a. Find 2-3 existing notes with strongest connection
  b. Add [[双向链接]] bidirectionally
  c. Add to appropriate MOC(s)
  d. Update vault-index.md

Step 4: Reply to Park
  📎 **{title}**
  要点：{one line}
  跟我们的关系：{one line}
  行动建议：{action or "存档，暂不行动"}
  已存：[[{note}]] → [[{MOC}]]
```

### 3. On-Demand: Topic Research (Park says "研究一下 X")

```
Step 1: Search existing KB
  grep + memory_search for related content

Step 2: Web research
  web_search → read top 5-10 sources

Step 3: Synthesize report
  - 现状概览
  - 关键玩家/观点
  - 跟 Park 的 thesis 的关系
  - Mermaid diagram (if structural relationships exist)
  - 可行动建议

Step 4: Save to research/ + connect + update MOC

Step 5: Reply with concise summary
```

### 4. On-Demand: Tool Evaluation (Park says "看看这个工具")

```
Step 1: Read docs / GitHub / demo

Step 2: Evaluate
  - 是什么 / 解决什么问题
  - 跟现有工具关系：替代？互补？无关？
  - 安装成本 / 学习成本
  - 建议：装 / 不装 / 观望

Step 3: Save to tools/ + update vault-index.md

Step 4: Reply with verdict + install plan if recommended
```

## MOC Update Rules

When adding an article to a MOC:

1. Add row to the `## 文章` table: `| [[article-name]] | one-line summary | X/10 |`
2. If article connects to articles in OTHER MOCs → add cross-reference in `## 连接` section
3. If `## 关键洞察` needs updating based on new evidence → update it
4. Never remove existing entries, only add

## Vault Index Format

`~/work/agents-co/knowledge-graph/vault-index.md`:

```markdown
# Vault Index
<!-- One-line per note. Agent scans this first, then reads full note if needed. -->

## Research
- [[260214-ClawVault-Agent记忆架构-Obsidian式]] — Markdown > vector DB for agent memory. Vault Index pattern.
- [[260213-OpenClaw记忆管理三层架构实战]] — 热/冷/原始三层, P0/P1/P2优先级, 自动归档.
...

## Tools
- [[claudian]] — Obsidian plugin embedding Claude Code CLI in vault.
...

## People
- [[steipete]] — OpenClaw power user, SOUL.md 最佳实践.
...
```

## Quality Gates

- **No orphan notes**: Every new note must link to ≥1 existing note + ≥1 MOC
- **No stale MOCs**: If a MOC hasn't been updated in 7 days but new articles exist → flag it
- **No bloated vault-index**: Each entry ≤ 15 words. It's a scan tool, not a summary.
- **Relevance filter**: Don't store ≤ 4/10 content. KB is curated, not comprehensive.
