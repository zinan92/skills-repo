---
name: product-readme
description: Writes comprehensive READMEs serving both human readers and AI agent readers. Use when user says "用 GitHub Skill", "productize README", or asks to create a product-grade README for a repo.
platform: both
scope: global
---

# Product README Generator

Generate product-grade READMEs that serve two audiences: human readers (developers, users, contributors) and AI agent readers (tools, dependencies, integrations).

## Trigger

User says one of:
- "用 GitHub Skill"
- "productize README"
- "write product README"

## Workflow

### Step 1: Understand the Project

Read the following files (skip any that don't exist):

| Priority | File | Purpose |
|----------|------|---------|
| 1 | `CLAUDE.md` | Agent instructions, architecture overview |
| 2 | `README.md` | Existing README (to preserve useful content) |
| 3 | `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` | Name, version, dependencies |
| 4 | Main entry point (`main.py`, `app.py`, `src/index.ts`, etc.) | Core functionality |
| 5 | API route files (`routes/`, `api/`, `endpoints/`) | Available endpoints |
| 6 | Config files (`.env.example`, `config.py`, `settings.py`) | Required configuration |
| 7 | `docker-compose.yml` / `Dockerfile` | Deployment info |

Then summarize internally:
- What problem does this project solve?
- Who is the target user?
- What are the key features?
- What APIs/interfaces does it expose?
- What is the tech stack?

### Step 2: Write the README

Write `README.md` in Chinese (code blocks and technical terms stay in English). Follow the template structure below exactly.

### Step 3: Update GitHub Repo Metadata

After writing the README, update the GitHub repo:

```bash
# Set repo description (Chinese, under 350 chars)
gh repo edit --description "项目的一句话描述"

# Add relevant topics (lowercase, hyphenated)
gh repo edit --add-topic "topic1" --add-topic "topic2" --add-topic "topic3"
```

Topic selection guide:

| Category | Example Topics |
|----------|---------------|
| Language/Framework | `python`, `fastapi`, `react`, `typescript` |
| Domain | `trading`, `nlp`, `data-pipeline`, `content` |
| Purpose | `api`, `cli`, `automation`, `monitoring` |
| Integration | `openai`, `telegram`, `mcp` |

### Step 4: Commit and Push

```bash
git add README.md
git commit -m "docs: productize README for human + agent readers"
git push
```

### Step 5: Update GitHub Profile (Conditional)

After pushing the repo README, check whether this project should appear on the GitHub profile.

**Gate conditions — ALL must be true:**

1. Repo is **public**: `gh api repos/OWNER/REPO --jq '.private'` returns `false`
2. Project is **substantial** enough to showcase (not a config repo, dotfiles, or trivial fork)

If either fails, skip this step silently.

**If conditions pass, ask the user:**

> "要更新 GitHub profile 吗？放在哪个分类下？（data / content / agent / 新分类）"

Wait for the user's answer. Do NOT auto-pick a category.

**Profile structure reference:**

The profile lives at `github.com/zinan92/zinan92` (`README.md`). The "what I'm building" section uses `### <category>` headers with entries in this format:

```markdown
### <category>

EMOJI **[repo-name](https://github.com/zinan92/repo-name)** — one-line description
```

**Execution:**

```bash
# 1. Clone profile repo (shallow, to /tmp)
gh repo clone zinan92/zinan92 /tmp/zinan92-profile -- --depth 1

# 2. Edit /tmp/zinan92-profile/README.md:
#    - Find the ### <category> section the user chose
#    - If entry already exists for this repo → update the description
#    - If entry doesn't exist → append under that category header
#    - If category doesn't exist → create new ### <category> section before the --- separator

# 3. Commit and push
cd /tmp/zinan92-profile
git add README.md
git commit -m "docs: add/update <repo-name> in profile"
git push

# 4. Clean up
rm -rf /tmp/zinan92-profile
```

**Entry format rules:**

| Field | Rule |
|-------|------|
| Emoji | Pick one that matches the project domain (📊 data, 🧠 AI, ✂️ video, 📥 download, 🤖 agent, 🔧 tool, etc.) |
| Repo name | Exact GitHub repo name, linked |
| Description | One line, English or mixed — match existing profile tone (witty, concise) |
| Dedup | If the repo already appears in ANY category, update in place instead of duplicating |

---

## README Template

Below is the complete template. Replace all `{{placeholders}}` with actual project values.

````markdown
<div align="center">

# {{PROJECT_NAME}}

**{{一句话价值主张 — 这个项目解决什么问题}}**

[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://python.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

</div>

---

## 痛点

{{描述用户/开发者面临的具体问题，2-3 句话}}

## 解决方案

{{这个项目如何解决上述痛点，2-3 句话}}

## 架构

```
{{ASCII 架构图 — 展示主要组件和数据流}}
{{例如:}}
┌──────────┐     ┌──────────┐     ┌──────────┐
│  数据源   │────▶│  处理引擎  │────▶│  存储层   │
└──────────┘     └──────────┘     └──────────┘
                       │
                       ▼
                 ┌──────────┐
                 │  API 层   │
                 └──────────┘
```

## 快速开始

```bash
# 1. 克隆仓库
git clone {{REPO_URL}}
cd {{REPO_DIR}}

# 2. 安装依赖
{{INSTALL_COMMAND}}

# 3. 配置环境变量
cp .env.example .env
# 编辑 .env 填入必要配置

# 4. 启动服务
{{START_COMMAND}}
```

## 功能一览

| 功能 | 说明 | 状态 |
|------|------|------|
| {{功能名}} | {{简要说明}} | {{已完成/开发中/计划中}} |

## API 参考

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/v1/{{resource}}` | {{说明}} |
| `POST` | `/api/v1/{{resource}}` | {{说明}} |

## 技术栈

| 层级 | 技术 | 用途 |
|------|------|------|
| 运行时 | {{Python 3.11+}} | {{核心语言}} |
| 框架 | {{FastAPI}} | {{Web 框架}} |
| 数据库 | {{SQLite}} | {{数据持久化}} |
| 部署 | {{Docker}} | {{容器化}} |

## 项目结构

```
{{PROJECT_NAME}}/
├── src/                  # 源代码
│   ├── api/              # API 路由
│   ├── models/           # 数据模型
│   ├── services/         # 业务逻辑
│   └── utils/            # 工具函数
├── tests/                # 测试
├── config/               # 配置文件
├── .env.example          # 环境变量模板
└── README.md
```

## 配置

| 变量 | 说明 | 必填 | 默认值 |
|------|------|------|--------|
| `{{ENV_VAR}}` | {{说明}} | {{是/否}} | {{默认值}} |

## For AI Agents

本节面向需要将此项目作为工具或依赖集成的 AI Agent。

### 结构化元数据

```yaml
name: {{project_name}}
description: {{一句话英文描述}}
version: {{version}}
api_base_url: http://localhost:{{port}}
endpoints:
  - path: /api/v1/{{resource}}
    method: GET
    description: {{what it returns}}
    params:
      - name: {{param}}
        type: string
        required: true
  - path: /api/v1/{{resource}}
    method: POST
    description: {{what it does}}
    body:
      content_type: application/json
      schema:
        field: type
install_command: {{pip install -r requirements.txt / npm install / etc.}}
start_command: {{python main.py / npm start / etc.}}
health_check: GET /health
dependencies:
  - {{dependency_1}}
  - {{dependency_2}}
capabilities:
  - {{capability_1 — 用英文动词短语, e.g. "fetch real-time stock data"}}
  - {{capability_2}}
  - {{capability_3}}
input_format: {{JSON / CSV / plain text}}
output_format: {{JSON API response}}
```

### Agent 调用示例

```python
import httpx

# {{描述这个工作流场景}}
async def agent_workflow():
    base = "http://localhost:{{port}}"

    # Step 1: {{操作说明}}
    resp = await httpx.AsyncClient().get(f"{base}/api/v1/{{resource}}")
    data = resp.json()

    # Step 2: {{操作说明}}
    result = await httpx.AsyncClient().post(
        f"{base}/api/v1/{{resource}}",
        json={"key": "value"}
    )
    return result.json()
```

### MCP / Tool-Use 接口

如果此项目可作为 MCP Server 或 Tool 使用：

```json
{
  "tool_name": "{{project_name}}",
  "description": "{{工具描述}}",
  "parameters": {
    "action": {
      "type": "string",
      "enum": ["{{action1}}", "{{action2}}"],
      "description": "要执行的操作"
    },
    "query": {
      "type": "string",
      "description": "查询参数"
    }
  }
}
```

> 如果项目不暴露 API（例如纯 CLI 工具），则将 Agent 调用示例改为命令行调用，MCP 接口部分可删除。

## 相关项目

| 项目 | 说明 | 链接 |
|------|------|------|
| {{相关项目}} | {{关系说明}} | {{链接}} |

## License

{{LICENSE_TYPE}}
````

---

## Writing Rules

| Rule | Details |
|------|---------|
| Language | Chinese for prose, English for code/technical terms |
| Badges | Only include badges that are accurate and verifiable |
| ASCII diagrams | Use box-drawing characters (`┌─┐│└─┘`), not ASCII art |
| Quick start | Must be copy-paste ready, numbered, tested |
| Agent metadata | YAML block must be syntactically valid — test parse mentally |
| Placeholders | Remove ALL `{{}}` placeholders — replace with real values |
| Length | Aim for 200-400 lines; cut fluff, keep substance |
| No fabrication | Only document features that actually exist in the codebase |
| API section | Only include if the project actually exposes HTTP endpoints |
| MCP section | Only include if the project can function as an MCP server or tool |
| Agent example | Always include — even CLI tools can show shell-based agent usage |

## Conditional Sections

Not all sections apply to every project. Follow these rules:

| Section | Include when |
|---------|-------------|
| API 参考 | Project has HTTP endpoints |
| MCP / Tool-Use 接口 | Project can serve as MCP server or callable tool |
| 配置 | Project uses environment variables or config files |
| Agent 调用示例 | Always — adapt format (HTTP for APIs, shell for CLIs) |
| 相关项目 | Project is part of a larger ecosystem |

## CLI-Only Project Adaptation

For projects without HTTP APIs, adapt the Agent section:

```yaml
# In structured metadata, replace api_base_url/endpoints with:
cli_command: {{command_name}}
cli_args:
  - name: {{arg}}
    type: string
    required: true
    description: {{说明}}
cli_flags:
  - name: --{{flag}}
    type: boolean
    description: {{说明}}
```

Agent example becomes:

```python
import subprocess

result = subprocess.run(
    ["{{command}}", "--flag", "value"],
    capture_output=True, text=True
)
output = result.stdout
```
