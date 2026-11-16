# Git Rules

- Show complete, literal output of all git commands -- never summarize or paraphrase
- ALWAYS use `git -C <path>` instead of `cd <path> && git ...`. Claude Code prompts on any `cd` into a different directory followed by `git` (another directory's git hooks could run), even when both parts are otherwise allowed. Allow rules for git must be written in the `git -C <path> <subcommand> *` form to match.
  - CORRECT: `git -C /path/to/repo log --oneline`
  - WRONG: `cd /path/to/repo && git log --oneline`
- Suppress the pager on any command that produces multi-line output: use `git --no-pager <subcommand>` or prefix with `GIT_PAGER=cat`. Commands that commonly hang: `log`, `diff`, `show`, `blame`, `shortlog`
- Always bound `git log` output with `-n <count>` or `--max-count=<n>`; unbounded log in large repos produces context-filling output
- Use `git status -uno` (skip untracked file scan) in large repos or worktrees where untracked file enumeration is slow or irrelevant
- NEVER mention "Claude" or "Claude Code" in:
  - Git commit messages or comments
  - GitHub commit messages or PR descriptions
  - Exception: when explicitly discussing Claude Code features
