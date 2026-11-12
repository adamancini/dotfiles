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

Credentials live in `pass`, but Claude never runs `pass`, `gpg` or reads `~/.password-store` directly. Get secrets through `pass-exec`, which asks pass-broker (a launchd agent). The broker shows the user a native dialog naming the entry, the reason and the command, and only fetches the secret if they approve. A cold GPG cache triggers the normal pinentry-mac prompt; no pre-unlock is needed.

```bash
# Secret goes into the child's env or a temp file, never into the transcript
pass-exec -r "why" --env TOKEN=fleet-infra/annarchy.net/foo -- curl -H "Authorization: Bearer $TOKEN" ...
pass-exec -r "why" --file KUBECONFIG=fleet-infra/annarchy.net/kubeconfig -- kubectl get nodes
pass-exec -r "why" --env-all VAR=entry -- cmd    # whole entry, not just line 1
```

- Always pass `-r` with a concrete reason; the user decides from it.
- Never echo, print or log a secret from the child command. `--show` prints to stdout; use it only if the user asks.
- Only entries under prefixes in `~/.config/pass-broker/allowlist` (currently `fleet-infra/`) can be requested. Anything else is rejected without a dialog; ask the user to extend the allowlist instead of working around it.
- If the user denies or the dialog times out, stop and ask. Do not retry in a loop.
- Find entry names with `ls ~/.password-store/<prefix>` (names only).
- Audit log: `~/.local/state/pass-broker/audit.log`. Broker setup: `~/.config/yadm/bootstrap.d/45-pass-broker.sh`.
