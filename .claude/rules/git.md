# Git Rules

- Show complete, literal output of all git commands -- never summarize or paraphrase
- ALWAYS use `git -C <path>` instead of `cd <path> && git ...`. The `Bash(git:*)` permission uses prefix matching — compound commands starting with `cd` won't match and require manual approval every time.
  - CORRECT: `git -C /path/to/repo log --oneline`
  - WRONG: `cd /path/to/repo && git log --oneline`
- Suppress the pager on any command that produces multi-line output: use `git --no-pager <subcommand>` or prefix with `GIT_PAGER=cat`. Commands that commonly hang: `log`, `diff`, `show`, `blame`, `shortlog`
- Always bound `git log` output with `-n <count>` or `--max-count=<n>`; unbounded log in large repos produces context-filling output
- Use `git status -uno` (skip untracked file scan) in large repos or worktrees where untracked file enumeration is slow or irrelevant
- NEVER mention "Claude" or "Claude Code" in:
  - Git commit messages or comments
  - GitHub commit messages or PR descriptions
  - Exception: when explicitly discussing Claude Code features
