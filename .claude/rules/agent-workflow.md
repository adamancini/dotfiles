# Agent Workflow

## Coding Projects -- Mandatory Final Steps

Every coding project todo list MUST end with:
1. Use appropriate quality control agent (e.g., `pr-review-toolkit:code-reviewer`)
2. Use `claudemd-compliance-checker` to verify compliance

This does NOT apply to system maintenance tasks (yadm, dotfiles, package installs, file reorg).

## Worktree Policy (All Branch Work)

CRITICAL: ALL branch creation for development work MUST use worktrees -- this includes the main session, not just subagents. See `~/.claude/rules/git-worktrees.md` for the full rule.

- Subagents that modify code MUST use `isolation: "worktree"`
- Main session creating a feature branch MUST use a worktree
- Worktrees go in `<repo-root>/.worktrees/<branch-name>`
- Add `.worktrees` to `.gitignore`
- Use `superpowers:using-git-worktrees` skill for setup
- NOT needed for: commits on current branch, read-only agents, system maintenance
