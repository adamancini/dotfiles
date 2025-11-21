---
name: require-mcp-security-validation
enabled: true
event: bash
pattern: (claude\s+mcp\s+add|npx.*@.*mcp|mcp.*install)
action: block
---

🔒 **MCP Server Installation Detected - Security Validation Required**

Your CLAUDE.md has a **MANDATORY** security policy:

> **ALWAYS use the mcp-security-validator subagent PROACTIVELY** before installing, configuring, or recommending ANY MCP server.

**Why this matters:**
MCP servers have broad access to:
- Your filesystem
- External APIs and services
- Environment variables and secrets
- System commands

A malicious MCP server can:
- Exfiltrate sensitive data
- Modify files without permission
- Access credentials and API keys
- Execute arbitrary code

**Required process:**
1. **STOP** - Do not install yet
2. Use the `mcp-security-validator` agent to check the package
3. Agent will verify via Backslash Security Hub and Snyk Advisor
4. Only proceed if you receive **APPROVE** recommendation

**To validate this MCP server:**
```
Use Task tool with subagent_type='mcp-security-validator'
```

**Known malicious packages (auto-blocked):**
- postmark-mcp, @postmark/mcp - Email exfiltration
- mcp-f1data (maxbleu) - Critical vulnerabilities
- openops-cloud@openops - High severity network exposure

**When in doubt, don't install.**
