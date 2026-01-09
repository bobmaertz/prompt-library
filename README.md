# Prompt Library

A centralized, dotfiles-style repository for AI/LLM development resources. Manage your Claude Code skills, slash commands, hooks, prompts, and Cursor rules in one place, synced across all your machines using symbolic links.

## Features

- 🔗 **Symlink-based installation** - Changes sync bidirectionally between your workspace and repository
- 🤖 **Multi-tool support** - Works with both Claude Code and Cursor
- 🚀 **Easy setup** - One command to install across all your machines
- 📦 **Organized structure** - Separate directories for different resource types
- 🔄 **Version controlled** - Track changes to your AI configurations with git
- 🛡️ **Safe installation** - Automatically backs up existing files

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/prompt-library.git ~/.prompt-library
cd ~/.prompt-library

# Run the installer
./scripts/install.sh
```

The installer will create symbolic links from your Claude Code and Cursor configuration directories to this repository.

### Uninstallation

```bash
cd ~/.prompt-library
./scripts/uninstall.sh
```

This removes only the symbolic links, preserving any backup files created during installation.

## Directory Structure

```
prompt-library/
├── claude/                     # Claude Code resources
│   ├── skills/                # Reusable skills
│   │   └── git-worktree-manager/
│   ├── commands/              # Slash commands
│   │   └── review.md
│   ├── hooks/                 # Event hooks
│   │   └── pre-commit.md
│   └── prompts/               # System prompts
│       └── best-practices.md
│
├── cursor/                    # Cursor resources
│   ├── rules/                 # .cursorrules files
│   │   └── default.cursorrules
│   └── prompts/               # Cursor-specific prompts
│
├── shared/                    # Shared resources
│   ├── prompts/              # Universal prompts
│   ├── templates/            # Code templates
│   └── docs/                 # Documentation
│
├── scripts/                   # Installation scripts
│   ├── install.sh            # Symlink installer
│   └── uninstall.sh          # Symlink remover
│
└── resources/                 # Legacy structure (will be migrated)
```

## Configuration Paths

The installer uses these default paths:

**Claude Code:**
- Skills: `~/.config/claude/skills/`
- Commands: `~/.config/claude/commands/`
- Hooks: `~/.config/claude/hooks/`
- Prompts: `~/.config/claude/prompts/`

**Cursor:**
- Rules: `~/.cursor/rules/`
- Prompts: `~/.cursor/prompts/`

You can override these by setting environment variables:
```bash
export CLAUDE_CONFIG_DIR="$HOME/.config/claude-custom"
export CURSOR_CONFIG_DIR="$HOME/.cursor-custom"
./scripts/install.sh
```

## Usage

### Making Changes

Since the installation uses symbolic links, you can edit files in either location:

**Option 1: Edit in the repository**
```bash
cd ~/.prompt-library/claude/commands
vim review.md
git add -A
git commit -m "Update review command"
git push
```

**Option 2: Edit in your config directory**
```bash
cd ~/.config/claude/commands
vim review.md  # This actually edits ~/.prompt-library/claude/commands/review.md
cd ~/.prompt-library
git add -A
git commit -m "Update review command"
git push
```

### Adding New Resources

#### Claude Code Skill

```bash
cd ~/.prompt-library/claude/skills
mkdir my-new-skill
cd my-new-skill
cat > SKILL.md << 'EOF'
---
name: my-new-skill
description: Description of what this skill does
---

# My New Skill

Skill content here...
EOF

# The skill is immediately available in Claude Code
```

#### Slash Command

```bash
cd ~/.prompt-library/claude/commands
cat > deploy.md << 'EOF'
---
description: Deploy the application to production
---

Deploy steps:
1. Run tests
2. Build production bundle
3. Deploy to server
EOF
```

#### Cursor Rule

```bash
cd ~/.prompt-library/cursor/rules
cat > python.cursorrules << 'EOF'
# Python-specific rules
- Follow PEP 8 style guide
- Use type hints
- Write docstrings for all public functions
EOF
```

### Syncing Across Machines

On a new machine:
```bash
git clone https://github.com/yourusername/prompt-library.git ~/.prompt-library
cd ~/.prompt-library
./scripts/install.sh
```

Your configurations are now identical across all machines. Any changes you make will be synced via git.

## Resource Types

### Claude Code Resources

#### Skills
Reusable skill definitions that Claude can invoke. Skills should include:
- `SKILL.md` with frontmatter (name, description)
- Any supporting scripts or files
- Clear documentation of usage

**Example:** `claude/skills/git-worktree-manager/`

#### Slash Commands
Custom commands that expand prompts when invoked with `/command-name`.

**Format:**
```markdown
---
description: Brief description of the command
---

Command prompt content here...
```

**Example:** `claude/commands/review.md` → `/review`

#### Hooks
Event-triggered prompts that run on specific events.

**Supported events:**
- `pre-commit` - Before creating a git commit
- `post-commit` - After creating a git commit
- Other Claude Code hook events

#### Prompts
Reusable prompt templates and system prompts.

### Cursor Resources

#### Rules
`.cursorrules` files that define Cursor's behavior and coding standards.

These can be:
- General rules (`default.cursorrules`)
- Language-specific (`python.cursorrules`, `typescript.cursorrules`)
- Project-type specific (`web.cursorrules`, `api.cursorrules`)

#### Prompts
Cursor-specific prompt templates.

### Shared Resources

Place universal resources in `shared/` to avoid duplication:
- Coding standards documents
- Architecture decision records
- Common prompt templates
- Code snippets and templates

## Best Practices

### Organization

1. **Use descriptive names** - `review-code.md` not `rc.md`
2. **Group related resources** - Keep skills with their scripts and docs
3. **Document everything** - Add clear descriptions and usage examples
4. **Version control** - Commit regularly with descriptive messages

### Workflow

1. **Test locally first** - Try new prompts/skills before committing
2. **Commit atomically** - One logical change per commit
3. **Write clear commit messages** - Describe what changed and why
4. **Pull before push** - Keep synced across machines

### Security

⚠️ **Never commit:**
- API keys or credentials
- Personal information
- Project-specific secrets
- Large binary files

Use `.gitignore` for sensitive files:
```gitignore
# Sensitive
*.key
*.pem
secrets.md

# Machine-specific
local.md
*.local
```

## Advanced Usage

### Custom Install Locations

Override default paths:
```bash
export CLAUDE_CONFIG_DIR="/custom/path/claude"
export CURSOR_CONFIG_DIR="/custom/path/cursor"
./scripts/install.sh
```

### Selective Installation

Manually symlink specific resources:
```bash
# Install only specific skills
ln -s ~/.prompt-library/claude/skills/git-worktree-manager \
      ~/.config/claude/skills/git-worktree-manager

# Install only specific commands
ln -s ~/.prompt-library/claude/commands/review.md \
      ~/.config/claude/commands/review.md
```

### Multiple Machines with Different Configs

Use branches for machine-specific variations:
```bash
# On machine 1
git checkout -b machine-work
# Add work-specific prompts
git add claude/prompts/work-specific.md
git commit -m "Add work-specific prompts"

# On machine 2 (personal)
git checkout main
# Only has shared prompts
```

Or use git sparse-checkout for selective syncing.

## Migrating Existing Configurations

If you already have Claude or Cursor configurations:

1. **Backup your existing configs:**
   ```bash
   cp -r ~/.config/claude ~/.config/claude.backup
   cp -r ~/.cursor ~/.cursor.backup
   ```

2. **Copy your existing resources to the repository:**
   ```bash
   cp -r ~/.config/claude/skills/* ~/.prompt-library/claude/skills/
   cp -r ~/.config/claude/commands/* ~/.prompt-library/claude/commands/
   # etc...
   ```

3. **Commit to the repository:**
   ```bash
   cd ~/.prompt-library
   git add -A
   git commit -m "Import existing configurations"
   git push
   ```

4. **Run the installer:**
   ```bash
   ./scripts/install.sh
   ```

   The installer will backup your existing files before creating symlinks.

## Troubleshooting

### Symlinks not working

Check if symlinks were created:
```bash
ls -la ~/.config/claude/skills
```

You should see `->` arrows pointing to your prompt library.

### Changes not syncing

Verify you're editing the symlinked files:
```bash
readlink ~/.config/claude/commands/review.md
# Should output: /path/to/prompt-library/claude/commands/review.md
```

### Installer fails

Check permissions:
```bash
ls -la ~/.config/claude
# Ensure you own these directories
```

### Git conflicts

If you edit on multiple machines without pulling:
```bash
cd ~/.prompt-library
git pull --rebase
# Resolve any conflicts
git push
```

## Future Enhancements

### Planned Features

- 🎯 **Unified prompts** - Single prompt format that works in both Claude and Cursor
- 📋 **Template system** - Project scaffolding templates
- 🔍 **Prompt testing** - Validate prompts before committing
- 🏷️ **Tagging system** - Organize resources by topic/project
- 🌐 **Shared prompt registry** - Import community prompts
- 🔧 **Configuration validator** - Check for common issues

### Contributing

Contributions welcome! To add new example resources:

1. Fork this repository
2. Add your resources to the appropriate directory
3. Update documentation
4. Submit a pull request

## Examples

See the included example resources:
- **Claude Skills:** `claude/skills/git-worktree-manager/`
- **Claude Commands:** `claude/commands/review.md`
- **Claude Hooks:** `claude/hooks/pre-commit.md`
- **Cursor Rules:** `cursor/rules/default.cursorrules`
- **Shared Prompts:** `claude/prompts/best-practices.md`

## License

MIT License - feel free to use and modify for your own purposes.

## Acknowledgments

Inspired by dotfiles management tools and the growing ecosystem of AI-assisted development tools.

---

**Happy prompting! 🚀**

For issues or questions, please open an issue on GitHub.
