# Git Worktrees: Mandatory for All Branch Work

## Rule

CRITICAL: ALL git branch creation for development work MUST use worktrees. NEVER create a branch and switch to it in the project root. This applies to:

- The main Claude session creating a feature branch
- Subagents doing implementation work
- Any code modification that involves a new branch

The ONLY exception is when the user explicitly says to work directly on the current branch (e.g., "just commit to main" or "work on this branch directly").

## Why

Working directly in the project root prevents parallel Claude sessions from running successfully. Worktrees provide isolation so multiple sessions can work on different features simultaneously.

## How

1. Use `superpowers:using-git-worktrees` skill for setup
2. Worktrees go in `<repo-root>/.worktrees/<branch-name>`
3. Ensure `.worktrees` is in `.gitignore` (fix immediately if not)
4. If the project has Taskfile worktree tasks (e.g., `dev:worktree:create`), prefer those

## Quick Reference

```bash
# Create worktree for a new feature branch
git worktree add .worktrees/feature-name -b feature/feature-name

# List worktrees
git worktree list

# Remove when done
git worktree remove .worktrees/feature-name
```

## Does NOT Apply To

- Commits on the current branch (no branch creation = no worktree needed)
- Read-only operations (viewing, searching, reviewing)
- System maintenance (yadm, dotfiles, package management)
- When user explicitly requests direct branch work
