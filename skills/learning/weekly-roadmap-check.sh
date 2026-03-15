#!/bin/bash
# Weekly roadmap check - runs Wed 20:00
# Sends Park a learning recommendation based on recent project activity

ROADMAP="$HOME/work/agents-co/knowledge-graph/learning/roadmap.md"
PROJECTS=("$HOME/ashare" "$HOME/park-intel" "$HOME/work/agents-co/wendy")

# Check recent git activity
ACTIVITY=""
for proj in "${PROJECTS[@]}"; do
  name=$(basename "$proj")
  if [ -d "$proj/.git" ]; then
    commits=$(cd "$proj" && git log --oneline --since="7 days ago" 2>/dev/null | head -5)
    if [ -n "$commits" ]; then
      ACTIVITY="$ACTIVITY\n📂 $name:\n$commits\n"
    fi
  fi
done

if [ -z "$ACTIVITY" ]; then
  ACTIVITY="本周没检测到 git 提交活动。"
fi

# Build message
MSG="📚 **Weekly Learning Check-in**

本周项目活动:
$(echo -e "$ACTIVITY")

📋 当前 Roadmap: ~/work/agents-co/knowledge-graph/learning/roadmap.md

建议: 查看 roadmap 中 🔴 Now 阶段的任务，挑一个花 2h 推进。
项目驱动 > 系统学习。遇到什么就学什么。"

# Send via openclaw message
cd "$HOME/work/agents-co/wendy"
openclaw message send --target 1416138619 --accountId wendy --message "$MSG" 2>/dev/null || echo "Failed to send message"
