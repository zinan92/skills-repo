---
platform: both
scope: agent:wendy
---

# Delegation Skill

标准化 sub-agent 委派模板，遵循 "Consume Uncertainty at Definition" 原则。

## 标准 Prompt 结构模板

```markdown
## 背景
[为什么要做这个任务，相关文件/链接]

## 目标
[一句话说清楚要达成什么]

## 步骤
[具体的 1-2-3 步骤，每步包含可执行的命令]

## 必填 Checklist
- [ ] 写死所有环境信息（路径、API URL、accountId）
- [ ] 指定输出格式
- [ ] 指定 git commit 消息
- [ ] 指定 Linear 状态更新命令
- [ ] 指定通知方式（message tool + accountId + target）

## 验证
[怎么确认任务成功完成]

## 收尾
[Linear 更新 + git commit + 通知]
```

## 委派 Checklist（每次 spawn 前检查）

1. ✅ 任务边界明确？（一个 sub-agent 只做一件事）
2. ✅ 所有路径写死？（不依赖 agent 猜测）
3. ✅ 输出格式定义？（不靠 agent 自由发挥）
4. ✅ 成功标准明确？（怎么判断完成）
5. ✅ accountId/target 写死？（message tool 必填项）
6. ✅ git commit 消息写好？
7. ✅ Linear 状态更新命令写好？

## 常见委派场景模板

### 1. 开发任务（新增 collector/feature）

```markdown
## 背景
需要新增 [具体功能]，相关文件：~/clawd/[具体路径]

## 目标
实现 [具体功能描述] 并集成到现有系统

## 步骤
1. 分析现有代码结构：`ls -la ~/clawd/[路径]`
2. 创建新文件：`~/clawd/[具体路径/文件名]`
3. 编写实现代码，参照 [现有模块] 的模式
4. 运行测试：`cd ~/clawd && npm test [测试命令]`
5. 验证集成：[具体验证命令]

## 必填 Checklist
- [ ] 路径：~/clawd/[具体路径]
- [ ] 输出格式：完整可运行代码 + 测试结果
- [ ] Git commit: "Add [功能名]: [简短描述]"
- [ ] Linear 更新：`cd ~/clawd/skills/linear && bash linear.sh update [TICKET-ID] --status done`
- [ ] 通知：通过主 agent 报告完成状态

## 验证
运行 `[具体测试命令]` 无错误，功能正常工作

## 收尾
Linear 更新 + git commit + 报告完成
```

### 2. 调研任务（评估工具/方案）

```markdown
## 背景
需要评估 [工具/方案名称] 解决 [具体问题]

## 目标
提供 [工具/方案] 的评估报告，包含优缺点和推荐方案

## 步骤
1. web_search 搜索相关资料
2. web_fetch 获取官方文档
3. 分析技术栈兼容性
4. 整理评估报告：~/clawd/docs/research/[主题].md

## 必填 Checklist
- [ ] 输出路径：~/clawd/docs/research/[具体文件名].md
- [ ] 输出格式：结构化 markdown（问题/方案/优缺点/推荐）
- [ ] Git commit: "Research: [主题] evaluation report"
- [ ] Linear 更新：`cd ~/clawd/skills/linear && bash linear.sh update [TICKET-ID] --status done`
- [ ] 通知：通过主 agent 报告关键发现

## 验证
报告包含明确的推荐方案和决策依据

## 收尾
保存报告 + Linear 更新 + git commit + 报告要点
```

### 3. 运维任务（修 cron/写文档）

```markdown
## 背景
需要 [修复/更新/创建] [具体运维项目]，相关文件：[路径]

## 目标
[一句话描述运维目标]

## 步骤
1. 检查现状：`[具体检查命令]`
2. 备份现有配置：`cp [原文件] [备份路径]`
3. 修改配置：[具体修改步骤]
4. 验证配置：`[验证命令]`
5. 记录变更：更新 ~/clawd/docs/ops/[相关文档].md

## 必填 Checklist
- [ ] 备份路径：[具体备份位置]
- [ ] 配置文件：[具体路径]
- [ ] 验证命令：[具体命令]
- [ ] Git commit: "Ops: [简短描述变更]"
- [ ] Linear 更新：`cd ~/clawd/skills/linear && bash linear.sh update [TICKET-ID] --status done`
- [ ] 通知：通过主 agent 确认变更生效

## 验证
运行验证命令确认配置生效，无错误日志

## 收尾
Linear 更新 + git commit + 报告变更状态
```

## 反模式

### ❌ 常见委派错误

- **太模糊**："帮我做 X" → 缺少具体步骤和标准
- **依赖猜测**：不写路径靠 agent 找 → 增加不确定性
- **格式不定**：不指定输出格式 → agent 自由发挥质量不控
- **标准不明**：成功标准模糊 → 无法判断完成质量
- **信息缺失**：忘记 accountId/target → message tool 调用失败
- **收尾不全**：忘记 git commit/Linear 更新 → 工作流断裂

### ✅ 好的委派特征

- **边界清晰**：一个 sub-agent 一个任务
- **信息完整**：所有必要参数写死
- **标准明确**：有具体的验证方式
- **流程闭环**：包含完整的收尾流程

## 使用方式

1. 选择对应场景模板
2. 填入具体信息（路径、命令、参数）
3. 过一遍委派 Checklist
4. spawn sub-agent 执行

## 质量原则

- **简洁**：一页能看完所有要点
- **实用**：模板可直接复制修改使用
- **标准化**：减少遗漏，提高执行质量