#!/bin/bash
#
# Phase 65: codebase-memory-mcp wiring for Claude Code
#
# The binary comes from Homebrew (adamancini/tap/codebase-memory-mcp, pinned
# version + sha256 in the formula; listed in the Brewfile). This phase does
# only the Claude Code wiring, and deliberately does NOT run the upstream
# `codebase-memory-mcp install`, because that also edits ~/.zshrc, VS Code,
# and ~/.copilot. Instead it:
#
#   1. installs the formula if phase 50 has not already
#   2. disables the graph web UI (config ui_enabled=false)
#   3. generates the upstream agents + skill in a sandbox HOME and copies
#      only those into ~/.claude (untracked by yadm; refreshed on every run,
#      so they always match the installed binary version)
#   4. registers the MCP server at user scope as `codebase-memory-mcp`
#   5. merges hooks into ~/.claude/settings.json (untracked) with jq:
#        SessionStart, SubagentStart, PreToolUse Grep|Glob|Bash
#      (no PostToolUse Read hook, by choice)
#   6. migrates the legacy curl|bash install (~/.local/bin binary, static
#      ~/.claude/hooks/cbm-* scripts) into a backup dir
#
# The daemon that hook-augment needs runs on demand: the first MCP session
# starts it. No launchd agent.
#
# Idempotent. Safe to re-run after `brew upgrade codebase-memory-mcp`.
#
# Usage:
#   65-codebase-memory.sh            # apply
#   65-codebase-memory.sh --dry-run  # show what would change
#   65-codebase-memory.sh --check    # verify current state, exit 1 on drift
#

set -euo pipefail

RED=$(tput setaf 1 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")
info() { echo "${GREEN}[INFO]${RESET} $*"; }
warn() { echo "${YELLOW}[WARN]${RESET} $*"; }
error() { echo "${RED}[ERROR]${RESET} $*" >&2; }
success() { echo "${GREEN}[✓]${RESET} $*"; }

FORMULA="adamancini/tap/codebase-memory-mcp"
MCP_NAME="codebase-memory-mcp"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
BACKUP_DIR="$HOME/.bootstrap-backups/codebase-memory-$(date +%Y%m%d-%H%M%S)"
AGENT_GLOB="codebase-memory*.md"
SKILL_NAME="codebase-memory"

MODE="apply"
case "${1:-}" in
    --dry-run) MODE="dry-run" ;;
    --check) MODE="check" ;;
    "") ;;
    *) error "unknown option: $1"; exit 2 ;;
esac

run() {
    if [[ "$MODE" == "apply" ]]; then
        "$@"
    else
        echo "  would run: $*"
    fi
}

backup() {
    local src=$1
    [[ -e "$src" || -L "$src" ]] || return 0
    if [[ "$MODE" == "apply" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$src" "$BACKUP_DIR/"
        info "moved $src -> $BACKUP_DIR/"
    else
        echo "  would move to backup: $src"
    fi
}

require() {
    local missing=0
    for cmd in brew jq claude; do
        if ! command -v "$cmd" &>/dev/null; then
            error "$cmd not found in PATH"
            missing=1
        fi
    done
    return $missing
}

# --- 1. binary -------------------------------------------------------------

ensure_formula() {
    if brew list --formula "$FORMULA" &>/dev/null; then
        success "$FORMULA installed ($(brew list --versions "$FORMULA" | awk '{print $2}'))"
    elif [[ "$MODE" == "check" ]]; then
        error "$FORMULA not installed"
        return 1
    else
        info "installing $FORMULA"
        run brew install "$FORMULA"
    fi
}

bin_path() {
    echo "$(brew --prefix)/opt/codebase-memory-mcp/bin/codebase-memory-mcp"
}

# --- 6. legacy migration ---------------------------------------------------

migrate_legacy() {
    local legacy_bin="$HOME/.local/bin/codebase-memory-mcp"
    local drift=0
    for f in "$legacy_bin" "$legacy_bin".v*.bak \
             "$CLAUDE_DIR"/hooks/cbm-code-discovery-gate \
             "$CLAUDE_DIR"/hooks/cbm-session-reminder \
             "$CLAUDE_DIR"/hooks/cbm-subagent-reminder; do
        [[ -e "$f" ]] || continue
        if [[ "$MODE" == "check" ]]; then
            warn "legacy artifact present: $f"
            drift=1
        else
            backup "$f"
        fi
    done
    # v0.9.0 also wrote a project-scoped ~/.claude/.mcp.json (active only for
    # sessions started in ~/.claude). Retire it only if cbm is all it holds.
    local pmcp="$CLAUDE_DIR/.mcp.json"
    if [[ -f "$pmcp" ]] && [[ "$(jq -c '.mcpServers | keys' "$pmcp" 2>/dev/null)" == "[\"$MCP_NAME\"]" ]]; then
        if [[ "$MODE" == "check" ]]; then
            warn "legacy project-scoped MCP file present: $pmcp"
            drift=1
        else
            backup "$pmcp"
        fi
    fi
    return $drift
}

# --- 2. config -------------------------------------------------------------

configure() {
    local bin=$1
    local ui
    ui=$("$bin" config get ui_enabled 2>/dev/null | awk '{print $NF}')
    if [[ "$ui" == "false" ]]; then
        success "graph UI disabled"
    elif [[ "$MODE" == "check" ]]; then
        warn "graph UI enabled (ui_enabled=$ui)"
        return 1
    else
        run "$bin" config set ui_enabled false
    fi
}

# --- 3. agents + skill -----------------------------------------------------

sync_agents_and_skill() {
    local bin=$1
    local sandbox
    sandbox=$(mktemp -d)
    # shellcheck disable=SC2064
    trap "rm -rf '$sandbox'" RETURN

    mkdir -p "$sandbox/.claude"
    echo '{}' >"$sandbox/.claude/settings.json"
    echo '{}' >"$sandbox/.claude.json"
    touch "$sandbox/.zshrc"
    # Restricted PATH keeps the installer from detecting other agents
    # (VS Code etc.); HOME redirect keeps every write inside the sandbox.
    if ! HOME="$sandbox" PATH=/usr/bin:/bin "$bin" install -y >"$sandbox/install.log" 2>&1; then
        error "sandbox install failed; log:"
        cat "$sandbox/install.log" >&2
        return 1
    fi

    local drift=0 changed=0
    mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills"
    for src in "$sandbox"/.claude/agents/$AGENT_GLOB; do
        [[ -f "$src" ]] || continue
        local dst
        dst="$CLAUDE_DIR/agents/$(basename "$src")"
        if cmp -s "$src" "$dst"; then
            continue
        elif [[ "$MODE" == "check" ]]; then
            warn "agent out of date: $dst"
            drift=1
        else
            run cp "$src" "$dst"
            changed=1
        fi
    done
    local skill_src="$sandbox/.claude/skills/$SKILL_NAME"
    local skill_dst="$CLAUDE_DIR/skills/$SKILL_NAME"
    if [[ -d "$skill_src" ]]; then
        if diff -rq "$skill_src" "$skill_dst" &>/dev/null; then
            :
        elif [[ "$MODE" == "check" ]]; then
            warn "skill out of date: $skill_dst"
            drift=1
        else
            run rm -rf "$skill_dst"
            run cp -R "$skill_src" "$skill_dst"
            changed=1
        fi
    fi
    [[ $drift -eq 0 && $changed -eq 0 ]] && success "agents + skill match $("$bin" --version | awk '{print $2}')"
    return $drift
}

# Keep generated files out of yadm even if someone runs `yadm add ~/.claude/agents`.
yadm_exclude() {
    command -v yadm &>/dev/null || return 0
    local repo exclude
    repo=$(yadm introspect repo 2>/dev/null) || return 0
    exclude="$repo/info/exclude"
    for pat in ".claude/agents/$AGENT_GLOB" ".claude/skills/$SKILL_NAME/"; do
        grep -qxF "$pat" "$exclude" 2>/dev/null && continue
        if [[ "$MODE" == "apply" ]]; then
            mkdir -p "$(dirname "$exclude")"
            echo "$pat" >>"$exclude"
            info "yadm exclude: $pat"
        elif [[ "$MODE" == "dry-run" ]]; then
            echo "  would add yadm exclude: $pat"
        fi
    done
}

# --- 4. MCP registration ---------------------------------------------------

register_mcp() {
    local bin=$1
    local current
    current=$(jq -r --arg n "$MCP_NAME" '.mcpServers[$n].command // empty' "$HOME/.claude.json" 2>/dev/null || true)
    if [[ "$current" == "$bin" ]]; then
        success "MCP server $MCP_NAME -> $bin"
        return 0
    fi
    if [[ "$MODE" == "check" ]]; then
        warn "MCP server $MCP_NAME points to '${current:-<unset>}', want $bin"
        return 1
    fi
    [[ -n "$current" ]] && run claude mcp remove -s user "$MCP_NAME"
    run claude mcp add -s user "$MCP_NAME" -- "$bin"
}

# --- 5. hooks --------------------------------------------------------------

# Desired hook block. Every entry calls the stable opt/ path, so
# `brew upgrade` needs no settings change.
desired_hooks() {
    local cmd="'$1' hook-augment"
    jq -n --arg cmd "$cmd" '
      def h($m): {matcher: $m, hooks: [{type: "command", command: $cmd, timeout: 5}]};
      {
        SessionStart:  [h("startup|resume|clear|compact")],
        SubagentStart: [h("*")],
        PreToolUse:    [h("Grep|Glob|Bash")]
      }'
}

merge_hooks() {
    local bin=$1
    local want
    want=$(desired_hooks "$bin")

    [[ -f "$SETTINGS" ]] || echo '{}' >"$SETTINGS"

    # Drop every existing cbm hook (old static scripts, upstream installer
    # entries, previous runs of this script), prune empty groups/events,
    # then append the desired set.
    local merged
    merged=$(jq --argjson want "$want" '
      def is_cbm: (.command // "") | test("codebase-memory-mcp|/cbm-");
      .hooks = (
        ((.hooks // {})
          | with_entries(
              .value |= (map(.hooks |= map(select(is_cbm | not)))
                         | map(select((.hooks | length) > 0)))
            )
          | with_entries(select((.value | length) > 0))
        ) as $clean
        | reduce ($want | to_entries[]) as $e ($clean;
            .[$e.key] = ((.[$e.key] // []) + $e.value))
      )' "$SETTINGS")

    if [[ "$(jq -S . "$SETTINGS")" == "$(jq -S . <<<"$merged")" ]]; then
        success "settings.json hooks up to date"
        return 0
    fi
    case "$MODE" in
        check)
            warn "settings.json hooks drift:"
            diff <(jq -S .hooks "$SETTINGS") <(jq -S .hooks <<<"$merged") || true
            return 1 ;;
        dry-run)
            echo "  would change settings.json hooks:"
            diff <(jq -S .hooks "$SETTINGS") <(jq -S .hooks <<<"$merged") | sed 's/^/    /' || true ;;
        apply)
            mkdir -p "$BACKUP_DIR"
            cp -p "$SETTINGS" "$BACKUP_DIR/settings.json"
            local tmp
            tmp=$(mktemp "$SETTINGS.XXXXXX")
            jq . <<<"$merged" >"$tmp" && mv "$tmp" "$SETTINGS"
            success "settings.json hooks merged (backup: $BACKUP_DIR/settings.json)" ;;
    esac
}

main() {
    info "Phase 65: codebase-memory-mcp ($MODE)"
    require

    local rc=0
    ensure_formula || rc=1
    if [[ "$MODE" == "dry-run" ]] && ! brew list --formula "$FORMULA" &>/dev/null; then
        warn "formula not installed yet; skipping steps that need the binary"
        return 0
    fi
    local bin
    bin=$(bin_path)
    [[ -x "$bin" ]] || { error "binary not found at $bin"; return 1; }

    migrate_legacy || rc=1
    configure "$bin" || rc=1
    sync_agents_and_skill "$bin" || rc=1
    yadm_exclude
    register_mcp "$bin" || rc=1
    merge_hooks "$bin" || rc=1

    if [[ "$MODE" == "apply" ]]; then
        info "restart Claude Code sessions to pick up MCP and hook changes"
    fi
    return $rc
}

main
