# Claude Plugin Library

A collection of Claude Code plugins for everyday development workflows. Each plugin is self-contained with commands, skills, and hooks that extend Claude Code for a specific domain.

## Plugins

| Plugin | Description |
|--------|-------------|
| [`general`](plugins/general/) | Research, repo exploration, docs, code review, security review, and git workflow |
| [`backend`](plugins/backend/) | LSP server configuration and linter templates |

## Installation

### Native install (recommended)

First add this repository as a Claude Code marketplace, then install the plugins you want:

```bash
# Add this repo as a marketplace (one-time)
/plugin marketplace add https://github.com/bobmaertz/prompt-library

# Install plugins
claude plugin install general
claude plugin install backend

# Or install to project scope to share with your team
claude plugin install general --scope project
```

Uninstall with `claude plugin uninstall <name>`.

### Symlink install (for contributors)

If you want edits to sync back to the repository automatically, clone it and use the install script instead. This symlinks each plugin directory into the Claude Code plugin cache rather than copying it.

```bash
git clone https://github.com/bobmaertz/prompt-library.git ~/.claude-plugins
cd ~/.claude-plugins
./scripts/install.sh
```

| What | Where |
|------|-------|
| Plugin symlinks | `~/.claude/plugins/cache/<plugin-name>` |
| Settings entry | `~/.claude/settings.json` → `enabledPlugins` |

```bash
# Uninstall
./scripts/uninstall.sh

# Override the default ~/.claude path
CLAUDE_DIR=/custom/path ./scripts/install.sh
```

### Testing a single plugin without installing

```bash
claude --plugin-dir ./plugins/general
```

## Plugin Structure

Every plugin follows this layout:

```
<plugin-name>/
├── .claude-plugin/
│   └── plugin.json       # Required: name, version, description, author
├── commands/             # Slash commands (/command-name.md)
├── skills/               # Invokable skills
│   └── <skill-name>/
│       └── SKILL.md
├── hooks/
│   └── hooks.json        # Event hooks (PreToolUse, TaskCompleted, etc.)
└── README.md
```

## Developing a New Plugin

1. Create a directory under `plugins/<plugin-name>/`
2. Add `.claude-plugin/plugin.json`:
   ```json
   {
     "name": "my-plugin",
     "description": "What this plugin does",
     "version": "1.0.0",
     "author": { "name": "your-name" },
     "license": "MIT"
   }
   ```
3. Add `commands/`, `skills/`, and/or `hooks/` as needed
4. Write a `README.md` describing commands and usage
5. Run `./scripts/install.sh` to pick up the new plugin

## Syncing Across Machines (symlink install)

Because the cache entries are symlinks, edits made through Claude Code write back to this repository. To sync across machines:

```bash
# Push from one machine
git add -A && git commit -m "Update plugins" && git push

# Pull on another machine
git pull
./scripts/install.sh   # only needed when adding new plugins
```

## License

MIT
