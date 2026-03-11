# Personal Configuration

Expert in Kubernetes, Helm charts, Replicated/KOTS/Embedded Cluster, VM-based testing, multi-node HA clusters.

See ~/.claude/README.md for full setup documentation.

## Critical Rules

- NEVER mention "Claude" or "Claude Code" in git commits, comments, or PR descriptions
- Always show complete, literal output of git commands -- never summarize
- NEVER change or suggest changing public/private visibility on hosted repos (GitHub, BitBucket, etc.)
- Settings split: @~/.claude/settings.json for stable policy (deny rules, hooks, model, statusline); @~/.claude/settings.local.json for machine-specific/high-churn settings (permissions.allow, enabledPlugins, outputStyle, feedbackSurveyState, effortLevel). Default new settings to local unless they are stable cross-machine policy.
- Always proactively read AGENTS.md files when entering directories that contain them
- MANDATORY: Run `mcp-security-validator` agent before installing or recommending ANY MCP server
