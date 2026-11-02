# AWS Guidance

## SSO Login Precheck (AWS MCP)

- The AWS MCP Server needs an active `aws sso login` session before its
  tools load and work correctly.
- Before the first AWS MCP call in a session, check the session with a
  cheap identity call (`run_script` with STS `GetCallerIdentity`).
- If that call fails with an expired-token, SSO or credential error, or
  the AWS MCP tools did not load (for example `aws-mcp` failed to connect
  with `-32602`), stop. Ask the user to run `! aws sso login` (add
  `--profile <name>` if a profile is in use), then reconnect with `/mcp`.
  Do not retry the AWS call until they confirm.

- Prefer the AWS MCP Server for AWS interactions — it provides sandboxed
  execution, observability, and audit logging. If unavailable, use the
  AWS CLI directly.
- Before starting a task, check whether a relevant AWS skill is available.
  Load the skill with `retrieve_skill` and prefer its guidance over
  general knowledge.
- When uncertain about specific AWS details (API parameters, permissions,
  limits, error codes), verify against documentation rather than guessing.
  State uncertainty explicitly if you cannot confirm.
- When creating infrastructure, prefer infrastructure-as-code (AWS CDK or
  CloudFormation) over direct CLI commands.
- When working with infrastructure, follow AWS Well-Architected Framework
  principles.
- Do not use em dashes in AWS resource names or descriptions. Use
  hyphens instead.

## Secret Safety

- MUST load the `aws-secrets-manager` skill first for any secret,
  credential, API key, token, or password task. MUST NOT call
  `secretsmanager get-secret-value` or `batch-get-secret-value`, and MUST
  NOT hit the Secrets Manager Agent daemon directly. MUST use
  `{{resolve:secretsmanager:secret-id:SecretString:json-key}}` with
  `asm-exec` so the secret resolves at runtime without entering context.
