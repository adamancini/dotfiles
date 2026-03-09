# Configuration & yadm Management

## yadm Tracking

**Track (commit to yadm):** README.md, settings.json, plugins/config.json, plugins/installed_plugins.json, plugins/known_marketplaces.json, custom agents/skills/hooks/hookify rules.

**Never track:** plugins/cache/, plugins/marketplaces/, file-history/, projects/, debug/, settings.local.json (machine-specific overrides)

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
