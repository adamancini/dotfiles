# Git Rules

- Show complete, literal output of all git commands -- never summarize or paraphrase
- NEVER use `cd <path> && git ...` compound commands. Use `git -C <path> <subcommand>` instead — single command, no directory change, no compound execution
- Suppress the pager on any command that produces multi-line output: use `git --no-pager <subcommand>` or prefix with `GIT_PAGER=cat`. Commands that commonly hang: `log`, `diff`, `show`, `blame`, `shortlog`
- Prevent credential prompts from hanging: prefix remote operations with `GIT_TERMINAL_PROMPT=0`
- Always bound `git log` output with `-n <count>` or `--max-count=<n>`; unbounded log in large repos produces context-filling output
- Use `git status -uno` (skip untracked file scan) in large repos or worktrees where untracked file enumeration is slow or irrelevant
- NEVER mention "Claude" or "Claude Code" in:
  - Git commit messages or comments
  - GitHub commit messages or PR descriptions
  - Exception: when explicitly discussing Claude Code features
