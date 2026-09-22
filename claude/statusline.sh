#!/bin/bash
# Read JSON data that Claude Code sends to stdin
input=$(cat)

# Tee the rate limits for claude-inbox. Skip when absent (first run of a session) so a good file is never blanked.
limits=$(echo "$input" | jq -c '.rate_limits // empty')
[ -n "$limits" ] && echo "$limits" > ~/.claude/rate_limits.json.tmp && mv ~/.claude/rate_limits.json.tmp ~/.claude/rate_limits.json

# --- Extract fields ---
MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
# "// empty" produces no output when rate_limits is absent (non-Pro/Max or pre-first-response)
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# --- Colors ---
CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; DIM='\033[2m'; RESET='\033[0m'

# --- Context: color-coded progress bar (green <70%, yellow 70-89%, red 90%+) ---
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"
CONTEXT="${BAR_COLOR}${BAR}${RESET} ${PCT}%"

# --- Git branch ---
BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"

# --- Rate limits (only when present) ---
LIMITS=""
[ -n "$FIVE_H" ] && LIMITS="5h: $(printf '%.0f' "$FIVE_H")%"
[ -n "$WEEK" ] && LIMITS="${LIMITS:+$LIMITS }7d: $(printf '%.0f' "$WEEK")%"
[ -n "$LIMITS" ] && LIMITS=" | ${DIM}⚡ ${LIMITS}${RESET}"

# --- One line: context, model, folder, branch, limits ---
echo -e "${CONTEXT} | ${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}${BRANCH}${LIMITS}"
