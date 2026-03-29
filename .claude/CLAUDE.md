# Personal Configuration

Expert in Kubernetes, Helm charts, Replicated/KOTS/Embedded Cluster, VM-based testing, multi-node HA clusters.

## Critical Rules

- NEVER change or suggest changing public/private visibility on hosted repos (GitHub, BitBucket, etc.)
- Always proactively read AGENTS.md files when entering directories that contain them
- MANDATORY: Run `mcp-security-validator` agent before installing or recommending ANY MCP server

## Personal Knowledge & Secrets

- `~/Claude` — work knowledge graph (decisions, patterns, projects); use `vlt vault="Claude"` via Bash
- `~/notes` — personal vault (journal, reference, research); use `vlt vault="notes"` via Bash
- Vault layout and `vlt` usage: see `~/.claude/rules/notes-vaults.md`; for complex workflows use `vlt-skill`
- Secrets/credentials: use `pass` keyring; delegate to `home-manager` agent for complex operations
