# Git Worktrees: Mandatory for All Branch Work

CRITICAL: ALL git branch creation for development work MUST use worktrees. NEVER create a branch and switch to it in the project root. Applies to the main session and subagents alike.

**Exception:** user explicitly says to work directly on the current branch ("just commit to main", "work on this branch directly").

**Not required for:** commits on the current branch, read-only operations, system maintenance (yadm, dotfiles, package management).

## Setup

```bash
git worktree add .worktrees/feature-name -b feature/feature-name
git worktree list
git worktree remove .worktrees/feature-name
```

- Worktrees go in `<repo-root>/.worktrees/<branch-name>`
- Ensure `.worktrees` is in `.gitignore` (fix immediately if not)
- Use `superpowers:using-git-worktrees` skill for setup
- If the project has Taskfile worktree tasks (e.g., `dev:worktree:create`), prefer those

## Why

Working directly in the project root prevents parallel Claude sessions from running successfully. Worktrees provide isolation so multiple sessions can work on different features simultaneously.
