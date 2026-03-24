#!/bin/bash

# 飞书每日反思脚本 v2.2 - 支持 AI 服务降级
# 自动分析过去 24 小时对话，更新 AI 记忆文档

# 可通过环境变量覆盖的配置
WORKSPACE="${WORKSPACE:-/home/zzm/.openclaw/workspace}"
MEMORY_DIR="${MEMORY_DIR:-${WORKSPACE}/memory}"
STATE_FILE="${STATE_FILE:-${MEMORY_DIR}/heartbeat-state.json}"
LOG_FILE="${LOG_FILE:-${WORKSPACE}/logs/daily-reflection.log}"
TARGET_USER="${TARGET_USER:-ou_476c7862905aec59a12d19ebd8c7f6af}"
AI_API="${AI_API:-http://192.168.99.17:8001/v1/chat/completions}"
SESSION_DIR="${SESSION_DIR:-/home/zzm/.openclaw/agents/main/sessions}"

mkdir -p "$(dirname "$LOG_FILE")" "$MEMORY_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
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

# 检查时间窗口
check_time_window() {
    HOUR=$(date +%H)
    if [[ "$HOUR" -lt 8 || "$HOUR" -ge 9 ]]; then
        log "不在反思时间窗口（8:00-9:00）"
        exit 0
    fi
}

# 获取会话历史
get_history() {
    local history_file="/tmp/reflection-history-$(date +%Y%m%d).txt"
    local session_dir="${SESSION_DIR}"
    local cutoff_time=$(($(date +%s) - 86400))
    
    > "$history_file"
    
    for session_file in "$session_dir"/*.jsonl; do
        [[ -f "$session_file" ]] || continue
        local file_mtime=$(stat -c %Y "$session_file" 2>/dev/null || echo "0")
        if [[ "$file_mtime" -gt "$cutoff_time" ]]; then
            grep -E '"role":"user"' "$session_file" 2>/dev/null | tail -50 | \
                jq -r '.message.content[0].text // empty' 2>/dev/null >> "$history_file"
        fi
    done
    
    local line_count=$(wc -l < "$history_file")
    log "会话历史：$history_file ($line_count 行)"
    printf '%s' "$history_file"
}

# AI 分析（支持降级）
analyze() {
    local history_file="$1"
    log "AI 分析中..."
    
    local content
    content=$(cat "$history_file" | head -c 8000)
    local line_count=$(wc -l < "$history_file")
    
    # 尝试调用 AI 服务（5 秒超时）
    local analysis
    analysis=$(curl -s --connect-timeout 5 -X POST "$AI_API" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"unsloth/Qwen3.5-27B-GGUF\",
            \"messages\": [
                {\"role\": \"system\", \"content\": \"分析对话，返回 JSON：{summary, soul, tools, user, memory}\"},
                {\"role\": \"user\", \"content\": \"$content\"}
            ],
            \"max_tokens\": 800
        }" 2>/dev/null | jq -r '.choices[0].message.content // "{}"' 2>/dev/null)
    
    # AI 服务失败时使用基础摘要
    if [[ -z "$analysis" || "$analysis" == "null" || "$analysis" == "{}" ]]; then
        log "AI 服务不可用，使用基础摘要"
        analysis="{\"summary\":\"过去 24 小时共 $line_count 行对话\",\"soul\":\"\",\"tools\":\"\",\"user\":\"\",\"memory\":\"对话记录已保存\"}"
    else
        log "AI 分析成功"
    fi
    
    echo "$analysis"
}

# 更新文档
update_doc() {
    local doc="$1"
    local content="$2"
    local doc_path="${WORKSPACE}/${doc}"
    
    if [[ -n "$content" && "$content" != "null" && "$content" != "" && "$content" != "{}" ]]; then
        local update_line="- $(date '+%Y-%m-%d %H:%M'): $content"
        
        if [[ -f "$doc_path" ]]; then
            echo -e "\n---\n## 最近更新\n$update_line" >> "$doc_path"
        else
            echo "# $doc\n\n## 最近更新\n$update_line" > "$doc_path"
        fi
        
        log "已更新 $doc"
        echo "- **$doc**: $content"
    fi
}

# 发送报告
send_report() {
    local report="$1"
    log "发送报告..."
    
    openclaw message send \
        --channel feishu \
        --target "$TARGET_USER" \
        --message "$report" 2>&1 | tee -a "$LOG_FILE"
    
    log "报告已发送"
}

# 更新状态
update_state() {
    local reflection_time=$(date -Iseconds)
    
    if [[ -f "$STATE_FILE" ]]; then
        jq --arg time "$reflection_time" '.lastDailyReflection = $time' "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"
    else
        echo "{\"lastDailyReflection\":\"$reflection_time\",\"lastChecks\":{}}" > "$STATE_FILE"
    fi
}

# 主函数
main() {
    log "========== 每日反思开始 =========="
    
    check_already_run
    [[ "$1" != "--manual" ]] && check_time_window
    
    # 获取历史
    history_file=$(get_history)
    
    # AI 分析
    analysis=$(analyze "$history_file")
    log "分析结果：$analysis"
    
    # 提取更新内容
    local soul_update=$(echo "$analysis" | jq -r '.soul // empty' 2>/dev/null)
    local tools_update=$(echo "$analysis" | jq -r '.tools // empty' 2>/dev/null)
    local user_update=$(echo "$analysis" | jq -r '.user // empty' 2>/dev/null)
    local memory_update=$(echo "$analysis" | jq -r '.memory // empty' 2>/dev/null)
    local summary=$(echo "$analysis" | jq -r '.summary // "日常对话"' 2>/dev/null)
    
    # 更新文档
    local updates=""
    [[ -n "$soul_update" && "$soul_update" != "{}" ]] && updates="${updates}$(update_doc "SOUL.md" "$soul_update")\n"
    [[ -n "$tools_update" && "$tools_update" != "{}" ]] && updates="${updates}$(update_doc "TOOLS.md" "$tools_update")\n"
    [[ -n "$user_update" && "$user_update" != "{}" ]] && updates="${updates}$(update_doc "USER.md" "$user_update")\n"
    [[ -n "$memory_update" && "$memory_update" != "{}" ]] && updates="${updates}$(update_doc "MEMORY.md" "$memory_update")\n"
    
    [[ -z "$updates" ]] && updates="- 无重大更新，日常对话为主\n"
    
    # 生成报告
    local report="## 📅 每日反思报告 ($(date +%Y-%m-%d))

**反思时间范围**: 昨天 8:00 → 今天 8:00

### 核心摘要
$summary

### 更新的文档
$(echo -e "$updates")

### 下次反思
明天 8:00-9:00"

    send_report "$report"
    update_state
    
    rm -f "$history_file"
    
    log "========== 每日反思完成 =========="
}

main "$@"
