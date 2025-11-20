#!/usr/bin/env python3
"""
UserPromptSubmit Hook: MCP Security Reminder with Fallback

This hook detects when users mention adding MCP servers and provides
security guidance. It operates in two modes:

1. If mcp-security-validator agent is available: Directs user to use it
2. If agent is not available: Performs basic security check and provides
   manual validation guidance + instructions to get the agent installed
"""

import json
import sys
import re
import os

# Known malicious packages (blocklist)
BLOCKLIST = [
    'postmark-mcp',
    '@postmark/mcp',
]

def agent_exists():
    """Check if mcp-security-validator agent is installed"""
    agent_paths = [
        os.path.expanduser("~/.claude/agents/mcp-security-validator.md"),
        os.path.join(os.getcwd(), ".claude/agents/mcp-security-validator.md"),
    ]

    # Check if CLAUDE_PROJECT_DIR is available
    project_dir = os.environ.get('CLAUDE_PROJECT_DIR')
    if project_dir:
        agent_paths.append(os.path.join(project_dir, ".claude/agents/mcp-security-validator.md"))

    return any(os.path.exists(path) for path in agent_paths)

def extract_package_name(prompt):
    """Try to extract package name from the prompt"""
    patterns = [
        r'@[\w-]+/[\w-]+',  # Scoped packages
        r'\b[\w-]+-mcp\b',  # Packages ending in -mcp
        r'\bmcp-[\w-]+\b',  # Packages starting with mcp-
    ]

    for pattern in patterns:
        match = re.search(pattern, prompt, re.IGNORECASE)
        if match:
            return match.group(0)
    return None

def check_blocklist(package_name):
    """Check if package is on the known blocklist"""
    if not package_name:
        return False
    package_lower = package_name.lower()
    return any(blocked.lower() in package_lower for blocked in BLOCKLIST)

def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    prompt = input_data.get("prompt", "")

    # MCP pattern detection
    mcp_patterns = [
        r'\badd\s+mcp\s+(server|package)',
        r'\binstall\s+mcp\s+(server|package)',
        r'\buse\s+mcp\s+(server|package)',
        r'\bclaude\s+mcp\s+add\b',
        r'\bnpx\s+-y\s+@',
        r'\bnpm\s+install.*mcp',
        r'@modelcontextprotocol/',
        r'@[\w-]+/[\w-]+.*server',
        r'[\w-]+-mcp\b',
        r'\bmcp-[\w-]+\b',
        r'\.claude/mcp\.json',
        r'\bmcp\.json\b',
        r'mcpServers',
        r'\bi want to add\s+@?[\w-]+',
        r'\bcan i add\s+@?[\w-]+',
        r'\bhow do i add\s+@?[\w-]+',
    ]

    matched = False
    for pattern in mcp_patterns:
        if re.search(pattern, prompt, re.IGNORECASE):
            matched = True
            break

    if matched:
        has_agent = agent_exists()

        if has_agent:
            reminder = (
                "� Security Reminder: Before adding MCP servers, validate them for security risks.\n\n"
                "Use the security validator agent:\n"
                "  @mcp-security-validator I want to add [package-name]\n\n"
                "Or use the convenient slash command:\n"
                "  /add-mcp [package-name]\n\n"
                "This ensures MCP servers are checked against the Backslash Security Hub "
                "and known threat databases before installation."
            )
        else:
            package_name = extract_package_name(prompt)
            is_blocked = check_blocklist(package_name)

            if is_blocked:
                reminder = (
                    f"� SECURITY ALERT: The package '{package_name}' is KNOWN MALICIOUS!\n\n"
                    "❌ DO NOT INSTALL THIS PACKAGE\n\n"
                    "This package contains a backdoor that exfiltrates sensitive data including:\n"
                    "- Passwords and MFA codes\n"
                    "- API keys and tokens\n"
                    "- Confidential communications\n\n"
                    "If you need MCP server functionality, use official packages:\n"
                    "  @modelcontextprotocol/server-*\n\n"
                    "⚠️ Note: The mcp-security-validator agent is not installed on your system.\n"
                    "For automated security validation, ask in #security how to get it installed."
                )
            else:
                blocklist_warning = ""
                if package_name:
                    blocklist_warning = f"\n⚠️ Note: Quick check shows '{package_name}' is not on the known malicious list, but this does NOT mean it's safe.\n"

                reminder = (
                    "� Security Reminder: Before adding MCP servers, validate them for security risks.\n"
                    f"{blocklist_warning}\n"
                    "⚠️ The mcp-security-validator agent is NOT installed on your system.\n\n"
                    "Please perform manual validation:\n\n"
                    "1. Check Backslash MCP Security Hub:\n"
                    "   https://mcp.backslash.security/\n\n"
                    "2. Check Snyk Advisor for package health:\n"
                    "   https://snyk.io/advisor/\n\n"
                    "3. Review the package on npm and GitHub:\n"
                    "   - Verify publisher authenticity\n"
                    "   - Check for recent activity and community trust\n"
                    "   - Look for security advisories or CVEs\n\n"
                    "4. Prefer official @modelcontextprotocol/* packages from Anthropic\n\n"
                    "5. When in doubt, ask in #security on Slack\n\n"
                    "� To get automated security validation:\n"
                    "   Ask in #security how to install the mcp-security-validator agent"
                )

        # For UserPromptSubmit hooks, just print to stdout
        # The output will be injected into Claude's context
        print(reminder)
        sys.exit(0)

    # No MCP patterns detected
    sys.exit(0)

if __name__ == "__main__":
    main()
