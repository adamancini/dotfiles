# Configuration & yadm Management

## yadm Usage

NEVER use `yadm status -u` or `yadm status -uall` -- it enumerates the entire home directory. Always use `yadm status` without the `-u` flag.

## yadm Templates

Template files use a `##os.Darwin` suffix for macOS-specific configs. `yadm alt` creates symlinks automatically (e.g., `.gitconfig.local##os.Darwin` → `.gitconfig.local`). Config directory: `~/.config/yadm/`.

## yadm Tracking

**Track (commit to yadm):** README.md, plugins/config.json, custom agents/skills/hooks/hookify rules.

**Never track:** settings.json, settings.local.json, plugins/cache/, plugins/marketplaces/, file-history/, projects/, debug/, plugins/installed_plugins.json, plugins/known_marketplaces.json.

## settings.json

All Claude settings live in `~/.claude/settings.json` (untracked). Do NOT split into settings.local.json — at project scope, settings.local.json shadows (fully replaces) the user-level file rather than merging, which breaks user-level permissions.allow, enabledPlugins, and hooks.

Use `settings.json` at both user and project scope.

## After Plugin/Config Changes

1. Update @~/.claude/README.md
2. Sync: `yadm add <files> && yadm commit -m "description" && yadm push`

## devops-toolkit Plugin Sync

Location: @~/.claude/plugins/repos/devops-toolkit
Remote: `git@github.com:adamancini/devops-toolkit.git`

MANDATORY sync after modifying agents/skills or during updates:
```bash
cd ~/.claude/plugins/repos/devops-toolkit && git fetch origin && git pull --rebase origin main && git push origin main
```
