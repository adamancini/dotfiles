# Agent Workflow

## Coding Projects -- Mandatory Final Steps

Every coding project todo list MUST end with:
1. Use appropriate quality control agent (e.g., `pr-review-toolkit:code-reviewer`)
2. Use `claudemd-compliance-checker` to verify compliance

This does NOT apply to system maintenance tasks (yadm, dotfiles, package installs, file reorg).

## Subagent Worktree Policy

IMPORTANT: Subagents that modify code MUST use `isolation: "worktree"`.

- Worktrees go in `<repo-root>/.worktrees/<branch-name>`
- Add `.worktrees` to `.gitignore`
- Use `superpowers:using-git-worktrees` skill for setup
- NOT needed for: read-only agents, search/grep only, system maintenance, single-file edits
