#!/bin/bash
# PreToolUse hook: tracks which worktree this Claude session is actively using.
# When a Bash command cds into a .worktrees/ path, writes the branch name to
# /tmp/.claude-session-<session-pid>.worktree so the statusline can display it.

INPUT=$(cat)

# Only act on Bash tool calls
TOOL=$(echo "$INPUT" | python3 -c \
    "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)
[ "$TOOL" != "Bash" ] && exit 0

COMMAND=$(echo "$INPUT" | python3 -c \
    "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

# Check for a cd into a .worktrees/ path
if echo "$COMMAND" | grep -qE '\.worktrees/'; then
    # Extract branch: everything after .worktrees/, stop at whitespace / ; && |
    BRANCH=$(echo "$COMMAND" \
        | grep -oE '\.worktrees/[^[:space:];|&]+' \
        | head -1 \
        | sed 's|.*\.worktrees/||; s|/$||')

    # Session key: grandparent PID = the stable Claude process PID
    SESSION_PID=$(ps -o ppid= -p $PPID 2>/dev/null | tr -d ' ')

    if [ -n "$SESSION_PID" ] && [ -n "$BRANCH" ]; then
        echo "$BRANCH" > "/tmp/.claude-session-${SESSION_PID}.worktree"
    fi
fi

exit 0
