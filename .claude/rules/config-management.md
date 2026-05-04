# Configuration & yadm Management

## yadm Usage

NEVER use `yadm status -u` or `yadm status -uall` -- it enumerates the entire home directory. Always use `yadm status` without the `-u` flag.

## yadm Templates

Template files use a `##os.Darwin` suffix for macOS-specific configs. `yadm alt` creates symlinks automatically (e.g., `.gitconfig.local##os.Darwin` → `.gitconfig.local`). Config directory: `~/.config/yadm/`.

## yadm Tracking

**Track (commit to yadm):** README.md, plugins/config.json, custom agents/skills/hooks. (Hookify rules at user scope do NOT fire — hookify globs relative to CWD; use settings.json hooks for global enforcement.)

**Never track:** settings.json, settings.local.json, plugins/cache/, plugins/marketplaces/, file-history/, projects/, debug/, plugins/installed_plugins.json, plugins/known_marketplaces.json.

## settings.json

All Claude settings live in `~/.claude/settings.json` (untracked). NEVER use `settings.local.json` at any scope:
- At project scope it shadows (fully replaces) the user-level `settings.json`, breaking `permissions.allow`, `enabledPlugins`, and hooks across all subdirectories
- At user scope it creates split state that is hard to reason about and violates the flat-config convention

Use `settings.json` only — at both user and project scope.

## Plugin Sync Strategy

Do NOT track plugin state in yadm. Previous attempts caused constant merge conflicts from cache churn and timestamp drift in `installed_plugins.json`.

**What to track (yadm):** `plugins/config.json`, `plugins/known_marketplaces.json`, hooks, CLAUDE.md, rules/
**What NOT to track:** `settings.json`, `settings.local.json`, `plugins/cache/`, `plugins/marketplaces/`, `plugins/installed_plugins.json`

Plugins are re-installed on new machines via the bootstrap script (`~/.config/yadm/bootstrap.d/60-claude-plugins.sh`).
Custom agents/skills live in plugin repos (e.g., `devops-toolkit`) managed as separate git repositories.

## After Plugin/Config Changes

1. Update @~/.claude/README.md
2. Sync: `yadm add <files> && yadm commit -m "description" && yadm push`

## devops-toolkit Plugin Sync

Location: @~/.claude/plugins/repos/devops-toolkit
Remote: `git@github.com:adamancini/devops-toolkit.git`

MANDATORY sync after modifying agents/skills or during updates:
```bash
git -C ~/.claude/plugins/repos/devops-toolkit fetch origin && git -C ~/.claude/plugins/repos/devops-toolkit pull --rebase origin main && git -C ~/.claude/plugins/repos/devops-toolkit push origin main
```
