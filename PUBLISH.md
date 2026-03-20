# 发布指南

## 发布到 ClawHub

### 1. 准备仓库

```bash
cd /home/zzm/.openclaw/workspace/skills/daily-reflection

# 初始化 git 仓库
git init
git add .
git commit -m "Initial release: daily-reflection skill v1.0"

# 创建 GitHub 仓库
gh repo create openclaw-daily-reflection --public --source=. --remote=origin --push
```

### 2. 发布到 ClawHub

```bash
# 使用 clawhub CLI 发布
cd /home/zzm/.openclaw/workspace/skills/daily-reflection
clawhub publish
```

### 3. 验证发布

```bash
# 搜索技能
clawhub search daily-reflection

# 安装测试
clawhub install daily-reflection
```

## 发布到 GitHub

### 仓库信息

- **仓库名**: `openclaw-daily-reflection`
- **描述**: 每日反思机制 - 自动分析对话历史，更新 AI 记忆文档
- **标签**: `openclaw`, `skill`, `automation`, `reflection`, `ai-memory`

### README 模板

仓库根目录创建 `README.md`：

```markdown
# OpenClaw Daily Reflection Skill

自动分析过去 24 小时对话，更新 AI 记忆文档（SOUL.md、USER.md、TOOLS.md 等）。

## 安装

### 1. 安装飞书插件（必需）

```bash
npx -y @larksuite/openclaw-lark-tools install
```

### 2. 安装 Skill

```bash
clawhub install daily-reflection
```

## 功能

- 📅 每日自动反思（8:00-9:00）
- 🧠 分析对话历史，提取核心内容
- 📝 自动更新所有相关文档
- 📊 生成反思报告并发送

## 使用

详见 [SKILL.md](SKILL.md)

## 作者

张正明

## 许可证

MIT
```

## 社区推广

### 1. Discord 安利贴

发到 `discord.gg/clawd` 的 #skills 频道：

```
📅 新 Skill 发布：每日反思机制

自动分析过去 24 小时对话，更新 AI 记忆文档（SOUL.md、USER.md、TOOLS.md 等）。

✨ 功能：
- 每天 8:00 自动执行
- AI 分析对话历史
- 自动更新所有文档
- 生成反思报告

🔗 GitHub: https://github.com/your-username/openclaw-daily-reflection
📦 ClawHub: clawhub install daily-reflection

欢迎试用和反馈！
```

### 2. 微信群/朋友圈

```
【OpenClaw Skill 发布】

做了一个「每日反思」Skill，让 AI 每天自动复盘过去 24 小时的对话：
- 用户纠正了什么 → 更新 SOUL.md
- 新增工具/脚本 → 更新 TOOLS.md
- 新的用户偏好 → 更新 USER.md
- 值得记住的事 → 更新 MEMORY.md

类似人类的「每日复盘」，帮助 AI 持续进化。

GitHub: https://github.com/your-username/openclaw-daily-reflection
```

## 版本更新

### v1.1（计划）

- [ ] 支持自定义反思时间
- [ ] 支持多个用户配置
- [ ] 增加反思模板自定义
- [ ] 支持导出反思历史

### 更新流程

```bash
# 修改 SKILL.md 中的版本号
# 更新 CHANGELOG.md
git add .
git commit -m "Release v1.1: 新增自定义反思时间"
git tag v1.1
git push --tags
clawhub publish
```
