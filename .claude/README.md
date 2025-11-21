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
  - `home-manager.md` - Home directory organization, dotfiles management, repository organization
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
- **`.claude/skills/yadm-utilities/`** - YADM dotfiles management
  - `SKILL.md` - YADM operations, bootstrap, alternates, Brewfile integration

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

## Bootstrap System

The laptop bootstrap system automates the setup of a fresh machine with all essential tools and configurations. The system is modular, idempotent, and can be run multiple times safely.

### Architecture

The bootstrap system uses a modular phase-based approach:

```
~/.config/yadm/
  ├── bootstrap                    # Main orchestrator (runs automatically after yadm clone)
  └── bootstrap.d/                 # Modular phase scripts
      ├── 00-prerequisites.sh      # Verify prerequisites (GPG key, internet, etc.)
      ├── 10-core-tools.sh         # Install Homebrew and essential tools
      ├── 20-shell-config.sh       # Setup shell environment and YADM templates
      ├── 30-ssh-keys.sh           # Interactive SSH key setup
      ├── 40-gpg-passstore.sh      # Configure GPG and password-store
      ├── 50-brewfile.sh           # Install packages from Brewfile
      ├── 60-claude-plugins.sh     # Setup Claude Code plugins
      └── 90-finalize.sh           # Health checks and final report

~/bin/
  └── bootstrap-laptop.sh          # Convenient wrapper for manual invocation
```

### Prerequisites

Before running bootstrap, ensure:

1. **GPG Key Restored**
   - Your GPG private key must be imported: `gpg --import /path/to/key.asc`
   - Trust the key: `gpg --edit-key adab3ta@gmail.com` → `trust` → `5` → `quit`

2. **Internet Connection**
   - Required for downloading tools and cloning repositories

3. **macOS (or Linux experimental)**
   - Currently optimized for macOS, Linux support is experimental

### Usage

#### Automatic Bootstrap (Recommended)

When you clone your dotfiles with YADM, bootstrap runs automatically:

```bash
# Clone dotfiles (bootstrap runs automatically)
yadm clone git@github.com:adamancini/dotfiles.git
```

#### Manual Bootstrap

```bash
# Run full bootstrap
~/.config/yadm/bootstrap

# Or use the convenient wrapper
~/bin/bootstrap-laptop.sh
```

#### Selective Phase Execution

```bash
# Skip specific phases (e.g., SSH and GPG if already configured)
SKIP_PHASES="30,40" ~/.config/yadm/bootstrap

# Run only specific phases
ONLY_PHASES="50,60" ~/.config/yadm/bootstrap   # Only Brewfile and Claude plugins

# Verbose debug output
DEBUG=1 ~/.config/yadm/bootstrap
```

### Phase Details

**00-prerequisites:** Verifies GPG key presence, internet connectivity, sudo access, OS compatibility

**10-core-tools:** Installs Xcode CLI tools, Homebrew, git, gnupg, yadm, pass

**20-shell-config:** Runs `yadm alt` to create template symlinks, verifies shell configuration

**30-ssh-keys:** Interactive prompt to generate new SSH keys or import existing ones, creates symlinks

**40-gpg-passstore:** Configures gpg-agent, tests GPG signing, clones password-store repository

**50-brewfile:** Installs packages from `~/.zshrcd/conf.d/Brewfile`, handles errors gracefully

**60-claude-plugins:** Updates marketplaces, installs superpowers plugins, clones devops-toolkit

**90-finalize:** Runs health checks, verifies configurations, generates completion report

### Idempotency

The bootstrap system is designed to be idempotent:

- Each phase checks if work is already done before proceeding
- Phases create marker files in `~/.bootstrap-markers/` when completed
- Re-running bootstrap skips completed phases
- To force re-run a phase: `rm ~/.bootstrap-markers/NN-phase-name.sh.complete`

### Logs and Reports

- **Logs:** Saved to `~/.bootstrap-logs/bootstrap-YYYYMMDD-HHMMSS.log`
- **Reports:** Generated in `~/.bootstrap-report-YYYYMMDD-HHMMSS.txt`
- Both contain detailed information about what was installed and configured

### Extending the Bootstrap System

To add new phases:

1. Create a new script: `~/.config/yadm/bootstrap.d/NN-phase-name.sh`
2. Make it executable: `chmod +x ~/.config/yadm/bootstrap.d/NN-phase-name.sh`
3. The orchestrator will automatically discover and run it in numerical order

Example phase template:

```bash
#!/bin/bash
set -uo pipefail

# Color output helpers
info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*"; }
error() { echo "[ERROR] $*"; }
success() { echo "[✓] $*"; }

main() {
    info "Running my custom phase..."

    # Check if work already done (idempotency)
    if [[ -f ~/.my-phase-complete ]]; then
        success "Phase already completed"
        return 0
    fi

    # Do the work...

    # Mark as complete
    touch ~/.my-phase-complete
    success "Phase completed"
    return 0
}

main "$@"
```

### Troubleshooting

**Bootstrap fails at prerequisites:**
- Ensure GPG key is imported: `gpg --list-secret-keys adab3ta@gmail.com`
- Check internet connection: `ping github.com`

**SSH key setup fails:**
- Run phase manually: `~/.config/yadm/bootstrap.d/30-ssh-keys.sh`
- Generate keys manually: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_moira`

**Brewfile installation has errors:**
- Normal for some packages (e.g., wireshark-app)
- Check what failed: `brew bundle --file=~/.zshrcd/conf.d/Brewfile check`
- Install failed packages manually

**Claude plugins don't install:**
- Ensure Claude Code app is installed: `ls /Applications/Claude.app`
- Launch Claude Code first, then re-run phase 60

### See Also

- **YADM Bootstrap Documentation:** `~/.config/yadm/README.md`
- **Bootstrap Logs:** `~/.bootstrap-logs/`
- **Phase Scripts:** `~/.config/yadm/bootstrap.d/`
