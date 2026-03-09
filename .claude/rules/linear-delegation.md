# Linear: Mandatory Delegation

CRITICAL: NEVER call Linear MCP tools directly. ALWAYS delegate to the `linear-assistant` agent. No exceptions.

- ALL Linear operations go through `linear-assistant`
- Multi-agent scenarios: invoke `linear-assistant` FIRST to get issue details, THEN pass to other agents
- On agent failure (0 tool uses): re-invoke with explicit action-oriented prompt, NEVER fall back to direct MCP calls
- Use explicit verbs in prompts: "Fetch", "Query", "Create", "Update" -- not vague "get info about"
