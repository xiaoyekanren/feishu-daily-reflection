---
name: daily-reflection
description: "每日反思机制。自动分析过去 24 小时对话，更新 SOUL.md、USER.md、TOOLS.md、MEMORY.md、HEARTBEAT.md 等文档，保持 AI 记忆同步。"
metadata: { "openclaw": { "emoji": "📅", "requires": { "bins": ["bash", "jq"], "plugins": ["@larksuite/openclaw-lark-tools"] } } }
---

# 每日反思 Skill

自动分析过去 24 小时的对话历史，提取核心内容并更新所有相关文档。

## 当以下情况时使用此 Skill

✅ **USE this skill when:**

- 每天 8:00-9:00 执行每日反思
- 用户要求"反思昨天的对话"
- 需要更新 AI 记忆文档（SOUL.md、USER.md、TOOLS.md 等）
- 用户纠正了 AI 的行为或偏好
- 发现了新的工具/脚本需要记录
- 有新的用户偏好需要保存

❌ **DON'T use this skill when:**

- 非反思时间（8:00-9:00 之外）且用户未明确要求
- 只需要更新单个文档（直接编辑即可）
- 会话历史不足 24 小时

## 反思范围

| 问题 | 更新文档 |
|------|---------|
| 用户纠正过我什么？ | SOUL.md |
| 有没有新增工具/脚本？ | TOOLS.md |
| 有没有重复工作可以自动化？ | HEARTBEAT.md |
| 用户表达了什么新偏好？ | USER.md |
| 有什么值得长期记住的？ | MEMORY.md |

## 使用方法

### 手动触发

```bash
# 在 OpenClaw 会话中
/reflect
```

### 定时任务（推荐）

在 crontab 中添加：

```bash
0 8 * * * /path/to/daily-reflection.sh
```

### 集成到 HEARTBEAT.md

在心跳检查文件中添加反思逻辑：

```markdown
## 0. 每日反思（每天 8:00-9:00 执行一次）

**检查条件**：
- 当前时间在 8:00-9:00 之间
- 昨天记忆文件未更新

**执行动作**：
1. 获取过去 24 小时对话历史
2. AI 分析并提取核心内容
3. 更新对应文档
4. 记录反思时间到 memory/heartbeat-state.json
5. 发送反思报告给用户
```

## 反思报告格式

```markdown
## 📅 每日反思报告 (YYYY-MM-DD)

**反思时间范围**: 昨天 8:00 → 今天 8:00

### 更新的文档
| 文档 | 更新内容 |
|------|---------|
| SOUL.md | ... |
| TOOLS.md | ... |
| USER.md | ... |
| MEMORY.md | ... |

### 核心摘要
- 重要事件 1
- 重要事件 2
- ...
```

## 状态记录

在 `memory/heartbeat-state.json` 中记录：

```json
{
  "lastDailyReflection": "2026-03-20T08:00:00+08:00"
}
```

## 脚本示例

```bash
#!/bin/bash

# 每日反思脚本
REFLECTION_DATE=$(date +%Y-%m-%d)
REFLECTION_TIME=$(date -Iseconds)

# 更新状态文件
cat > memory/heartbeat-state.json << EOF
{
  "lastDailyReflection": "${REFLECTION_TIME}"
}
EOF

# 发送报告（飞书私聊示例）
openclaw message send \
  --channel feishu \
  --target "ou_xxx" \
  --message "## 📅 每日反思报告 (${REFLECTION_DATE})

**反思时间范围**: 昨天 8:00 → 今天 8:00

### 更新的文档
| 文档 | 更新内容 |
|------|---------|
| SOUL.md | ... |
| TOOLS.md | ... |

### 核心摘要
- ..."
```

## 依赖

- bash
- jq（JSON 处理）
- OpenClaw CLI
- **飞书插件**：`@larksuite/openclaw-lark-tools`

## 安装飞书插件

```bash
npx -y @larksuite/openclaw-lark-tools install
```

## 注意事项

1. **时间窗口** - 每天只执行一次（8:00-9:00）
2. **幂等性** - 检查 `heartbeat-state.json` 避免重复执行
3. **报告发送** - 必须发送到用户可见的渠道（飞书私聊等）
4. **文档同步** - 所有相关文档必须同时更新
5. **飞书插件** - 必须先安装飞书插件才能发送报告

## 相关文件

- `SOUL.md` - AI 人格和风格
- `USER.md` - 用户偏好和习惯
- `TOOLS.md` - 工具和环境配置
- `MEMORY.md` - 长期记忆和规则
- `HEARTBEAT.md` - 心跳检查任务
- `memory/heartbeat-state.json` - 反思状态记录

---

_作者：张正明 | 版本：1.0 | 更新时间：2026-03-20_
