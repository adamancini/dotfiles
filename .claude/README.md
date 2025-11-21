# Claude Code Configuration Management

This document explains what Claude Code files are synced via yadm and why.

## Tracked Files (Synced Across Machines)

### Core Configuration
- **`.claude/CLAUDE.md`** - Personal Claude Code configuration and preferences
- **`.claude/settings.json`** - Claude Code settings (statusline, allowlist, etc.)
- **`.claude/settings.local.json`** - Local settings overrides

### Custom Agents
- **`.claude/agents/*.md`** - Custom agents for specialized tasks:
  - `claudemd-compliance-checker.md` - Verifies compliance with project CLAUDE.md
  - `helm-chart-developer.md` - Helm chart development and review
  - `markdown-writer.md` - Markdown document creation and improvement
  - `mcp-security-validator.md` - MCP server security validation
  - `quality-control-enforcer.md` - Code quality review
  - `shell-code-optimizer.md` - Shell script optimization
  - `yaml-kubernetes-validator.md` - YAML and Kubernetes manifest validation

### Hooks
- **`.claude/hooks/user-prompt-submit-mcp-reminder.py`** - Reminds about MCP security validation

### Hookify Rules (Custom Validations)
- **`.claude/hookify.block-claude-in-commits.local.md`** - Prevents "Claude" mentions in commits
- **`.claude/hookify.require-mcp-security-validation.local.md`** - Enforces MCP security checks
- **`.claude/hookify.validate-helm-templates.local.md`** - Validates Helm template syntax
- **`.claude/hookify.validate-markdown.local.md`** - Lints markdown files
- **`.claude/hookify.validate-yaml-indentation.local.md`** - Checks YAML indentation

### Custom Skills
- **`.claude/skills/replicated-cli/`** - Replicated CLI workflow automation
  - `SKILL.md` - Main skill definition
  - `references/*.md` - CLI commands, VM management, release workflows
  - `examples/Makefile.*` - Example integration patterns

### Plugin Configuration
- **`.claude/plugins/config.json`** - Plugin system configuration
- **`.claude/plugins/known_marketplaces.json`** - Registered plugin marketplaces

### Scripts
- **`.claude/statusline-command.sh`** - Custom statusline showing git, k8s, system info

## NOT Tracked (Local-Only)

### Cache and Temporary Files
- `.claude/plugins/cache/` - Downloaded plugin cache (regenerated from marketplaces)
- `.claude/plugins/installed_plugins.json` - Plugin install registry (regenerated, has timestamps/paths)
- `.claude/plugins/marketplaces/` - Marketplace repositories (cloned from remote)
- `.claude/file-history/` - File edit history (session-specific)
- `.claude/debug/` - Debug logs (temporary)
- `.claude/ide/*.lock` - IDE lock files (process-specific)

### Project-Specific Data
- `.claude/projects/` - Per-project conversation history (machine-specific paths)
- `.claude/todos/` - Todo list state (session-specific)
- `.claude/shell-snapshots/` - Shell environment snapshots (machine-specific)
- `.claude/history.jsonl` - Command history (local)

### Security State
- `.claude/security_warnings_state_*.json` - Security warning tracking (session-specific)

### Corrupted Files
- `.claude.json.corrupted.*` - Backup corruption records (not needed on other machines)

## Plugin Repositories

Plugin repositories like `.claude/plugins/repos/devops-toolkit/` are **separate git repositories**
and should be managed independently:

```bash
# Clone on new machine
cd ~/.claude/plugins/repos
git clone https://github.com/your-org/devops-toolkit.git

# Or use plugin installation
claude plugin install /path/to/devops-toolkit
```

## Current Plugin Configuration

### Installed Marketplaces
- **superpowers-marketplace** (obra/superpowers-marketplace)
- **claude-code-plugins** (anthropics/claude-code)

### Installed & Enabled Plugins

**From claude-code-plugins:**
- agent-sdk-dev
- pr-review-toolkit
- commit-commands
- feature-dev
- security-guidance
- code-review
- explanatory-output-style
- learning-output-style
- frontend-design
- ralph-wiggum
- hookify
- plugin-dev

**From superpowers-marketplace:**
- superpowers (v3.4.1) - Core skills library with TDD, debugging, collaboration patterns
- elements-of-style - Writing guidance based on Strunk's Elements of Style
- superpowers-developing-for-claude-code - Skills for developing Claude Code plugins/MCP servers

**Custom:**
- devops-toolkit - Custom DevOps automation toolkit

## Setup on New Machine

When setting up a new machine with yadm:

1. **Clone dotfiles:**
   ```bash
   yadm clone https://github.com/adamancini/dotfiles.git
   ```

2. **Install Claude Code:**
   Follow Claude Code installation instructions

3. **Update and install plugin marketplaces:**
   ```bash
   claude plugin marketplace update
   ```

4. **Install plugins from marketplaces:**
   ```bash
   # Superpowers marketplace plugins
   claude plugin install superpowers@superpowers-marketplace
   claude plugin install elements-of-style@superpowers-marketplace
   claude plugin install superpowers-developing-for-claude-code@superpowers-marketplace

   # Claude Code plugins are installed automatically from known_marketplaces.json
   ```

5. **Install custom plugin repos:**
   ```bash
   # Clone devops-toolkit plugin (contains replicated-cli skill)
   cd ~/.claude/plugins/repos
   git clone git@github.com:adamancini/devops-toolkit.git
   ```

6. **Verify configuration:**
   ```bash
   ls ~/.claude/agents/          # Custom agents
   ls ~/.claude/skills/          # Custom skills
   ls ~/.claude/hookify.*.local.md  # Hookify rules
   cat ~/.claude/settings.json   # Settings
   ```

## Rationale

### Why Track These Files?
- **Custom agents** - Represent significant work and specialized workflows
- **Hookify rules** - Enforce consistency across all machines
- **Custom skills** - Domain-specific knowledge and automation
- **Settings** - Personal preferences and configurations
- **Plugin config** - Which plugins/marketplaces to use

### Why NOT Track These Files?
- **Cache** - Regenerated automatically, wastes space
- **installed_plugins.json** - Contains timestamps/paths that change frequently, regenerated on install
- **Project history** - Machine-specific paths, privacy concerns
- **Debug logs** - Temporary, large, not useful across machines
- **Session state** - Only relevant to active sessions
- **Plugin repos** - Separate git repositories (avoid nested repos)

## Maintenance

### Adding New Trackable Files
```bash
yadm add ~/.claude/your-new-file.md
yadm commit -m "Add new Claude Code configuration"
yadm push
```

### Updating on Other Machines
```bash
yadm pull
# Verify changes
yadm status
```

### Checking What's Tracked
```bash
yadm ls-files | grep "^\.claude"
```

## Best Practices

1. **Custom agents and skills** - Always track these (they're your work)
2. **Hookify rules** - Track to maintain consistency across machines
3. **Plugin repos** - Manage as separate git repositories
4. **Marketplaces** - Don't track (they're cloned from upstream)
5. **Cache** - Never track (regenerated automatically)
6. **Secrets** - Never track (use `.local.md` files ignored by yadm)
