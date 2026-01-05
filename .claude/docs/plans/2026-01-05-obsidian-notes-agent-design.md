# Obsidian Notes Agent Design

**Date:** 2026-01-05
**Status:** Implemented

## Overview

Design for an `obsidian-notes` agent to manage the Obsidian vault at `~/notes/`. The agent provides full lifecycle management of notes including creation, discovery, organization, configuration, and AI optimization.

## Design Decisions

### Scope: Full Lifecycle Manager
- **Read-heavy operations:** Finding, organizing, cross-referencing existing notes
- **Write-heavy operations:** Creating notes from conversations, capturing content
- **Configuration management:** Plugin setup, troubleshooting, optimization

### Interaction Model: Hybrid File/API
- **Direct file access:** Always available for read/write/search operations
- **REST API integration:** When Obsidian running, enables live updates and plugin access
- **Graceful degradation:** Falls back to file operations if API unavailable

### Domain Handling: Context-Aware with Tags
- Agent infers work/personal domain from conversation context
- Places notes in appropriate directory (`/work/` or `/personal/`)
- Applies hierarchical tags (e.g., `#work/chef-360/architecture`)
- Confirms placement for ambiguous cases

### Template Strategy: Evolution
- Uses existing templates when they match
- Learns patterns from existing notes
- Suggests new templates for recurring note types
- Can refine existing templates when improvements identified

### MOC Maintenance: Automatic
- Automatically adds links to relevant MOCs when creating notes
- Updates domain indexes (`work/_index.md`, `personal/_index.md`)
- Can audit for orphans, dead links, tag inconsistencies

### Configuration Scope: Full Management
- Can configure Obsidian plugins
- Troubleshoots issues
- Suggests optimizations
- Manages hotkeys and settings

### AI Optimization: Comprehensive
- Semantic searchability via consistent frontmatter
- Context chunking with clear section boundaries
- Cross-reference density with wikilinks
- Structured data extraction via inline fields

### Agent Relationship: Peer with Delegation
- Independent peer to `home-manager` agent
- Can be invoked directly for any note task
- `home-manager` delegates note tasks to `obsidian-notes`
- Neither is subordinate; they reference each other

## Vault Structure

```
~/notes/
├── Index.md              # Central dashboard
├── work/                 # Work domain
│   └── _index.md
├── personal/             # Personal domain
│   └── _index.md
├── journal/              # Daily/monthly reflections
├── collections/          # Curated topic groupings
├── templates/            # Note templates
├── attachments/          # Media files
├── *-MOC.md             # Maps of Content
└── .obsidian/           # Obsidian configuration
```

## Frontmatter Schema

```yaml
---
tags:
  - work
  - work/chef-360/architecture
aliases:
  - Short Name
created: 2026-01-05
updated: 2026-01-05
status: active  # active | draft | archive
type: note      # note | meeting | reference | project
related:
  - "[[Related Note]]"
---
```

## Obsidian Knowledge

The agent is expert in:
- Obsidian-flavored markdown (callouts, highlights, comments)
- Internal linking (wikilinks, block refs, embeds)
- Aliases
- Bases (native database views, .base files, formulas)
- Plugin configuration (Dataview, Templater, Tasks, etc.)

## Documentation References

- https://help.obsidian.md/Editing+and+formatting/Obsidian+Flavored+Markdown
- https://help.obsidian.md/links
- https://help.obsidian.md/aliases
- https://help.obsidian.md/callouts
- https://help.obsidian.md/bases
- https://help.obsidian.md/bases/syntax

## Implementation

- Agent file: `~/.claude/agents/obsidian-notes.md`
- Home-manager updated with delegation reference
- Tracked via yadm
