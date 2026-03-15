# wendy-skills-repo

Skills 的唯一真相来源。版本控制，symlink 安装。

## 目录结构

```
skills/
  <skill-name>/
    SKILL.md          # 必须包含 platform + scope frontmatter
    ...               # 其他文件（脚本、参考资料等）
install.sh            # 安装器：根据 frontmatter 路由
uninstall.sh          # 卸载器：按 manifest 清理 symlinks
manifest/             # 安装清单
tests/                # 测试
```

## 路由机制

每个 `skills/<name>/SKILL.md` 的 frontmatter 包含两个路由字段：

```yaml
---
name: my-skill
description: ...
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

## Agent -> Workspace 映射

| Agent    | Workspace                                    |
|----------|----------------------------------------------|
| wendy    | `/Users/wendy/work/agents-co/wendy`          |
| monica   | `/Users/wendy/work/agents-co/monica`          |
| donald   | `/Users/wendy/work/content-co/ceo-donald`     |
| rachel   | `/Users/wendy/work/content-co/researcher-rachel` |
| ross     | `/Users/wendy/work/content-co/distribution-lead-ross` |
| chandler | `/Users/wendy/work/content-co/seedance-expert-chandler` |
| gunther  | `/Users/wendy/work/content-co/analyst-gunther` |
| echo     | `/Users/wendy/work/trading-co/echo`           |
| justin   | `/Users/wendy/work/data-co/JUSTIN-quant-workspace` |
| vincent  | `/Users/wendy/work/data-co/VINCENT-qual-workspace` |
| michelle | `/Users/wendy/work/trading-co/newsletter-michelle` |

## 安装

```bash
# 预览（dry-run）
bash install.sh --dry-run

# 安装所有 skills
bash install.sh

# 只安装某个 agent 相关的 skills
bash install.sh --agent wendy
```

## 卸载

```bash
bash uninstall.sh
```

只会删除 `manifest/install-manifest.json` 中记录的 symlinks，不会碰本 repo 的源文件。

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

## 平台支持

| 平台         | 发现路径                           |
|-------------|-----------------------------------|
| OpenClaw    | `<workspace>/.agents/skills/`     |
| Claude Code | `<workspace>/.claude/skills/`     |
| Pi          | `<workspace>/.agents/skills/`（同 OpenClaw） |
