# Configuration & yadm Management

## yadm Usage

NEVER use `yadm status -u` or `yadm status -uall` -- it enumerates the entire home directory. Always use `yadm status` without the `-u` flag.

## yadm Tracking

**Track (commit to yadm):** README.md, plugins/config.json, custom agents/skills/hooks. (Hookify rules at user scope do NOT fire — hookify globs relative to CWD; use settings.json hooks for global enforcement.)

**Never track:** settings.json, settings.local.json, plugins/cache/, plugins/marketplaces/, file-history/, projects/, debug/, plugins/installed_plugins.json, plugins/known_marketplaces.json.

## settings.json

User-level settings live in `~/.claude/settings.json` (untracked). That is the single home for personal config, plugins and global hooks.

How scopes combine (per the Claude Code settings docs): precedence is managed > CLI `--settings` > project local (`.claude/settings.local.json`) > project (`.claude/settings.json`) > user. Precedence is **per key**: a project file only overrides the keys it sets, and list keys such as `permissions.allow` merge across scopes. A project file does not mask the user file. Project files are read from the session's working directory or repo root; they are not inherited from parent directories the way CLAUDE.md is.

- **Projects may have their own `.claude/settings.json` and `settings.local.json`.** That is fine. Don't be surprised by them: when one changes behavior that matters (plugins enabled or disabled, permissions, hooks, model), mention it. `/status` shows the setting sources.
- **Never create `~/.claude/settings.local.json`.** Launching `claude` from `$HOME` makes `~/.claude/` both the user dir and the project dir, so a local file there would apply only to `$HOME`-rooted sessions. That split state is exactly what caused confusion before. Keep personal settings in `~/.claude/settings.json`.
- **Install plugins at user scope by default.** Project or local scope writes `enabledPlugins` into the repo's `.claude/settings*.json`, and that's where plugins "ended up at project scope" before. Use project scope only when the repo should carry the plugin.

## Plugin Sync Strategy

Do NOT track plugin state in yadm. Previous attempts caused constant merge conflicts from cache churn and timestamp drift in `installed_plugins.json`.

**What to track (yadm):** `plugins/config.json`, `plugins/known_marketplaces.json`, hooks, CLAUDE.md, rules/
**What NOT to track:** `settings.json`, `settings.local.json`, `plugins/cache/`, `plugins/marketplaces/`, `plugins/installed_plugins.json`

Plugins are re-installed on new machines via the bootstrap script (`~/.config/yadm/bootstrap.d/60-claude-plugins.sh`).
Custom agents/skills live in plugin repos (e.g., `devops-toolkit`) managed as separate git repositories.

## After Plugin/Config Changes

1. Update `~/.claude/README.md`
2. Sync: `yadm add <files> && yadm commit -m "description" && yadm push`

## devops-toolkit Plugin Sync

Location: `~/.claude/plugins/repos/devops-toolkit`
Remote: `git@github.com:adamancini/devops-toolkit.git`

MANDATORY sync after modifying agents/skills or during updates:
```bash
git -C ~/.claude/plugins/repos/devops-toolkit fetch origin && git -C ~/.claude/plugins/repos/devops-toolkit pull --rebase origin main && git -C ~/.claude/plugins/repos/devops-toolkit push origin main
```

### Version bump is MANDATORY on every push to this (or any) marketplace-enabled plugin

Not currently enforced by git tooling -- must be handled at development time,
every time, with no exceptions. A push to a Claude plugin marketplace repo
without a version bump is silently ignored by the plugin cache -- the
content changes ship in the git history but never reach a running session
until someone notices the version didn't move.

Before every push that touches plugin content (SKILL.md, agents/*.md,
references/*.md, hooks, or any file under `plugins/<name>/`), bump BOTH:

1. The individual skill/agent's own `version:` frontmatter field in its
   `SKILL.md` (or agent file), if it has one.
2. The plugin-wide `version` field in `.claude-plugin/marketplace.json`
   (under `plugins[].version` for the affected plugin entry).

Both bumps go in the same commit (or an immediately following commit)
as the content change -- never push content changes and defer the version
bump to "later." If in doubt about bump size, follow this repo's existing
pattern of small, frequent minor/patch bumps per notable change (see
`git log -- .claude-plugin/marketplace.json` for precedent).
