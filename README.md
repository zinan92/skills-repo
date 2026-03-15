<div align="center">

# skills-repo

**AI Agent Skills 的唯一真相来源 — 版本控制、frontmatter 路由、symlink 安装**

![Skills](https://img.shields.io/badge/skills-60-blue)
![Platform](https://img.shields.io/badge/platform-claude--code%20%7C%20openclaw-green)
![Shell](https://img.shields.io/badge/installer-bash-yellow)
![Agents](https://img.shields.io/badge/agents-11-purple)

</div>

---

## 痛点

管理 AI agent 的 skills 是一件混乱的事情：

- **散落各处** — skills 文件分散在不同 agent workspace、不同平台目录，没有统一管理
- **版本失控** — 同一个 skill 被复制到多个地方，修改后无法同步
- **路由靠人脑** — 哪个 skill 装到哪个 agent、哪个平台，全凭记忆
- **无法批量操作** — 新增或更新一个 skill，需要手动复制到每个目标位置

## 解决方案

**一个 repo 管理所有 skills，用 frontmatter 声明路由，用 symlink 安装。**

核心设计：

- **Single Source of Truth** — 所有 60 个 skills 统一存放在 `skills/` 目录
- **Flat Namespace** — 无嵌套，每个 skill 是 `skills/<name>/SKILL.md`
- **Frontmatter 驱动路由** — 每个 SKILL.md 用 YAML frontmatter 声明目标平台和作用域
- **Symlink 安装** — `install.sh` 读取 frontmatter，自动创建 symlink 到正确位置

## 架构

```
skills-repo/
│
├── skills/
│   ├── triage/SKILL.md            ─── platform: claude-code
│   ├── product-readme/SKILL.md    ─── platform: both, scope: global
│   ├── baoyu-cover-image/SKILL.md ─── platform: both, scope: company:content-co
│   ├── bird/SKILL.md              ─── platform: both, scope: agent:wendy
│   └── ... (60 skills)
│
├── install.sh          读取 frontmatter → 创建 symlinks
├── uninstall.sh        按 manifest 清理 symlinks
├── manifest/           安装清单（JSON）
└── tests/              测试
         │
         ▼
   ┌─────────────────────────────────────────────────┐
   │  install.sh 路由逻辑                              │
   │                                                   │
   │  scope: global     → ~/                           │
   │  scope: agent:X    → /workspace/of/X/             │
   │  scope: company:Y  → /workspace/of/每个Y的agent/  │
   │                                                   │
   │  platform: claude-code → .claude/skills/          │
   │  platform: openclaw    → .agents/skills/          │
   │  platform: both        → 两个目录都装              │
   └─────────────────────────────────────────────────┘
```

## 快速开始

```bash
# 克隆
git clone https://github.com/zinan92/skills-repo.git
cd skills-repo

# 预览（不会创建任何文件）
bash install.sh --dry-run

# 安装所有 skills
bash install.sh

# 只安装某个 agent 相关的 skills
bash install.sh --agent wendy

# 卸载所有 symlinks
bash uninstall.sh
```

## 功能一览

| 功能 | 说明 |
|------|------|
| **60 个 Skills** | 覆盖开发工作流、AI/ML、内容创作、交易、数据等领域 |
| **Flat Namespace** | `skills/<name>/SKILL.md`，无嵌套，无歧义 |
| **Platform 路由** | `claude-code` / `openclaw` / `both` — 自动安装到对应平台目录 |
| **Scope 路由** | `global`（全局）/ `agent:<name>`（单个 agent）/ `company:<company>`（公司下所有 agent） |
| **Symlink 安装** | 修改源文件即可同步到所有安装位置，无需重新安装 |
| **Manifest 追踪** | 安装清单记录所有 symlink，卸载时精确清理 |
| **Dry-run 模式** | `--dry-run` 预览安装结果 |
| **Agent 过滤** | `--agent <name>` 只安装特定 agent 的 skills |

## 路由机制

每个 `skills/<name>/SKILL.md` 的 frontmatter：

```yaml
---
name: my-skill
description: 做某件事的 skill
platform: claude-code    # claude-code | openclaw | both
scope: global            # global | agent:<name> | company:<company>
---
```

### platform（目标平台）

| 值 | 安装位置 |
|---|---------|
| `claude-code` | `<target>/.claude/skills/` |
| `openclaw` | `<target>/.agents/skills/` |
| `both` | 两个目录都装 |

### scope（作用域）

| 值 | 行为 |
|---|------|
| `global` | 安装到 `~/`（所有 agent 共享） |
| `agent:<name>` | 安装到该 agent 的 workspace |
| `company:<company>` | 安装到该公司下所有 agent 的 workspace |

### Agent → Workspace 映射

| Agent | Workspace | 公司 |
|-------|-----------|------|
| wendy | `agents-co/wendy` | agents-co |
| monica | `agents-co/monica` | agents-co |
| donald | `content-co/ceo-donald` | content-co |
| rachel | `content-co/researcher-rachel` | content-co |
| ross | `content-co/distribution-lead-ross` | content-co |
| chandler | `content-co/seedance-expert-chandler` | content-co |
| gunther | `content-co/analyst-gunther` | content-co |
| echo | `trading-co/echo` | trading-co |
| michelle | `trading-co/newsletter-michelle` | trading-co |
| justin | `data-co/JUSTIN-quant-workspace` | data-co |
| vincent | `data-co/VINCENT-qual-workspace` | data-co |

## 技术栈

| 技术 | 用途 |
|------|------|
| Bash | 安装/卸载脚本 |
| YAML Frontmatter | Skill 元数据与路由声明 |
| Symlinks | 零拷贝安装，源文件修改即时生效 |
| JSON Manifest | 安装记录，支持精确卸载 |

## Skill 列表

### 开发工作流（Dev Workflow）

| Skill | 平台 | 作用域 | 说明 |
|-------|------|--------|------|
| `triage` | claude-code | global | 任务分类 — 决定如何执行 |
| `writing-plans` | claude-code | global | 从需求到实现计划 |
| `executing-plans` | claude-code | global | 带 review checkpoint 的计划执行 |
| `mvu-execution` | claude-code | global | 100-300 行的原子执行单元，含 reviewer 和升级路径 |
| `test-driven-development` | claude-code | global | TDD：先写测试再实现 |
| `requesting-code-review` | claude-code | global | 完成任务后请求 code review |
| `receiving-code-review` | claude-code | global | 收到 review 反馈后的技术验证流程 |
| `verification-before-completion` | claude-code | global | 完成前运行验证命令，证据先于断言 |
| `finishing-a-development-branch` | claude-code | global | 开发分支完成后的集成决策 |
| `using-git-worktrees` | claude-code | global | 创建隔离的 git worktree |
| `dispatching-parallel-agents` | claude-code | global | 并行分发独立任务 |
| `subagent-driven-development` | claude-code | global | 用 sub-agent 执行实现计划 |
| `systematic-debugging` | openclaw | global | 系统化调试流程 |
| `github` | both | agent:monica | GitHub 操作：issues, PRs, CI |

### AI Agent 管理

| Skill | 平台 | 作用域 | 说明 |
|-------|------|--------|------|
| `agent-onboarding` | both | agent:wendy | 新 agent 初始化和环境配置 |
| `agent-estimation` | both | agent:wendy | 用 tool-call rounds 估算 agent 工作量 |
| `using-superpowers` | claude-code | global | 会话开始时发现和使用 skills |
| `find-skills` | openclaw | global | 帮助用户发现可安装的 skills |
| `writing-skills` | claude-code | global | 创建和编辑 skills |
| `delegation` | both | agent:wendy | 任务委派 |
| `proactive-agent` | both | agent:wendy | 从任务执行者到主动合作伙伴 |
| `continuous-learning-v2` | both | agent:wendy | 基于 instinct 的学习系统 |
| `learning` | both | agent:wendy | 每周学习路线推荐 |

### 思维与认知

| Skill | 平台 | 作用域 | 说明 |
|-------|------|--------|------|
| `brainstorming` | openclaw | global | 创意工作前的意图探索 |
| `intent-clarifier` | both | agent:wendy | 模糊想法的交互式澄清 |
| `cognitive-distillation` | both | agent:wendy | 四层认知蒸馏：Raw → Episodic → Semantic → Principles |
| `connect-the-dots` | both | agent:wendy | Obsidian 知识库的知识编排 |
| `ontology` | both | agent:wendy | 类型化知识图谱 |

### 内容创作（Baoyu 系列）

| Skill | 平台 | 作用域 | 说明 |
|-------|------|--------|------|
| `baoyu-image-gen` | both | company:content-co | AI 图片生成（OpenAI, Google, DashScope, Replicate） |
| `baoyu-cover-image` | both | company:content-co | 文章封面图生成（5维度 × 9色板 × 6渲染风格） |
| `baoyu-article-illustrator` | both | company:content-co | 文章配图（Type × Style 二维方法） |
| `baoyu-infographic` | both | company:content-co | 信息图生成（21布局 × 20视觉风格） |
| `baoyu-xhs-images` | both | company:content-co | 小红书图片系列（10风格 × 8布局） |
| `baoyu-comic` | both | company:content-co | 知识漫画创作 |
| `baoyu-slide-deck` | both | company:content-co | 幻灯片生成 |
| `baoyu-format-markdown` | both | company:content-co | Markdown 格式化美化 |
| `baoyu-markdown-to-html` | both | company:content-co | Markdown 转 HTML（支持微信主题） |
| `baoyu-url-to-markdown` | both | company:content-co | 网页转 Markdown（Chrome CDP） |
| `baoyu-compress-image` | both | company:content-co | 图片压缩（WebP/PNG） |
| `baoyu-post-to-wechat` | both | company:content-co | 发布到微信公众号 |
| `baoyu-post-to-x` | both | company:content-co | 发布到 X/Twitter |
| `baoyu-danger-x-to-markdown` | both | company:content-co | X/Twitter 内容转 Markdown |
| `baoyu-danger-gemini-web` | both | company:content-co | Gemini Web API 图片/文本生成 |

### UI/UX 与前端

| Skill | 平台 | 作用域 | 说明 |
|-------|------|--------|------|
| `ui-ux-pro-max` | openclaw | global | UI/UX 设计（50风格, 21色板, 50字体组合, 8技术栈） |
| `d3-viz` | openclaw | global | D3.js 数据可视化 |
| `tailwindcss-advanced-layouts` | openclaw | global | Tailwind CSS 高级布局 |
| `nextjs-app-router-patterns` | openclaw | global | Next.js 14+ App Router |
| `remotion-best-practices` | both | agent:donald | Remotion 视频逻辑 |

### 后端与 API

| Skill | 平台 | 作用域 | 说明 |
|-------|------|--------|------|
| `fastapi-python` | openclaw | global | FastAPI Python 开发 |
| `fastapi-async-patterns` | openclaw | global | FastAPI 异步模式 |

### 数据与信息源

| Skill | 平台 | 作用域 | 说明 |
|-------|------|--------|------|
| `hackernews` | both | agent:monica | Hacker News API |
| `reddit` | both | agent:monica | Reddit 内容检索 |
| `blogwatcher` | both | agent:monica | RSS/Atom 博客监控 |
| `summarize` | both | agent:monica | URL/播客/本地文件摘要 |
| `bird` | both | agent:wendy | X/Twitter CLI |
| `obsidian` | both | agent:monica | Obsidian vault 操作 |

### 交易与风控

| Skill | 平台 | 作用域 | 说明 |
|-------|------|--------|------|
| `risk-management` | openclaw | global | 仓位管理和止损规则 |

### 文档与产品化

| Skill | 平台 | 作用域 | 说明 |
|-------|------|--------|------|
| `product-readme` | both | global | 产品级 README 撰写（人类 + agent 双读者） |

### 工具

| Skill | 平台 | 作用域 | 说明 |
|-------|------|--------|------|
| `mgrep` | both | agent:wendy | 搜索工具 |
| `linear` | both | agent:wendy | Linear 集成 |

## 添加新 Skill

1. 创建 `skills/<skill-name>/SKILL.md`
2. 在 frontmatter 中设置 `platform` 和 `scope`
3. 提交并推送
4. 执行 `bash install.sh` 刷新 symlinks

示例：

```yaml
---
name: my-new-skill
description: 做某件事的 skill
platform: both
scope: agent:wendy
---

# My New Skill

具体说明...
```

## For AI Agents

```yaml
# ── Agent-Readable Metadata ──
name: skills-repo
description: >
  Centralized repository of 60 AI agent skills with frontmatter-driven
  routing and symlink-based installation. Single source of truth for
  skill management across multiple agents and platforms.
capabilities:
  - Install skills to claude-code and openclaw platforms via symlinks
  - Route skills by scope (global, per-agent, per-company)
  - Manage 60 skills across dev workflow, content creation, trading, and more
  - Dry-run mode for safe preview
  - Manifest-based uninstall for clean removal
install_command: "bash install.sh"
uninstall_command: "bash uninstall.sh"
preview_command: "bash install.sh --dry-run"
repo: "https://github.com/zinan92/skills-repo"
```

### Agent 如何使用

1. **发现 skill** — 浏览 `skills/` 目录或搜索 SKILL.md 的 frontmatter
2. **阅读 skill** — 每个 `skills/<name>/SKILL.md` 包含完整的 skill 说明和触发条件
3. **安装 skill** — 运行 `bash install.sh` 或 `bash install.sh --agent <name>`
4. **使用 skill** — 安装后，skill 会出现在平台的 skills 发现路径中

### Frontmatter 结构

```yaml
---
name: skill-name           # 唯一标识
description: ...           # 功能描述和触发条件
platform: claude-code      # 目标平台
scope: global              # 作用域
---
```

## 相关项目

- [agent-core](https://github.com/zinan92) — Agent 基础设施

## License

Private repository.
