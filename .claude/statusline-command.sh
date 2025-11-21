#!/bin/bash
#
# Claude Code Statusline Script
# Displays: working directory, git status, system info

set -euo pipefail

# Color codes for formatting (optional, statusline may support these)
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BLUE='\033[34m'

# Get current working directory (abbreviated for home)
CWD="${PWD/#$HOME/~}"

# Git information
GIT_INFO=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "unknown")

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        STATUS="*"  # Modified files
    else
        STATUS=""
    fi

    # Check for untracked files
    if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
        STATUS="${STATUS}+"
    fi

    # Check if ahead/behind remote
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

    GIT_INFO=" | git:${BRANCH}${STATUS}"
fi

# Kubernetes context (if kubectl is available and configured)
K8S_INFO=""
if command -v kubectl &>/dev/null && kubectl config current-context &>/dev/null; then
    K8S_CTX=$(kubectl config current-context 2>/dev/null | cut -c1-20)
    K8S_INFO=" | k8s:${K8S_CTX}"
fi

# System information
HOSTNAME=$(hostname -s)
LOAD=$(uptime | sed 's/.*load average: //' | awk '{print $1}' | sed 's/,$//')
SYSTEM_INFO="${HOSTNAME} [${LOAD}]"

# Build left and right parts
LEFT_PART="[${CWD}]${GIT_INFO}${K8S_INFO}"
RIGHT_PART="${SYSTEM_INFO}"

# Get terminal width (default to 80 if unable to determine)
TERM_WIDTH=$(tput cols 2>/dev/null || echo "80")

# Calculate visible length (removing ANSI codes if present)
LEFT_LEN=$(echo -n "$LEFT_PART" | sed 's/\x1b\[[0-9;]*m//g' | wc -c | tr -d ' ')
RIGHT_LEN=$(echo -n "$RIGHT_PART" | sed 's/\x1b\[[0-9;]*m//g' | wc -c | tr -d ' ')

# Calculate padding needed
PADDING=$((TERM_WIDTH - LEFT_LEN - RIGHT_LEN))

# Ensure minimum padding of 1 space
if [ $PADDING -lt 1 ]; then
    PADDING=1
fi

# Create padding string
PAD_STR=$(printf '%*s' $PADDING '')

# Build the statusline with right-justified system info
echo "${LEFT_PART}${PAD_STR}${RIGHT_PART}"
