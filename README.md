# 飞书每日反思 Skill

**【飞书专属】** 自动分析过去 24 小时对话，更新 AI 记忆文档，通过飞书发送反思报告。

## 适用范围

⚠️ **仅适用于飞书渠道** - 本 Skill 依赖飞书插件，只能在 OpenClaw 飞书渠道中使用。

## 安装

### 1. 安装飞书插件（必需）

```bash
npx -y @larksuite/openclaw-lark-tools install
```

### 2. 安装 Skill

```bash
# 方法 1: 从 clawhub 安装（发布后）
clawhub install daily-reflection

# 方法 2: 手动安装
git clone https://github.com/xiaoyekanren/openclaw-daily-reflection.git
cp -r openclaw-daily-reflection ~/.openclaw/skills/
```

## 快速开始

### 1. 配置定时任务

在 crontab 中添加（每天 8:00 执行）：

```bash
0 8 * * * cd /home/zzm/.openclaw/workspace && /home/zzm/.openclaw/skills/daily-reflection/reflect.sh
```

### 2. 集成到 HEARTBEAT.md

在心跳检查文件中添加：

```markdown
## 0. 每日反思（每天 8:00-9:00 执行一次）

**检查条件**：
- 当前时间在 8:00-9:00 之间
- 昨天记忆文件未更新

**执行动作**：
1. 获取过去 24 小时对话历史
2. AI 分析并提取核心内容
3. 更新对应文档
4. 记录反思时间
5. 发送反思报告
```

### 3. 配置用户 ID

编辑 `reflect.sh`，替换为目标用户的 open_id：

```bash
TARGET_USER="ou_xxx"  # 替换为你的飞书用户 ID
```

## 文件结构

```
daily-reflection/
├── SKILL.md          # Skill 描述（必需）
├── README.md         # 使用说明
├── reflect.sh        # 反思脚本
└── examples/
    └── report.md     # 报告格式示例
```

## 反思范围

| 问题 | 更新文档 |
|------|---------|
| 用户纠正过我什么？ | SOUL.md |
| 有没有新增工具/脚本？ | TOOLS.md |
| 有没有重复工作可以自动化？ | HEARTBEAT.md |
| 用户表达了什么新偏好？ | USER.md |
| 有什么值得长期记住的？ | MEMORY.md |

## 报告格式

```markdown
## 📅 每日反思报告 (2026-03-20)

**反思时间范围**: 昨天 8:00 → 今天 8:00

### 更新的文档
| 文档 | 更新内容 |
|------|---------|
| SOUL.md | 用户偏好简洁回复 |
| TOOLS.md | 新增定时任务框架 |
| USER.md | 新增文档同步要求 |
| MEMORY.md | 记录框架 v2.0 架构 |

### 核心摘要
- 定时任务框架 v2.0 重构完成
- 修复 3 个 bug
- 晨间简报正常运行
```

## 手动触发

```bash
# 立即执行反思
./reflect.sh --manual

# 指定日期范围
./reflect.sh --start 2026-03-19 --end 2026-03-20
```

## 依赖

- bash
- jq（JSON 处理）
- OpenClaw CLI

## 故障排除

### 反思未执行

检查 `memory/heartbeat-state.json`：

```bash
cat memory/heartbeat-state.json
```

如果 `lastDailyReflection` 是今天，说明已执行过。

### 报告未发送

检查日志：

```bash
tail -f /home/zzm/.openclaw/cron/logs/daily-reflection.log
```

### 文档未更新

确保 AI 有写入权限：

```bash
ls -la ~/.openclaw/workspace/*.md
```

## 贡献

欢迎提交 Issue 和 PR！

## 许可证

MIT

---

_作者：张正明 | 版本：1.0 | 更新时间：2026-03-20_
