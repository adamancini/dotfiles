---
name: block-direct-yadm
enabled: true
event: bash
pattern: ^yadm\s+
action: block
---

**BLOCKED: Direct yadm command detected**

Per CLAUDE.md guidelines, all yadm/dotfiles operations must be delegated to the `home-manager` agent.

Instead of running yadm directly, use:
```
Task(subagent_type="home-manager", prompt="[describe what you need to do with yadm]")
```

The home-manager agent will handle:
- yadm status, diff, add, commit, push
- Dotfile synchronization
- Shell configuration changes
- Repository organization

This ensures consistent handling of home directory configuration across all contexts.
