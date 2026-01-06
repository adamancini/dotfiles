---
name: block-direct-linear-mcp
enabled: true
event: all
pattern: mcp__plugin_linear_linear__|plugin:linear:linear
action: block
---

**BLOCKED: Direct Linear MCP tool usage detected**

Linear MCP tools must only be used through the `linear-assistant` agent to preserve main context.

If the linear-assistant agent failed, do NOT fall back to direct MCP calls. Instead:

1. Report the agent failure to the user
2. Ask if they want to retry or troubleshoot
3. Let the user decide how to proceed

**Never pollute the main context with verbose Linear API responses.**

To use Linear, always delegate:
```
Task(subagent_type="linear-assistant", prompt="[your Linear query]")
```
