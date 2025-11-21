# YADM Bootstrap System

Automated laptop bootstrap system for setting up a fresh macOS machine with all essential tools, configurations, and applications.

## Overview

This bootstrap system automates the complete setup of a new laptop from a fresh install to a fully configured development environment. It's designed to be:

- **Idempotent**: Can be run multiple times safely
- **Modular**: Each phase is independent and can be run separately
- **Resumable**: Tracks completed phases and skips them on re-run
- **Extensible**: Easy to add new phases for future requirements

## System Architecture

```
~/.config/yadm/
├── bootstrap                    # Main orchestrator script
└── bootstrap.d/                 # Phase scripts (auto-discovered)
    ├── 00-prerequisites.sh      # Prerequisites check
    ├── 10-core-tools.sh         # Homebrew & essential tools
    ├── 20-shell-config.sh       # Shell environment setup
    ├── 30-ssh-keys.sh           # SSH keys configuration
    ├── 40-gpg-passstore.sh      # GPG & password-store
    ├── 50-brewfile.sh           # Package installation
    ├── 60-claude-plugins.sh     # Claude Code plugins
    └── 90-finalize.sh           # Health checks & report

~/bin/
└── bootstrap-laptop.sh          # Convenient wrapper script

~/.bootstrap-markers/            # Phase completion markers
~/.bootstrap-logs/               # Execution logs
```

## Quick Start

### New Machine Setup

1. **Restore GPG Key (REQUIRED)**
   ```bash
   gpg --import /path/to/backup/gpg-key.asc
   gpg --edit-key adab3ta@gmail.com
   # Type: trust, 5, quit
   ```

2. **Clone Dotfiles** (bootstrap runs automatically)
   ```bash
   yadm clone git@github.com:adamancini/dotfiles.git
   ```

   Or if SSH not setup yet:
   ```bash
   yadm clone https://github.com/adamancini/dotfiles.git
   ```

3. **Follow Manual Steps** from completion report

### Manual Execution

```bash
# Full bootstrap
~/.config/yadm/bootstrap

# Using wrapper
~/bin/bootstrap-laptop.sh

# Skip phases
SKIP_PHASES="30,40" ~/.config/yadm/bootstrap

# Run specific phases only
ONLY_PHASES="50" ~/.config/yadm/bootstrap

# Debug mode
DEBUG=1 ~/.config/yadm/bootstrap
```

## Phase Descriptions

### Phase 00: Prerequisites Check

**Purpose:** Verify all prerequisites before bootstrap proceeds

**Checks:**
- Operating system (macOS preferred, Linux experimental)
- Internet connectivity (`ping github.com`)
- Sudo access availability
- **GPG key presence** (CRITICAL - must be restored manually)
- Available disk space (warns if <10GB)
- Existing YADM setup

**Failures:**
- Missing GPG key → Aborts bootstrap with instructions
- No internet → Aborts bootstrap
- Other checks → Warnings only

**Idempotency:** Always runs (fast check phase)

---

### Phase 10: Core Tools Installation

**Purpose:** Install foundational development tools

**Installs:**
1. Xcode Command Line Tools (macOS)
   - Required for `git` and compilation
   - Prompts for user confirmation
   - Waits up to 5 minutes for installation

2. Homebrew
   - Package manager for macOS/Linux
   - Installs to `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel)
   - Adds to PATH for current session

3. Essential tools via Homebrew:
   - `git` - Version control
   - `curl` - HTTP client
   - `gnupg` - GPG encryption
   - `yadm` - Dotfiles manager
   - `pass` - Password store

**Idempotency:** Checks if each tool already installed

**Failures:** Aborts if critical tools fail to install

---

### Phase 20: Shell Configuration

**Purpose:** Setup shell environment and process YADM templates

**Actions:**
1. Run `yadm alt` to create template symlinks
   - Processes `##os.Darwin` suffixes
   - Creates symlinks like `.gitconfig.local -> .gitconfig.local##os.Darwin`

2. Verify directory structure:
   - `~/.zshrcd` (custom ZDOTDIR)
   - `~/.zshrcd/conf.d` (modular configs)
   - `~/.config` (XDG_CONFIG_HOME)

3. Check PATH configuration
4. Verify key config files exist

**Idempotency:** Template processing is idempotent

**Note:** Changes take effect after opening new terminal or `exec zsh`

---

### Phase 30: SSH Keys Setup

**Purpose:** Interactive setup for SSH keys

**Interactive Prompts:**
```
SSH key not found. What would you like to do?
  (g) Generate new SSH key
  (i) Import existing SSH key
  (s) Skip SSH setup
```

**Actions:**
- **Generate:** Creates new RSA 4096-bit key at `~/.ssh/id_moira`
- **Import:** Prompts for path and copies to `~/.ssh/id_moira`
- **Skip:** Continues without SSH setup

**Post-setup:**
1. Creates symlinks: `id_rsa -> id_moira`
2. Adds key to ssh-agent
3. Tests GitHub connection
4. Displays public key for adding to GitHub

**Idempotency:** Skips if `~/.ssh/id_moira` already exists

**Non-interactive mode:** Skips with warning

---

### Phase 40: GPG and Password-Store Setup

**Purpose:** Configure GPG agent and setup password-store

**Prerequisites:** GPG key must already be imported (verified in Phase 00)

**Actions:**
1. Verify GPG key present for `adab3ta@gmail.com`
2. Configure `~/.gnupg/gpg-agent.conf`:
   - pinentry-program: `/opt/homebrew/bin/pinentry`
   - Cache timeouts: 600s / 7200s
   - Enable SSH support
3. Write `~/.gnupg/common.conf` (use-keyboxd)
4. Restart GPG agent
5. Test GPG signing
6. Initialize pass if needed
7. Clone password-store repository:
   - Tries SSH first: `git@github.com:adamancini/password-store.git`
   - Falls back to HTTPS if SSH fails
8. Verify pass functionality

**Idempotency:** Skips if password-store already cloned

**Failures:** Warnings only, doesn't abort bootstrap

---

### Phase 50: Brewfile Installation

**Purpose:** Install packages, casks, and apps from Brewfile

**Location:** `~/.zshrcd/conf.d/Brewfile`

**Installs:**
- 12 taps (additional Homebrew repositories)
- 82 brew packages (CLI tools)
- 17 casks (GUI applications)
- 12 Mac App Store apps (via `mas`)
- 60 VS Code extensions
- 7 Go packages

**Process:**
1. Verify Homebrew installed
2. Display Brewfile stats
3. Run `brew bundle --file=~/.zshrcd/conf.d/Brewfile --no-lock`
4. Handle errors gracefully (some packages may fail)
5. Run `brew cleanup`
6. Verify critical packages installed

**Known Issues:**
- `wireshark-app` cask may fail (documented, non-critical)

**Duration:** 10-30 minutes depending on network speed

**Idempotency:** Homebrew handles already-installed packages

---

### Phase 60: Claude Code Plugins Setup

**Purpose:** Install and configure Claude Code plugins

**Prerequisites:** Claude Code app installed at `/Applications/Claude.app`

**Actions:**
1. Check Claude Code and CLI availability
2. Update plugin marketplaces: `claude plugin marketplace update`
3. Install superpowers marketplace plugins:
   - `superpowers@superpowers-marketplace`
   - `elements-of-style@superpowers-marketplace`
   - `superpowers-developing-for-claude-code@superpowers-marketplace`
4. Clone devops-toolkit custom plugin:
   - `git clone https://github.com/adamancini/devops-toolkit.git`
   - Location: `~/.claude/plugins/repos/devops-toolkit`
5. Verify configuration files exist
6. List installed plugins

**Idempotency:**
- Checks if plugins already installed
- Updates devops-toolkit if already cloned

**Failures:** Warnings only if Claude Code not installed

**Note:** Custom agents, skills, and hookify rules are tracked in dotfiles

---

### Phase 90: Finalization and Verification

**Purpose:** Run health checks and generate completion report

**Health Checks:**
- Core tools (git, brew, yadm)
- Security tools (gpg, pass, ssh)
- Development tools (kubectl, helm, docker)
- Optional tools (claude, aerospace)

**Configuration Verification:**
- Shell configuration (`.zshrc`, `.zshenv`, `~/.zshrcd`)
- Git configuration (`.gitconfig`, `.gitconfig.local`)
- SSH configuration (`~/.ssh/`, keys)
- GPG configuration (`~/.gnupg/`, key presence)
- Password store (`~/.password-store/.git`)
- Claude Code (`~/.claude/`, agents, skills)

**Manual Steps Check:**
- SSH key added to GitHub
- GPG signing key configured
- Claude Code installed

**Report Generation:**
- Creates detailed completion report
- Saved to: `~/.bootstrap-report-YYYYMMDD-HHMMSS.txt`
- Displays summary of installed tools
- Lists manual steps required
- Provides useful commands reference

**Output:** Always returns success (informational phase)

---

## Orchestrator Features

### Phase Management

**Auto-discovery:**
- Finds all `*.sh` files in `bootstrap.d/`
- Executes in alphabetical/numerical order
- Makes scripts executable automatically

**Completion Tracking:**
- Creates markers in `~/.bootstrap-markers/`
- Format: `NN-phase-name.sh.complete`
- Skips phases with existing markers
- To re-run: `rm ~/.bootstrap-markers/<phase>.complete`

**Selective Execution:**
```bash
# Skip phases 30 and 40
SKIP_PHASES="30,40" ~/.config/yadm/bootstrap

# Run only phase 50
ONLY_PHASES="50" ~/.config/yadm/bootstrap

# Multiple phases
ONLY_PHASES="20,30,40" ~/.config/yadm/bootstrap
```

### Logging

**Log Files:**
- Location: `~/.bootstrap-logs/bootstrap-YYYYMMDD-HHMMSS.log`
- Contains: All output from phases with timestamps
- Retention: Manual cleanup (not automated)

**Log Levels:**
- `[INFO]` - Informational messages
- `[WARN]` - Warnings (non-critical)
- `[ERROR]` - Errors (may abort phase)
- `[✓]` - Success confirmations

### Error Handling

**Phase Failures:**
- Displays error message with exit code
- Asks if bootstrap should continue (interactive mode)
- In non-interactive mode: Continues with warnings

**Final Summary:**
- Lists completed phases
- Lists skipped phases
- Lists failed phases
- Exit code 1 if any phase failed

### User Interaction

**Interactive Mode** (terminal attached):
- Prompts for SSH key generation/import
- Asks whether to continue after phase failure
- Colored output for better readability

**Non-Interactive Mode** (no terminal):
- Skips interactive prompts
- Uses defaults where possible
- Logs warnings for skipped interactions

---

## Extending the System

### Adding New Phases

1. **Create phase script:**
   ```bash
   vim ~/.config/yadm/bootstrap.d/NN-phase-name.sh
   ```

   Where `NN` determines execution order (00-99)

2. **Use template:**
   ```bash
   #!/bin/bash
   set -uo pipefail

   # Color output
   info() { echo "[INFO] $*"; }
   warn() { echo "[WARN] $*"; }
   error() { echo "[ERROR] $*"; }
   success() { echo "[✓] $*"; }

   main() {
       info "Running my custom phase..."

       # Idempotency check
       if [[ -f ~/.my-marker ]]; then
           success "Already completed"
           return 0
       fi

       # Do work...

       # Mark complete
       touch ~/.my-marker
       success "Completed"
       return 0
   }

   main "$@"
   ```

3. **Make executable:**
   ```bash
   chmod +x ~/.config/yadm/bootstrap.d/NN-phase-name.sh
   ```

4. **Test:**
   ```bash
   ~/.config/yadm/bootstrap.d/NN-phase-name.sh
   # or
   ONLY_PHASES="NN" ~/.config/yadm/bootstrap
   ```

5. **Add to yadm:**
   ```bash
   yadm add ~/.config/yadm/bootstrap.d/NN-phase-name.sh
   yadm commit -m "Add phase NN: description"
   yadm push
   ```

### Local Customizations

For machine-specific phases not tracked in dotfiles:

```bash
# Create local phase (not tracked by yadm)
vim ~/.config/yadm/bootstrap.d/99-local.sh
chmod +x ~/.config/yadm/bootstrap.d/99-local.sh

# Add to .gitignore
echo "99-local.sh" >> ~/.config/yadm/bootstrap.d/.gitignore
```

---

## Troubleshooting

### Bootstrap won't start

**Symptom:** Bootstrap script not found

**Solution:**
```bash
# Check if bootstrap exists
ls -l ~/.config/yadm/bootstrap

# If missing, check yadm status
yadm status

# Pull latest changes
yadm pull

# Make executable
chmod +x ~/.config/yadm/bootstrap
```

---

### Phase fails repeatedly

**Symptom:** Same phase fails on every run

**Solution:**
```bash
# Check phase logs
tail -50 ~/.bootstrap-logs/bootstrap-*.log

# Run phase manually for debugging
bash -x ~/.config/yadm/bootstrap.d/NN-phase-name.sh

# Remove completion marker to force re-run
rm ~/.bootstrap-markers/NN-phase-name.sh.complete
```

---

### GPG key not found

**Symptom:** Phase 00 aborts with GPG key error

**Solution:**
```bash
# Import your GPG private key
gpg --import /path/to/backup/private-key.asc

# Trust the key
gpg --edit-key adab3ta@gmail.com
# Type: trust, 5 (ultimate), quit

# Verify
gpg --list-secret-keys adab3ta@gmail.com

# Re-run bootstrap
~/.config/yadm/bootstrap
```

---

### SSH connection to GitHub fails

**Symptom:** Cannot clone repositories via SSH

**Solution:**
```bash
# Check SSH key exists
ls -l ~/.ssh/id_moira

# Display public key
cat ~/.ssh/id_moira.pub

# Add to GitHub: https://github.com/settings/keys

# Test connection
ssh -T git@github.com

# If still fails, check ssh-agent
ssh-add -l
ssh-add ~/.ssh/id_moira
```

---

### Brewfile installation errors

**Symptom:** Some packages fail during Phase 50

**Solution:**
```bash
# Check what failed
brew bundle --file=~/.zshrcd/conf.d/Brewfile check

# Install failed packages manually
brew install <package-name>

# Known issues:
# - wireshark-app cask: Safe to ignore
# - mas apps: Require App Store login first
```

---

### Claude plugins won't install

**Symptom:** Phase 60 skips or fails

**Solution:**
```bash
# Check if Claude Code installed
ls /Applications/Claude.app

# Download from: https://claude.ai/download

# Launch Claude Code first
open /Applications/Claude.app

# Verify CLI available
which claude

# Re-run phase 60
ONLY_PHASES="60" ~/.config/yadm/bootstrap
```

---

## Maintenance

### Updating Bootstrap System

```bash
# Pull latest bootstrap changes
yadm pull

# Clear all markers to re-run everything
rm -rf ~/.bootstrap-markers

# Or clear specific phase
rm ~/.bootstrap-markers/50-brewfile.sh.complete

# Re-run bootstrap
~/.config/yadm/bootstrap
```

### Viewing Logs

```bash
# List all log files
ls -lh ~/.bootstrap-logs/

# View latest log
tail -f ~/.bootstrap-logs/bootstrap-*.log | tail -1

# View specific phase output
grep "\[50-brewfile\]" ~/.bootstrap-logs/bootstrap-*.log
```

### Cleaning Up

```bash
# Remove old logs (keep last 5)
cd ~/.bootstrap-logs
ls -t | tail -n +6 | xargs rm

# Remove old reports
cd ~
ls -t .bootstrap-report-* | tail -n +6 | xargs rm

# Clear all markers (force full re-run)
rm -rf ~/.bootstrap-markers
```

---

## Best Practices

1. **Test on VM first** - Before running on production machine
2. **Backup important data** - Especially GPG keys and SSH keys
3. **Run phases incrementally** - Use `ONLY_PHASES` for testing
4. **Keep logs** - Useful for debugging and verification
5. **Document customizations** - Add comments to custom phases
6. **Version control** - Commit bootstrap changes to yadm
7. **Review reports** - Check completion reports for manual steps

---

## See Also

- **Claude Code Configuration:** `~/.claude/README.md`
- **YADM Documentation:** https://yadm.io/docs
- **Homebrew Documentation:** https://docs.brew.sh
- **Phase Scripts:** `~/.config/yadm/bootstrap.d/`
