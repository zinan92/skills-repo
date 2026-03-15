<div align="center">

# skills-repo

**把 AI agent skills 统一收纳到一个仓库里，按 `data / content / dev / trading` 四类组织，并用 frontmatter + symlink 安装到正确的 agent workspace。**

[![Skills](https://img.shields.io/badge/skills-62-blue.svg)](https://github.com/zinan92/skills-repo)
[![Platforms](https://img.shields.io/badge/platform-claude--code%20%7C%20openclaw-green.svg)](https://github.com/zinan92/skills-repo)
[![Installer](https://img.shields.io/badge/installer-bash-yellow.svg)](https://github.com/zinan92/skills-repo)

</div>

---

## 痛点

当一个人同时维护多个 agent、多个 workspace 和多个工作域时，skills 很容易失控：同一个 skill 被复制到不同目录，修改后不同步；哪些 skill 应该装到哪个 agent，只能靠记忆；一旦数量上来，安装、升级和清理都变成体力活。

更麻烦的是，skill 的“发现视角”和“安装视角”往往混在一起。你既需要按业务域去整理技能库，也需要按平台和作用域把它们路由到正确的目录。

## 解决方案

`skills-repo` 把所有 skills 放进一个公共仓库，用四个业务分类子目录组织发现层结构，再用每个 `SKILL.md` 里的 `platform` 和 `scope` frontmatter 驱动安装。目录负责“好找”，frontmatter 负责“装对”。

安装器 `install.sh` 会递归扫描 `skills/` 下的 `SKILL.md`，把对应 skill 目录 symlink 到 `~/.claude/skills`、`~/.agents/skills` 或特定 agent workspace。这样既保留了分类目录，也保留了单个 skill 目录的独立性。

## 架构

```text
skills-repo/
├── skills/
│   ├── data/
│   │   ├── hackernews/
│   │   ├── summarize/
│   │   └── ...
│   ├── content/
│   │   ├── baoyu-cover-image/
│   │   ├── baoyu-post-to-x/
│   │   └── ...
│   ├── dev/
│   │   ├── product-readme/
│   │   ├── skill-creator/
│   │   ├── using-superpowers/
│   │   ├── writing-skills/
│   │   └── ...
│   └── trading/
│       └── risk-management/
├── install.sh
├── uninstall.sh
├── manifest/install-manifest.json
└── tests/

recursive scan:
skills/<category>/<skill>/SKILL.md
        │
        ▼
read frontmatter(platform, scope)
        │
        ▼
route to ~/.claude/skills / ~/.agents/skills / agent workspace
```

## 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/zinan92/skills-repo.git
cd skills-repo

# 2. 安装依赖
# 无第三方依赖；需要 bash 和 python3（uninstall 使用）

# 3. 配置环境变量
# 本项目默认无需 .env，可跳过此步

# 4. 启动服务
# 预览安装结果
bash install.sh --dry-run

# 实际安装
bash install.sh

# 只安装某个 agent 相关的 skills
bash install.sh --agent monica

# 卸载由 manifest 记录的 symlinks
bash uninstall.sh
```

## 功能一览

| 功能 | 说明 | 状态 |
|------|------|------|
| Central skill registry | 统一管理 62 个 skills，避免多份副本漂移 | 已完成 |
| Four-category discovery layer | 通过 `data / content / dev / trading` 提升可发现性 | 已完成 |
| Recursive installer | 自动发现 `skills/<category>/<skill>/SKILL.md` 并安装对应 skill 根目录 | 已完成 |
| Frontmatter routing | 基于 `platform` / `scope` 路由到 home 或 agent workspace | 已完成 |
| Agent filter | 支持 `--agent <name>` 只安装目标 agent 相关 skills | 已完成 |
| Manifest-based uninstall | 用 `manifest/install-manifest.json` 跟踪已安装 symlink | 已完成 |
| Trading catalog expansion | `trading` 分类目前仍较薄，后续继续补充 | 计划中 |

## API 参考

| 方法 | 路径 | 说明 |
|------|------|------|
| `CLI` | `bash install.sh --dry-run` | 预览安装结果，不写入任何 symlink |
| `CLI` | `bash install.sh` | 安装所有可路由的 skills |
| `CLI` | `bash install.sh --agent <name>` | 仅安装某个 agent 需要的 skills |
| `CLI` | `bash uninstall.sh` | 删除 manifest 中记录的 symlink |
| `DOC` | `skills/<category>/<skill>/SKILL.md` | skill 定义、触发条件和 frontmatter 元数据 |

## 技术栈

| 层级 | 技术 | 用途 |
|------|------|------|
| 运行时 | Bash + Python 3 | 安装脚本与卸载逻辑 |
| 元数据 | YAML frontmatter | 描述 skill 的名称、平台和作用域 |
| 分发机制 | Symlink | 零拷贝安装，源 skill 更新可直接生效 |
| 状态记录 | JSON manifest | 跟踪安装目标，支持精确卸载 |

## 项目结构

```text
skills-repo/
├── skills/
│   ├── data/        # 数据获取、摘要、知识组织（9 个）
│   ├── content/     # 内容生产与发布（16 个）
│   ├── dev/         # 开发工作流、原 global 基础包、agent 管理、工程工具（36 个）
│   └── trading/     # 交易与风控（1 个）
├── tests/           # dry-run 与路由回归测试
├── manifest/        # 安装清单
├── install.sh       # 递归扫描并创建 symlinks
├── uninstall.sh     # 基于 manifest 清理 symlinks
└── README.md
```

## 配置

| 变量 | 说明 | 必填 | 默认值 |
|------|------|------|--------|
| `platform` | skill 目标平台：`claude-code` / `openclaw` / `both` | 是 | 无 |
| `scope` | skill 作用域：`global` / `agent:<name>` / `company:<company>` | 是 | 无 |
| `TARGET_AGENT` | 通过 `install.sh --agent <name>` 传入的安装过滤器 | 否 | 空 |
| `MANIFEST_FILE` | 安装清单输出位置 | 否 | `manifest/install-manifest.json` |

## 分类说明

| 分类 | 说明 | 当前数量 |
|------|------|----------|
| `data` | 数据源、摘要、知识组织与可视化 | 9 |
| `content` | 内容生成、排版、图片、分发 | 16 |
| `dev` | 开发工作流、原 `global` 基础技能包、agent 管理、工程与产品化技能 | 36 |
| `trading` | 交易与风险控制 | 1 |

## 路由规则

每个 skill 的真实安装行为由对应 `SKILL.md` 的 frontmatter 决定：

```yaml
---
name: product-readme
description: Use when user asks to productize a README for a repo
platform: both
scope: global
---
```

| 字段 | 值 | 行为 |
|------|----|------|
| `platform` | `claude-code` | 安装到 `.claude/skills/` |
| `platform` | `openclaw` | 安装到 `.agents/skills/` |
| `platform` | `both` | 两个目录都安装 |
| `scope` | `global` | 安装到用户 home 级 skills 目录 |
| `scope` | `agent:<name>` | 安装到指定 agent workspace |
| `scope` | `company:<company>` | 安装到该公司下所有已知 agent workspace |

## For AI Agents

本节面向把 `skills-repo` 当作技能仓库、安装源或能力索引来使用的 AI agent。

### 结构化元数据

```yaml
name: skills-repo
description: Centralized AI agent skills repository with category folders, frontmatter routing, and symlink installation.
version: repo-local
entrypoints:
  - bash install.sh --dry-run
  - bash install.sh
  - bash uninstall.sh
skill_layout:
  pattern: skills/<category>/<skill>/SKILL.md
  categories:
    - data
    - content
    - dev
    - trading
routing:
  platform:
    - claude-code
    - openclaw
    - both
  scope:
    - global
    - agent:<name>
    - company:<company>
```

### Agent 使用建议

1. 先浏览 `skills/` 的四大类，确定应在哪个业务域下找 skill。
2. 再读取目标 skill 的 `SKILL.md`，以 frontmatter 为准理解安装路由。
3. 需要批量安装时优先使用 `bash install.sh --dry-run` 预览结果。
4. 需要撤销安装时使用 `bash uninstall.sh`，不要手工删除一批未知 symlink。

## 添加新 Skill

```bash
# 1. 选择分类目录
mkdir -p skills/dev/my-new-skill

# 2. 创建 SKILL.md
$EDITOR skills/dev/my-new-skill/SKILL.md

# 3. 预览安装结果
bash install.sh --dry-run
```

新 skill 至少需要：

- 放在四大类中的某一个子目录下
- 在 `SKILL.md` 中声明 `platform` 与 `scope`
- 保持一个 skill 一个独立目录，便于附带 `references/`、`scripts/`、`assets/`

## License

This repository is public, but no open-source license is declared yet.
