#!/bin/bash

# 每日反思脚本 v1.0
# 自动分析过去 24 小时对话，更新 AI 记忆文档

set -e

# 配置
WORKSPACE="/home/zzm/.openclaw/workspace"
MEMORY_DIR="${WORKSPACE}/memory"
STATE_FILE="${MEMORY_DIR}/heartbeat-state.json"
LOG_FILE="${WORKSPACE}/logs/daily-reflection.log"
TARGET_USER="ou_476c7862905aec59a12d19ebd8c7f6af"  # 替换为你的用户 ID

# 创建日志目录
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 检查是否已执行过今日反思
check_already_run() {
    if [[ -f "$STATE_FILE" ]]; then
        LAST_REFLECTION=$(jq -r '.lastDailyReflection // empty' "$STATE_FILE" 2>/dev/null)
        if [[ -n "$LAST_REFLECTION" ]]; then
            LAST_DATE=$(echo "$LAST_REFLECTION" | cut -d'T' -f1)
            TODAY=$(date +%Y-%m-%d)
            if [[ "$LAST_DATE" == "$TODAY" ]]; then
                log "今日反思已执行：$LAST_REFLECTION"
                exit 0
            fi
        fi
    fi
}

# 检查时间窗口（8:00-9:00）
check_time_window() {
    HOUR=$(date +%H)
    if [[ "$HOUR" -lt 8 || "$HOUR" -ge 9 ]]; then
        log "不在反思时间窗口（8:00-9:00），当前时间：$(date +%H:%M)"
        exit 0
    fi
}

# 获取过去 24 小时对话历史
get_conversation_history() {
    log "获取过去 24 小时对话历史..."
    # 这里需要根据实际 API 实现
    # 示例：使用 OpenClaw sessions_history 工具
    HISTORY_FILE="/tmp/reflection-history-$(date +%Y%m%d).md"
    
    # TODO: 实现对话历史获取逻辑
    # 可以通过 OpenClaw API 或会话历史工具获取
    
    echo "$HISTORY_FILE"
}

# AI 分析对话历史
analyze_history() {
    local history_file="$1"
    log "分析对话历史..."
    
    # 使用 AI 分析对话，提取核心内容
    # 返回需要更新的文档内容
    
    # TODO: 实现 AI 分析逻辑
    # 可以调用本地 AI 服务或 OpenAI API
    
    log "分析完成"
}

# 更新文档
update_documents() {
    log "更新文档..."
    
    # 根据分析结果更新文档
    # SOUL.md, USER.md, TOOLS.md, MEMORY.md, HEARTBEAT.md
    
    # TODO: 实现文档更新逻辑
    
    log "文档更新完成"
}

# 更新状态文件
update_state() {
    local reflection_time=$(date -Iseconds)
    
    # 读取现有状态
    if [[ -f "$STATE_FILE" ]]; then
        # 保留其他字段，只更新 lastDailyReflection
        jq --arg time "$reflection_time" '.lastDailyReflection = $time' "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"
    else
        # 创建新文件
        cat > "$STATE_FILE" << EOF
{
  "lastDailyReflection": "${reflection_time}",
  "lastChecks": {
    "email": null,
    "calendar": null,
    "weather": null
  }
}
EOF
    fi
    
    log "状态已更新：$reflection_time"
}

# 发送反思报告
send_report() {
    log "发送反思报告..."
    
    local report_date=$(date +%Y-%m-%d)
    local report_time_range="昨天 8:00 → 今天 8:00"
    
    # TODO: 从分析结果生成报告
    
    local report="## 📅 每日反思报告 (${report_date})

**反思时间范围**: ${report_time_range}

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
- ..."

    # 发送到飞书私聊
    openclaw message send \
        --channel feishu \
        --target "$TARGET_USER" \
        --message "$report"
    
    log "报告已发送"
}

# 主函数
main() {
    log "========== 每日反思开始 =========="
    
    # 检查是否已执行
    check_already_run
    
    # 检查时间窗口（手动执行时跳过）
    if [[ "$1" != "--manual" ]]; then
        check_time_window
    fi
    
    # 获取对话历史
    HISTORY_FILE=$(get_conversation_history)
    
    # AI 分析
    analyze_history "$HISTORY_FILE"
    
    # 更新文档
    update_documents
    
    # 更新状态
    update_state
    
    # 发送报告
    send_report
    
    # 清理临时文件
    rm -f "$HISTORY_FILE"
    
    log "========== 每日反思完成 =========="
}

# 执行
main "$@"
