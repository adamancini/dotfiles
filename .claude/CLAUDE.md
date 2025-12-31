# Personal Claude Code Configuration

## Expertise & Domain Knowledge

- You're an expert at troubleshooting Kubernetes clusters and developing Helm charts
- Deep expertise in Replicated platform, KOTS, and Embedded Cluster deployments
- Proficient with VM-based testing, multi-node cluster configurations, and HA architectures

## AGENTS.md Documentation Guidelines

**CRITICAL: Always proactively read AGENTS.md files when working in directories that have them.**

### When to Read AGENTS.md

- **Immediately** when changing into a directory that contains an AGENTS.md file
- **Before** executing any commands or making changes in that directory
- **After** a user asks you to work on something in a directory with an AGENTS.md
- **Automatically** when exploring a codebase to understand workflows

### Known AGENTS.md Locations

Projects may have AGENTS.md files in subdirectories for workflow-specific documentation:
- `helm/AGENTS.md` - Helm chart development, testing, packaging, and release workflows
- `chef-replicated/chef-360/AGENTS.md` - Replicated distribution, VM management, EC installation workflows

### Priority and Authority

- **AGENTS.md has equal authority to CLAUDE.md** for its directory scope
- When working in a subdirectory with AGENTS.md, follow its instructions for that subdirectory
- AGENTS.md typically contains detailed "how-to" documentation
- CLAUDE.md provides high-level architecture and cross-cutting concerns

### Workflow

1. Identify working directory from user request
2. Check for AGENTS.md in that directory (use Read tool)
3. If found, read and internalize the instructions
4. Follow AGENTS.md instructions for all work in that directory
5. Treat AGENTS.md as authoritative for subdirectory-specific workflows

## Git Operation Guidelines

- **Always show literal output** - For git operations, never summarize; always show the complete, literal output of any git command
- **No Claude mentions** - Never mention "Claude" or "Claude Code" in:
  - Git commit messages
  - Git comments
  - GitHub commit messages
  - PR descriptions (unless explicitly discussing Claude Code features)

## Makefile Invocation Guidelines

**CRITICAL: Bash permission patterns use prefix matching with `:*` wildcard only at the end.**

When invoking make targets with environment variables, ALWAYS use this pattern:

```bash
make TARGET_NAME VARIABLE1=value1 VARIABLE2=value2 ...
```

**✅ CORRECT Examples:**
- `make vm-3node CLUSTER_PREFIX=adamancini`
- `make replicated-release CHANNEL=beta VERSION=1.2.3`
- `make vm-download-ec-binary CLUSTER_PREFIX=test-cluster EC_DOWNLOAD_URL=https://example.com/archive.tgz EC_AUTH_TOKEN=secret123`

**❌ INCORRECT Examples (will not match Bash permissions):**
- `CLUSTER_PREFIX=adamancini make vm-3node` (env var before make)
- `EC_DOWNLOAD_URL=https://example.com make vm-download-ec-binary` (env var before make)

**Why:** The permission `Bash(make:*)` matches commands starting with `make`, followed by anything. Environment variables BEFORE `make` don't match this pattern and will require user approval for every invocation.

## Agent Usage Guidelines

### Mandatory Agent Workflow

**For coding projects - ALWAYS complete this checklist at the end of EVERY todo list:**

1. ☐ Use `claudemd-compliance-checker` agent to verify compliance
2. ☐ For code changes: Use appropriate quality control agent
3. ☐ Mark compliance check as final todo item

**Quality Control Agents - Use at logical stop points for coding projects:**

- After completing a feature implementation
- Before creating commits or PRs
- When finishing a significant refactor
- After adding new configurations or manifests

**NOT for system maintenance tasks:**
- File system reorganization
- yadm/git dotfile syncing
- Installing packages or tools
- General housekeeping tasks
- Repository organization

### Available Specialized Agents

#### Code Quality & Review Agents

**feature-dev:code-reviewer**
- **When to use:** After writing significant code; before commits/PRs
- **Purpose:** Reviews for bugs, logic errors, security vulnerabilities, code quality
- **Confidence-based filtering:** Only reports high-priority issues
- **Tools:** Full file access, grep, web search

**pr-review-toolkit:code-reviewer**
- **When to use:** Before committing changes or creating pull requests
- **Purpose:** Checks adherence to project guidelines, style guides, best practices
- **Focus:** Reviews unstaged git changes by default
- **Tools:** Full tool access

**pr-review-toolkit:silent-failure-hunter**
- **When to use:** After implementing error handling, catch blocks, fallback logic
- **Purpose:** Identifies silent failures, inadequate error handling, inappropriate fallback behavior
- **Proactive use:** For any code that could potentially suppress errors
- **Tools:** Full tool access

**pr-review-toolkit:code-simplifier**
- **When to use:** After completing a coding task or writing a logical chunk of code
- **Purpose:** Simplifies code for clarity, consistency, maintainability while preserving functionality
- **Focus:** Recently modified code unless instructed otherwise
- **Tools:** Full tool access

**pr-review-toolkit:comment-analyzer**
- **When to use:**
  - After generating large documentation comments or docstrings
  - Before finalizing a PR with comment changes
  - When reviewing existing comments for technical debt
- **Purpose:** Analyzes code comments for accuracy, completeness, long-term maintainability
- **Tools:** Full tool access

**pr-review-toolkit:type-design-analyzer**
- **When to use:**
  - When introducing new types
  - During pull request creation with new types
  - When refactoring existing types
- **Purpose:** Expert analysis of type design for encapsulation and invariant expression
- **Ratings:** Provides qualitative feedback and quantitative ratings
- **Tools:** Full tool access

**pr-review-toolkit:pr-test-analyzer**
- **When to use:** After creating/updating a PR to ensure test coverage
- **Purpose:** Reviews test coverage quality and completeness for new functionality
- **Tools:** Full tool access

#### Architecture & Exploration Agents

**feature-dev:code-explorer**
- **When to use:** Need to deeply understand existing codebase features
- **Purpose:** Traces execution paths, maps architecture layers, documents dependencies
- **Use case:** Informing new development with codebase knowledge
- **Tools:** Read, grep, glob, web search

**feature-dev:code-architect**
- **When to use:** Designing new features; need implementation blueprints
- **Purpose:** Analyzes codebase patterns, provides comprehensive implementation plans
- **Output:** Specific files to create/modify, component designs, data flows, build sequences
- **Tools:** Read, grep, glob, web search

**Explore agent (quick/medium/very thorough)**
- **When to use:** Quick codebase exploration, finding files by patterns, searching for keywords
- **Thoroughness levels:**
  - `quick` - Basic searches
  - `medium` - Moderate exploration
  - `very thorough` - Comprehensive analysis across multiple locations
- **Tools:** All tools

#### Validation & Compliance Agents

**claudemd-compliance-checker**
- **When to use (coding projects only):**
  - **MANDATORY:** At the end of every coding project todo list
  - After writing/modifying code subject to project standards
  - Before creating git commits in coding projects
  - When installing/configuring MCP servers
  - After configuration changes (build systems, CI/CD, deployment manifests)
  - After modifying Helm charts or Kubernetes manifests
- **When NOT to use:**
  - File system reorganization
  - yadm/git dotfile syncing
  - Installing packages or tools
  - General housekeeping tasks
  - Repository organization
- **Purpose:** Verifies compliance with project-specific instructions in CLAUDE.md/AGENTS.md
- **Scope:** Code standards, git workflows, MCP security, Helm templating, infrastructure configs
- **Tools:** Full tool access

**yaml-kubernetes-validator**
- **When to use:** Writing, reviewing, or validating YAML documents, especially K8s manifests
- **Purpose:** Ensures YAML conforms to best practices, proper indentation, K8s API specifications
- **Standards:** Leverages yaml-language-server for validation
- **Tools:** All tools

**helm-chart-developer**
- **When to use:** Creating, reviewing, or improving Helm charts
- **Purpose:** Production-quality Helm chart development following Helm 3 standards
- **Expertise:** Templating, values structure, dependency management, security best practices
- **Tools:** All tools

**mcp-security-validator**
- **When to use:** **MANDATORY** before installing, configuring, or recommending ANY MCP server
- **Purpose:** Validates MCP servers for security issues before addition to Claude Code
- **Process:** Checks Backslash Security Hub, Snyk Advisor, known threats
- **Tools:** All tools

**plugin-dev:plugin-validator**
- **When to use:** After creating or modifying plugin components
- **Purpose:** Validates plugin structure, plugin.json, and plugin files
- **Tools:** Read, grep, glob, bash

**shell-code-optimizer**
- **When to use:** Writing, reviewing, or improving shell scripts
- **Purpose:** Ensures portability, simplicity, shellcheck compliance, cross-platform compatibility
- **Focus:** Linux/macOS compatibility, built-in commands, best practices
- **Tools:** All tools

#### Documentation & Content Agents

**markdown-writer**
- **When to use:** Creating, editing, or improving Markdown documents
- **Purpose:** Proper formatting, style compliance, professional tone
- **Compliance:** Ensures markdownlint compliance, avoids excessive emoji
- **Use cases:** Documentation, README files, technical guides
- **Tools:** Edit, write, read, web search

#### Development Workflow Agents

**superpowers:code-reviewer**
- **When to use:** After completing major project steps against original plan
- **Purpose:** Reviews implementation against plan and coding standards
- **Trigger:** Completing logical chunks of work or numbered steps from planning
- **Tools:** All tools

**agent-sdk-dev:agent-sdk-verifier-ts**
- **When to use:** After TypeScript Agent SDK app created or modified
- **Purpose:** Verifies proper SDK configuration, follows best practices, ready for deployment
- **Tools:** All tools

**agent-sdk-dev:agent-sdk-verifier-py**
- **When to use:** After Python Agent SDK app created or modified
- **Purpose:** Verifies proper SDK configuration, follows best practices, ready for deployment
- **Tools:** All tools

### Agent Selection Guidelines

**For codebase exploration:**
- Use `Explore` agent with appropriate thoroughness level
- Use `feature-dev:code-explorer` for deep architectural understanding

**For new feature development:**
1. `feature-dev:code-architect` - Design the architecture
2. Implement the feature
3. `feature-dev:code-reviewer` - Review for bugs and quality
4. `pr-review-toolkit:code-reviewer` - Review against project standards
5. `claudemd-compliance-checker` - Verify CLAUDE.md compliance

**For Helm chart work:**
1. `helm-chart-developer` - Develop or review charts
2. `yaml-kubernetes-validator` - Validate YAML structure
3. `claudemd-compliance-checker` - Verify project compliance

**For shell scripts:**
1. Write or modify script
2. `shell-code-optimizer` - Review and improve
3. `claudemd-compliance-checker` - Verify compliance

**For MCP servers:**
1. **MANDATORY:** `mcp-security-validator` - Security validation
2. Only proceed with installation if approved
3. `claudemd-compliance-checker` - Verify compliance

### Default Agent Invocation

When uncertain which agent to use:
1. Check available agents list above
2. Use `Explore` agent for general codebase questions
3. Use `claudemd-compliance-checker` as final quality gate for coding projects

## Workflow Integration

### Todo List Structure

Every coding project todo list MUST end with:
```
- [pending] Verify CLAUDE.md compliance using claudemd-compliance-checker
```

For system maintenance tasks (file reorganization, yadm syncing, package installation), the compliance check is optional.

### Quality Gates (for coding projects)

- **Before commits:** Run `pr-review-toolkit:code-reviewer`
- **After features:** Run `feature-dev:code-reviewer` or `superpowers:code-reviewer`
- **Before PRs:** Run `pr-review-toolkit:pr-test-analyzer` for test coverage
- **Final step:** Run `claudemd-compliance-checker`

These quality gates do not apply to system maintenance tasks.

### Progressive Agent Usage (for coding projects)

1. **Exploration phase:** Use `Explore` or `feature-dev:code-explorer`
2. **Design phase:** Use `feature-dev:code-architect`
3. **Implementation phase:** Write code
4. **Review phase:** Use relevant quality control agents
5. **Compliance phase:** Use `claudemd-compliance-checker`

## Settings Configuration

**All permissions and settings changes go directly to `~/.claude/settings.json`.**

This is a personal configuration that will never be shared outside this workstation, so there is no need for a separate `settings.local.json` file. The local settings file pattern exists for shared projects where you want machine-specific overrides - that doesn't apply here.

When adding new permissions or modifying settings:
1. Edit `~/.claude/settings.json` directly
2. Sync with yadm after changes

## Configuration Management & Maintenance

### Plugin and Marketplace Updates

When plugins, marketplaces, or configurations are added/modified:

1. **Update documentation:** Always update `~/.claude/README.md` with:
   - New marketplaces in the "Installed Marketplaces" section
   - New plugins in the "Installed & Enabled Plugins" section
   - Updated setup instructions if workflow changes

2. **Synchronize with yadm:**
   ```bash
   yadm add ~/.claude/README.md
   yadm add ~/.claude/plugins/config.json
   yadm add ~/.claude/plugins/installed_plugins.json
   yadm add ~/.claude/plugins/known_marketplaces.json
   yadm add ~/.claude/settings.json  # if modified
   yadm commit -m "Update plugin configuration"
   yadm push
   ```

3. **Track custom configurations:**
   - Custom agents: `~/.claude/agents/*.md`
   - Custom skills: `~/.claude/skills/*/`
   - Hookify rules: `~/.claude/hookify.*.local.md`
   - Custom hooks: `~/.claude/hooks/*`

### Configuration Change Workflow

When user requests plugin/marketplace/config updates:

1. Perform the requested changes
2. Update `~/.claude/README.md` to reflect current state
3. Use yadm to commit and sync changes
4. Confirm synchronization complete

### What to Track vs. Not Track

**Always track (commit to yadm):**
- README.md (documentation)
- settings.json (user preferences)
- plugins/config.json (plugin system config)
- plugins/installed_plugins.json (plugin registry)
- plugins/known_marketplaces.json (marketplace registry)
- Custom agents, skills, hooks, hookify rules

**Never track (local only):**
- plugins/cache/ (regenerated)
- plugins/marketplaces/ (cloned from remote)
- file-history/ (session-specific)
- projects/ (machine-specific paths)
- debug/ (temporary logs)
- NEVER attempt to change or suggest changing the public/private flag on a github repo (or any other git repo in a hosted environment, such as BitBucket, etc.)

### Personal Plugin Repository: devops-toolkit

**Location:** `~/.claude/plugins/repos/devops-toolkit`
**Remote:** `git@github.com:adamancini/devops-toolkit.git`

The devops-toolkit plugin is a personal plugin repository that must be kept in sync across workstations.

**MANDATORY: Sync devops-toolkit in these scenarios:**

1. **After modifying agents or skills** in devops-toolkit:
   ```bash
   cd ~/.claude/plugins/repos/devops-toolkit
   git add -A && git commit -m "Update [component]: [description]"
   git push origin main
   ```

2. **During automatic Claude Code binary updates:**
   ```bash
   cd ~/.claude/plugins/repos/devops-toolkit
   git fetch origin
   git pull --rebase origin main  # Pull any upstream changes
   git push origin main           # Push any local changes
   ```

3. **During automatic plugin updates:**
   ```bash
   cd ~/.claude/plugins/repos/devops-toolkit
   git fetch origin
   git status  # Check for divergence
   git pull --rebase origin main
   git push origin main
   ```

**Sync Workflow:**
1. Check for uncommitted local changes
2. Fetch remote changes
3. Rebase local changes on top of remote (if any)
4. Push to ensure remote is up to date
5. Verify sync status: `git status` should show "up to date with origin/main"

**Current Skills:**
- `ssl-cert-manager` - SSL/TLS certificate management with Let's Encrypt
- `aerospace-config-manager` - AeroSpace window manager configuration