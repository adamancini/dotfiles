---
name: validate-markdown
enabled: true
event: file
tool_matcher: Edit|Write|MultiEdit
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.md$
  - field: file_path
    operator: not_contains
    pattern: node_modules
action: warn
---

📝 **Markdown File Edit Detected - Validation Recommended**

**Recommended validation:**

```bash
# Run markdownlint on the file
markdownlint path/to/file.md

# Or use the markdown-writer agent
# (Use Task tool with subagent_type='markdown-writer')
```

**Common markdown linting issues:**
- [ ] Missing blank lines around headings
- [ ] Inconsistent list marker style (- vs * vs +)
- [ ] Trailing whitespace
- [ ] Missing blank line at end of file
- [ ] Inconsistent heading hierarchy (skipping levels)
- [ ] Bare URLs (should be in < > or [text](url))
- [ ] Improper code fence formatting

**Your project standards:**
- Professional tone without excessive emoji
- Markdownlint compliance required
- Clean, readable structure

**Available agent:**
- `markdown-writer` - Creates/edits/improves Markdown with proper formatting

**Common fixes:**
```bash
# Auto-fix many issues
markdownlint --fix path/to/file.md

# Check specific rules
markdownlint --config .markdownlint.json path/to/file.md
```

**When to skip this validation:**
- Generated documentation (auto-generated changelogs, etc.)
- Third-party files in node_modules or vendor directories
- Files explicitly excluded from linting
