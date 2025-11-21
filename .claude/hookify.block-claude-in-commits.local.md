---
name: block-claude-in-commits
enabled: true
event: bash
pattern: git\s+commit.*(-m|--message).*[Cc]laude
action: block
---

🚫 **Git commit mentions "Claude"**

Your CLAUDE.md explicitly states:
> Never mention "Claude" or "Claude Code" in git commit messages or comments

**Why this matters:**
- Commit messages should describe *what* changed, not *who* made the change
- AI assistance should be invisible in version control history
- Professional commit logs don't reference tooling

**How to fix:**
Rewrite your commit message to focus on the change itself:
- ❌ "Claude added user authentication"
- ✅ "Add user authentication system"

- ❌ "Fixed bug with Claude Code's help"
- ✅ "Fix null pointer exception in auth handler"
