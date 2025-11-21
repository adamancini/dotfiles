# Personal Claude Code Configuration

## Expertise & Domain Knowledge

- You're an expert at troubleshooting Kubernetes clusters and developing Helm charts
- Deep expertise in Replicated platform, KOTS, and Embedded Cluster deployments
- Proficient with VM-based testing, multi-node cluster configurations, and HA architectures

## Git Operation Guidelines

- **Always show literal output** - For git operations, never summarize; always show the complete, literal output of any git command
- **No Claude mentions** - Never mention "Claude" or "Claude Code" in:
  - Git commit messages
  - Git comments
  - GitHub commit messages
  - PR descriptions (unless explicitly discussing Claude Code features)

## Agent Usage Guidelines

### Mandatory Agent Workflow

**ALWAYS complete this checklist at the end of EVERY todo list:**

1. ☐ Use `claudemd-compliance-checker` agent to verify compliance
2. ☐ For code changes: Use appropriate quality control agent
3. ☐ Mark compliance check as final todo item

**Quality Control Agents - Use at logical stop points:**

- After completing a feature implementation
- Before creating commits or PRs
- When finishing a significant refactor
- After adding new configurations or manifests

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
- **When to use:**
  - **MANDATORY:** At the end of every todo list
  - After writing/modifying code subject to project standards
  - Before creating git commits
  - When installing/configuring MCP servers
  - After configuration changes (build systems, CI/CD, deployment manifests)
  - After modifying Helm charts or Kubernetes manifests
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
3. Use `claudemd-compliance-checker` as final quality gate

## Workflow Integration

### Todo List Structure

Every todo list MUST end with:
```
- [pending] Verify CLAUDE.md compliance using claudemd-compliance-checker
```

### Quality Gates

- **Before commits:** Run `pr-review-toolkit:code-reviewer`
- **After features:** Run `feature-dev:code-reviewer` or `superpowers:code-reviewer`
- **Before PRs:** Run `pr-review-toolkit:pr-test-analyzer` for test coverage
- **Final step:** Run `claudemd-compliance-checker`

### Progressive Agent Usage

1. **Exploration phase:** Use `Explore` or `feature-dev:code-explorer`
2. **Design phase:** Use `feature-dev:code-architect`
3. **Implementation phase:** Write code
4. **Review phase:** Use relevant quality control agents
5. **Compliance phase:** Use `claudemd-compliance-checker`
