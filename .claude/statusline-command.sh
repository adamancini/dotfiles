#!/bin/bash
#
# Claude Code Statusline Script
# Displays: cwd, git branch + worktree info, session tag, system info

set -euo pipefail

# Shorten a path fish-style: abbreviate intermediate components to first character.
# Only applied when the full path exceeds the threshold (default 35 chars).
# Usage: shorten_path <path> [threshold]
shorten_path() {
    local path="$1"
    local threshold="${2:-35}"

    # Nothing to do if the path is already short enough.
    if (( ${#path} <= threshold )); then
        echo "$path"
        return
    fi

    # Split on "/" into an array.
    local IFS='/'
    read -ra parts <<< "$path"

    # parts[0] is either "" (absolute path, leading /) or "~" (home-relative).
    # We need at least 3 elements (anchor + one intermediate + last) to abbreviate.
    local n=${#parts[@]}
    if (( n <= 2 )); then
        echo "$path"
        return
    fi

    local result=""
    local i
    for (( i = 0; i < n; i++ )); do
        local seg="${parts[$i]}"
        if (( i == 0 )); then
            # Leading anchor: empty string (for "/foo") or "~"
            result="$seg"
        elif (( i == n - 1 )); then
            # Always keep the last component full.
            result="${result}/${seg}"
        else
            # Intermediate: abbreviate to first character (skip empty segments).
            if [[ -n "$seg" ]]; then
                result="${result}/${seg:0:1}"
            fi
        fi
    done

    echo "$result"
}

# Get current working directory (abbreviated for home)
CWD="${PWD/#$HOME/~}"
CWD=$(shorten_path "$CWD" 35)

# --- Git Information ---
GIT_INFO=""
WORKTREE_INFO=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null \
        || git rev-parse --short HEAD 2>/dev/null \
        || echo "detached")

    # Detect if this session is inside a worktree.
    # When in a worktree, git-dir path contains /worktrees/ rather than ending in .git
    GIT_DIR=$(git rev-parse --git-dir 2>/dev/null || echo "")
    WORKTREE_PREFIX=""
    if [[ "$GIT_DIR" == *"/worktrees/"* ]] || [[ "$PWD" == *"/.worktrees/"* ]]; then
        WORKTREE_PREFIX="⑂"
    fi

    # Uncommitted changes
    STATUS=""
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        STATUS="*"
    fi
    if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
        STATUS="${STATUS}+"
    fi

    # Ahead/behind remote
    UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")
    if [ -n "$UPSTREAM" ]; then
        AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
        BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
        if [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -gt 0 ]; then
            STATUS="${STATUS}⇅"
        elif [ "$AHEAD" -gt 0 ]; then
            STATUS="${STATUS}↑"
        elif [ "$BEHIND" -gt 0 ]; then
            STATUS="${STATUS}↓"
        fi
    fi

    # Read active worktree recorded by the PreToolUse hook.
    # Session key: grandparent PID = the Claude process (stable, unique per session).
    SESSION_PID=$(ps -o ppid= -p $PPID 2>/dev/null | tr -d ' ')
    ACTIVE_WT=""
    if [ -n "$SESSION_PID" ]; then
        ACTIVE_WT_FILE="/tmp/.claude-session-${SESSION_PID}.worktree"
        if [ -f "$ACTIVE_WT_FILE" ] && kill -0 "$SESSION_PID" 2>/dev/null; then
            ACTIVE_WT=$(tr -d '\n' < "$ACTIVE_WT_FILE" 2>/dev/null)
        fi
    fi

    # Show main→feat/auth when at repo root but actively working in a worktree.
    # If already inside the worktree dir (ACTIVE_WT == BRANCH), ⑂ prefix suffices.
    if [ -n "$ACTIVE_WT" ] && [ "$ACTIVE_WT" != "$BRANCH" ]; then
        GIT_INFO=" | ${WORKTREE_PREFIX}${BRANCH}→${ACTIVE_WT}${STATUS}"
    else
        GIT_INFO=" | ${WORKTREE_PREFIX}${BRANCH}${STATUS}"
    fi

    # Count active worktrees OTHER than the current one.
    # Works whether the session is at the repo root (shows all worktrees) or
    # inside a specific worktree (shows the others).
    CURRENT_WT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
    WT_COUNT=$(git worktree list 2>/dev/null \
        | awk -v cur="$CURRENT_WT" '$1 != cur { print $3 }' \
        | tr -d '[]' \
        | grep -v '^$' \
        | grep -v '^(bare)$' \
        | wc -l \
        | tr -d ' ' \
        || echo "0")
    if [ "${WT_COUNT}" -gt 0 ] 2>/dev/null; then
        WORKTREE_INFO=" | wt:${WT_COUNT}"
    fi
fi

# --- Session Tag ---
# $PPID is the parent process of this script (the shell Claude invoked).
# It is unique per concurrent Claude session and stable within a session.
# Displayed as a 3-hex-digit code for brevity.
SESSION_TAG=$(printf '#%03x' $((PPID % 4096)))

# --- System Information ---
HOSTNAME=$(hostname -s)
LOAD=$(uptime | sed 's/.*load average: //' | awk '{print $1}' | sed 's/,$//')

# --- Build Statusline ---
LEFT_PART="[${CWD}]${GIT_INFO}${WORKTREE_INFO}"
RIGHT_PART="${HOSTNAME} [${LOAD}] ${SESSION_TAG}"

TERM_WIDTH=$(tput cols 2>/dev/null || echo "80")
LEFT_LEN=$(echo -n "$LEFT_PART" | sed 's/\x1b\[[0-9;]*m//g' | wc -c | tr -d ' ')
RIGHT_LEN=$(echo -n "$RIGHT_PART" | sed 's/\x1b\[[0-9;]*m//g' | wc -c | tr -d ' ')
PADDING=$((TERM_WIDTH - LEFT_LEN - RIGHT_LEN))
if [ $PADDING -lt 1 ]; then
    PADDING=1
fi

echo "${LEFT_PART}$(printf '%*s' $PADDING '')${RIGHT_PART}"
