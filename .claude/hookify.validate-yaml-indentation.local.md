---
name: validate-yaml-indentation
enabled: true
event: file
tool_matcher: Edit|Write|MultiEdit
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.(yaml|yml)$
  - field: new_text
    operator: regex_match
    pattern: ^\t|  \t| \t
action: warn
---

⚠️ **YAML Indentation Issue Detected**

Your YAML file appears to have inconsistent indentation (tabs or mixed tabs/spaces).

**Your project standard (from CLAUDE.md):**
> 2-space indentation consistently

**Common YAML indentation errors:**
- Using tabs instead of spaces
- Mixing tabs and spaces
- Using 4 spaces instead of 2
- Inconsistent nesting levels

**Why this matters for Helm/Kubernetes:**
- YAML parsers may fail with tab characters
- Helm template rendering can break
- kubectl apply will reject malformed YAML
- yamllint will flag these as errors

**How to fix:**
1. Replace all tabs with 2 spaces
2. Ensure consistent 2-space indentation throughout
3. Run `yamllint` to validate

**Quick fix:**
```bash
# Replace tabs with 2 spaces in YAML file
sed -i '' 's/\t/  /g' path/to/file.yaml
```

**Recommended validators:**
- `make yamllint` (in helm/ directory)
- `yaml-kubernetes-validator` agent
- VS Code YAML extension
