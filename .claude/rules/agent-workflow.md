# Agent Workflow

## Coding Projects -- Mandatory Final Steps

Every coding project todo list MUST end with:
1. Use appropriate quality control agent (e.g., `pr-review-toolkit:code-reviewer`)
2. Use `claudemd-compliance-checker` to verify compliance

This does NOT apply to system maintenance tasks (yadm, dotfiles, package installs, file reorg).

## Parallelism

Use agents to run independent tasks in parallel wherever possible. When multiple research, analysis, or execution steps don't depend on each other's results, launch them concurrently using the Agent tool in a single message rather than sequentially.

## Worktree Policy (All Branch Work)

CRITICAL: ALL branch creation MUST use worktrees — main session and subagents alike. Subagents that modify code MUST use `isolation: "worktree"`. See `~/.claude/rules/git-worktrees.md` for setup and exceptions.
