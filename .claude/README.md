# Claude Code Configuration Management

This document explains what Claude Code files are synced via yadm and why.

## Tracked Files (Synced Across Machines)

### Core Configuration
- **`.claude/CLAUDE.md`** - Personal Claude Code configuration and preferences
- **`.claude/settings.json`** - Claude Code settings (statusline, allowlist, etc.)
- **`.claude/settings.local.json`** - Local settings overrides

### Custom Agents & Skills

**Note:** All custom agents and skills are now managed in the `devops-toolkit` plugin repository (no longer stored in `.claude/agents/` or `.claude/skills/`). This allows agents and skills to be synced via git and shared across workstations through the plugin system.

See the "Plugin Repositories" section below for the devops-toolkit repository location and complete list of agents and skills.

### Hooks
- **`.claude/hooks/user-prompt-submit-mcp-reminder.py`** - Reminds about MCP security validation

### Hookify Rules (Custom Validations)
- **`.claude/hookify.block-claude-in-commits.local.md`** - Prevents "Claude" mentions in commits
- **`.claude/hookify.require-mcp-security-validation.local.md`** - Enforces MCP security checks
- **`.claude/hookify.validate-helm-templates.local.md`** - Validates Helm template syntax
- **`.claude/hookify.validate-markdown.local.md`** - Lints markdown files
- **`.claude/hookify.validate-yaml-indentation.local.md`** - Checks YAML indentation

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

### Plugin Architecture

**All plugins are installed at USER SCOPE** (globally available on each workstation).

**Installation Strategy:**
- Plugins installed at **user scope** via `claude plugin install PLUGIN@MARKETPLACE --scope user`
- Available globally across all projects on a workstation
- Each workstation can have different plugins enabled

**Enablement Strategy:**
- **User default:** Most plugins are **disabled by default** in `~/.claude/settings.json`
- **Core plugins enabled:** Only 5 essential plugins enabled by default (see below)
- **Per-project override:** Enable specific plugins in project `.claude/settings.json`

**Benefits:**
- ✅ Minimal context usage by default (only 5 core plugins loaded)
- ✅ Selective enablement per project type
- ✅ Different plugin sets per workstation
- ✅ Template-based configuration for common project types

### Installed Marketplaces
- **superpowers-marketplace** (obra/superpowers-marketplace)
- **claude-plugins-official** (anthropics/claude-plugins-official)
- **claude-code-workflows** (wshobson/agents)
- **devops-toolkit** (adamancini/devops-toolkit) - Local repository

### Plugins Enabled by Default (User Scope)

These 5 plugins are enabled in `~/.claude/settings.json`:

1. **superpowers@superpowers-marketplace** - Core skills library
2. **episodic-memory@superpowers-marketplace** - Cross-session memory
3. **superpowers-developing-for-claude-code@superpowers-marketplace** - Development docs
4. **devops-toolkit@devops-toolkit** - Personal DevOps toolkit
5. **hookify@claude-plugins-official** - Hook management

### Plugins Available (Disabled by Default)

All 35+ other plugins are available but disabled by default. Enable them per-project as needed.

**From claude-plugins-official:**
- pr-review-toolkit, commit-commands, feature-dev, code-review
- security-guidance, context7, frontend-design, gopls-lsp
- plugin-dev, Notion, explanatory-output-style, learning-output-style

**From superpowers-marketplace:**
- elements-of-style

**From claude-code-workflows:**
- cicd-automation, cloud-infrastructure, code-documentation
- code-refactoring, codebase-cleanup, developer-essentials
- distributed-debugging, documentation-generation
- error-debugging, error-diagnostics, kubernetes-operations
- shell-scripting, agent-orchestration, context-management
- debugging-toolkit, full-stack-orchestration, git-pr-workflows
- observability-monitoring, security-compliance, security-scanning
- systems-programming, unit-testing

### Per-Project Plugin Enablement

Create `.claude/settings.json` in any project to enable additional plugins:

```json
{
  "enabledPlugins": {
    "kubernetes-operations@claude-code-workflows": true,
    "shell-scripting@claude-code-workflows": true,
    "pr-review-toolkit@claude-plugins-official": true
  }
}
```

**Project Templates Available:**
- Kubernetes/Helm: `~/.claude/templates/kubernetes-settings.json`
- Go Development: `~/.claude/templates/go-settings.json`
- Shell Scripting: `~/.claude/templates/shell-settings.json`
- DevOps/Infrastructure: `~/.claude/templates/devops-settings.json`

See "Plugin Templates" section below for details.

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

4. **Install all plugins at USER SCOPE:**
   ```bash
   # Core plugins (enabled by default)
   claude plugin install superpowers@superpowers-marketplace --scope user
   claude plugin install episodic-memory@superpowers-marketplace --scope user
   claude plugin install superpowers-developing-for-claude-code@superpowers-marketplace --scope user
   claude plugin install hookify@claude-plugins-official --scope user

   # Additional plugins (disabled by default, enable per-project or per-workstation)
   claude plugin install elements-of-style@superpowers-marketplace --scope user
   claude plugin install pr-review-toolkit@claude-plugins-official --scope user
   claude plugin install feature-dev@claude-plugins-official --scope user
   claude plugin install commit-commands@claude-plugins-official --scope user
   claude plugin install kubernetes-operations@claude-code-workflows --scope user
   claude plugin install shell-scripting@claude-code-workflows --scope user
   # ... (install others as needed)

   # Or use a bulk install script (if available)
   ```

5. **Install custom plugin repos:**
   ```bash
   # Clone and install devops-toolkit plugin (contains agents and skills)
   cd ~/.claude/plugins/repos
   git clone git@github.com:adamancini/devops-toolkit.git
   claude plugin install ~/.claude/plugins/repos/devops-toolkit --scope user
   ```

6. **Configure per-workstation enablement (optional):**
   ```bash
   # Edit ~/.claude/settings.json to enable additional plugins on this workstation
   # Or keep the default minimal set and enable per-project instead
   ```

7. **Verify configuration:**
   ```bash
   claude plugin list | grep "Scope: user"  # All plugins at user scope
   claude plugin list | grep "enabled"      # See which are enabled
   ls ~/.claude/templates/                  # Project templates
   ls ~/.claude/hookify.*.local.md          # Hookify rules
   cat ~/.claude/settings.json              # User settings
   ```

## Plugin Templates

Pre-configured `.claude/settings.json` templates for common project types. Copy to your project directory to enable relevant plugins.

### Kubernetes/Helm Projects

**Template:** `~/.claude/templates/kubernetes-settings.json`

**Enables:**
- kubernetes-operations@claude-code-workflows
- cloud-infrastructure@claude-code-workflows
- yaml-kubernetes-validator (via devops-toolkit)
- helm-chart-developer (via devops-toolkit)
- shell-scripting@claude-code-workflows

**Usage:**
```bash
cp ~/.claude/templates/kubernetes-settings.json /path/to/k8s-project/.claude/settings.json
```

### Go Development

**Template:** `~/.claude/templates/go-settings.json`

**Enables:**
- systems-programming@claude-code-workflows (includes golang-pro)
- gopls-lsp@claude-plugins-official
- feature-dev@claude-plugins-official
- pr-review-toolkit@claude-plugins-official
- unit-testing@claude-code-workflows

**Usage:**
```bash
cp ~/.claude/templates/go-settings.json /path/to/go-project/.claude/settings.json
```

### Shell Scripting

**Template:** `~/.claude/templates/shell-settings.json`

**Enables:**
- shell-scripting@claude-code-workflows (posix-shell-pro, bash-pro)
- shell-code-optimizer (via devops-toolkit)
- debugging-toolkit@claude-code-workflows

**Usage:**
```bash
cp ~/.claude/templates/shell-settings.json /path/to/shell-project/.claude/settings.json
```

### DevOps/Infrastructure

**Template:** `~/.claude/templates/devops-settings.json`

**Enables:**
- cicd-automation@claude-code-workflows
- cloud-infrastructure@claude-code-workflows
- kubernetes-operations@claude-code-workflows
- shell-scripting@claude-code-workflows
- security-scanning@claude-code-workflows

**Usage:**
```bash
cp ~/.claude/templates/devops-settings.json /path/to/devops-project/.claude/settings.json
```

### Creating Custom Templates

1. Create a new project-specific `.claude/settings.json`
2. Test the plugin combination
3. Save as a template in `~/.claude/templates/`
4. Document in this README

## Rationale

### Why Track These Files?
- **Custom agents** - Now managed via devops-toolkit plugin repository (separate git repo)
- **Hookify rules** - Enforce consistency across all machines
- **Custom skills** - Domain-specific knowledge and automation (non-plugin skills)
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

1. **Custom agents** - Manage via plugin repositories (like devops-toolkit) for better organization and git sync
2. **Custom skills** - Track standalone skills in `.claude/skills/`, or add to plugin repos for shared workflows
3. **Hookify rules** - Track to maintain consistency across machines
4. **Plugin repos** - Manage as separate git repositories (agents and skills live here)
5. **Marketplaces** - Don't track (they're cloned from upstream)
6. **Cache** - Never track (regenerated automatically)
7. **Secrets** - Never track (use `.local.md` files ignored by yadm)

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

**60-claude-plugins:** Updates marketplaces, installs superpowers plugins, clones devops-toolkit (contains agents and skills)

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
