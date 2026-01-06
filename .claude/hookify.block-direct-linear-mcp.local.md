---
name: block-direct-linear-mcp
enabled: true
event: all
pattern: (mcp__plugin_linear|plugin:linear|linear.*get_issue|linear.*update_issue|linear.*search|linear.*create_issue|linear.*list)
action: block
---

**BLOCKED: Direct Linear MCP tool usage detected**

You are attempting to call Linear MCP tools directly. This is **PROHIBITED** by CLAUDE.md.

**WHY THIS IS BLOCKED:**
- Linear API responses are verbose JSON (often 30+ lines)
- Direct calls pollute the main context window
- The `linear-assistant` agent exists specifically to handle this

**WHAT TO DO INSTEAD:**

1. **ALWAYS** delegate to linear-assistant agent:
   ```
   Task(subagent_type="linear-assistant", prompt="[your Linear query]")
   ```

2. Even when another agent is requested for the main task (e.g., "use golang-pro"), Linear lookups MUST still go through linear-assistant FIRST

3. If linear-assistant fails, report the failure - do NOT fall back to direct MCP calls

**CORRECT WORKFLOW:**
- User: "Work on ANN-41 using golang-pro"
- You: First invoke linear-assistant to get issue details, THEN invoke golang-pro with those details

**This rule cannot be bypassed. Delegate to linear-assistant or ask the user for guidance.**
