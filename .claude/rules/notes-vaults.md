# Personal Knowledge Vaults

Two Obsidian vaults. Use `vlt` CLI directly via Bash for all vault operations.
For complex workflows, invoke the `vlt-skill`.

## Vault Inventory

| Vault name | Path | Purpose |
|------------|------|---------|
| `Claude` | `~/Claude` | Work knowledge graph: decisions, patterns, project context (paivot-graph) |
| `notes` | `~/notes` | Personal vault: journal, research, reference, life planning |

## Claude Vault Layout (`~/Claude`)

Follows paivot-shared-vault-pattern with structured frontmatter.

| Folder | Type tag | What lives here |
|--------|----------|----------------|
| `_inbox/` | varies | Quick captures before triage |
| `concepts/` | `concept` | Language, tool, and framework knowledge |
| `conventions/` | `convention` | Coding standards, team agreements |
| `decisions/` | `decision` | ADRs — why X was chosen over Y |
| `debug/` | `debug` | Bug investigations with root cause |
| `methodology/` | `methodology` | Process and workflow guides |
| `patterns/` | `pattern` | Reusable solutions that worked |
| `projects/` | `project` | One index note per project |

### Search by type
```bash
vlt vault="Claude" search query="[type:decision] [project:clew]"
vlt vault="Claude" search query="[type:pattern] [status:active]"
vlt vault="Claude" search query="[type:project]"
```

## notes Vault Layout (`~/notes`)

| Folder | What lives here |
|--------|----------------|
| `journal/` | Daily notes |
| `personal/` | Personal notes |
| `reference/` | Reference material |
| `research/` | Research notes |
| MOC files | Learning-MOC, Life-MOC, Projects-MOC, Work-MOC |

## Common Operations

```bash
# Read a note
vlt vault="Claude" read file="clew"

# Search for a topic
vlt vault="Claude" search query="Traefik"

# Capture a decision
vlt vault="Claude" create name="My Decision" path="decisions/My Decision.md" \
  content="---\ntype: decision\nproject: foo\nstatus: active\ncreated: $(date +%F)\n---\n# ..." silent timestamps

# Append session notes to a project
vlt vault="Claude" append file="projects/clew" content="## Session $(date +%F)\n..."

# List projects
vlt vault="Claude" files folder="projects"
```

## Secrets

Use `pass` for all credentials. Delegate complex keyring operations to `home-manager` agent.
```bash
pass show <key>          # Read a secret
pass ls                  # List available secrets
```
