---
name: validate-helm-templates
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: (^|/)helm/.*\.(yaml|yml)$|(^|/)charts/.*\.(yaml|yml)$|Chart\.yaml$|values.*\.yaml$
action: warn
---

📋 **Helm Chart Changes Detected - Validation Checklist**

Before marking this work as complete, validate your Helm chart changes:

**Required validations:**

```bash
# 1. Lint the chart with subcharts
make chef-platform-helm-lint

# Or directly:
helm lint ./chef-platform --with-subcharts

# 2. Validate YAML syntax and rendering
make yamllint

# 3. Test template rendering (dry-run)
helm template chef-platform . --dry-run

# 4. Update dependencies if Chart.yaml changed
make chef-platform-helm-dependency-update
```

**Common Helm template errors to check:**
- [ ] Missing required template helpers (`.name`, `.fullname`, `.labels`)
- [ ] Incorrect value references ({{ .Values.serviceName }} vs {{ .Values.servicename }})
- [ ] Unclosed template blocks (missing `{{- end }}`)
- [ ] Improper quoting (use `{{ .Values.value | quote }}` for special chars)
- [ ] Resource naming consistency (`{{ .Release.Name }}-{{ .Values.servicename }}-resource`)

**Your project standards (from CLAUDE.md):**
- Snake_case for values hierarchy
- SCREAMING_SNAKE_CASE for environment variables with `CHEF_` prefix
- 2-space indentation consistently
- Kebab-case for file names

**Working directory:**
- Helm commands should run from `helm/` directory
- Change directory if needed: `cd helm && make chef-platform-helm-lint`

**Specialized agents available:**
- `helm-chart-developer` - For chart review and improvements
- `yaml-kubernetes-validator` - For YAML validation
- `claudemd-compliance-checker` - For project standards compliance
