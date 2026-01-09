# Claude Code Resources

This directory contains resources for Claude Code, the official CLI tool for Claude.

## Directory Structure

- **skills/** - Reusable skills that Claude can invoke during conversations
- **commands/** - Slash commands for quick prompt expansion
- **hooks/** - Event-triggered prompts (pre-commit, post-commit, etc.)
- **prompts/** - System prompts and reusable prompt templates

## Quick Reference

### Skills
Located in `skills/`, each skill should have:
- A directory with the skill name
- `SKILL.md` file with frontmatter containing name and description
- Any supporting scripts, templates, or documentation

Example:
```
skills/
  my-skill/
    SKILL.md
    scripts/
    README.md
```

### Slash Commands
Located in `commands/`, each command is a markdown file:
```markdown
---
description: Brief description
---

Your prompt here...
```

Invoke with: `/command-name`

### Hooks
Located in `hooks/`, event-triggered prompts:
```markdown
---
description: What the hook does
event: pre-commit
---

Hook instructions...
```

### Prompts
Located in `prompts/`, reusable prompt templates and system prompts that can be referenced in your Claude Code configuration.

## Adding Resources

1. Create your resource in the appropriate directory
2. Test it locally in Claude Code
3. Commit and push to sync across machines

## See Also

- Main README: `../README.md`
- Claude Code documentation: https://github.com/anthropics/claude-code
