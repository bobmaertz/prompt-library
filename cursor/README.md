# Cursor Resources

This directory contains resources for Cursor, the AI-powered code editor.

## Directory Structure

- **rules/** - `.cursorrules` files that define Cursor's behavior
- **prompts/** - Cursor-specific prompt templates

## Quick Reference

### Rules
Located in `rules/`, these are `.cursorrules` files that configure how Cursor assists with code.

Types of rules:
- `default.cursorrules` - General coding standards
- `python.cursorrules` - Python-specific rules
- `typescript.cursorrules` - TypeScript-specific rules
- `web.cursorrules` - Web development rules
- etc.

Rules can include:
- Code style preferences
- Security guidelines
- Testing requirements
- Documentation standards
- AI assistance preferences

### Prompts
Located in `prompts/`, these are reusable prompt templates for Cursor.

## Using Rules in Projects

Cursor rules can be:
1. **Global** - Symlinked from this repository to `~/.cursor/rules/`
2. **Project-specific** - Copied to project root as `.cursorrules`

For project-specific usage:
```bash
cp ~/.cursor/rules/python.cursorrules /path/to/project/.cursorrules
```

## Adding Resources

1. Create your `.cursorrules` file in `rules/`
2. Test it in Cursor
3. Commit and push to sync across machines

## See Also

- Main README: `../README.md`
- Cursor documentation: https://cursor.sh/docs
