# Claude Plugin Library

A collection of Claude Code plugins for everyday development workflows. Each plugin is self-contained with commands, skills, and hooks that extend Claude Code for a specific domain.

## Plugins

| Plugin | Description |
|--------|-------------|
| [`general`](plugins/general/) | Research, repository exploration, and documentation generation |
| [`review`](plugins/review/) | Code review: quick, peer, and security review agents with pre-commit hooks |
| [`git`](plugins/git/) | Git commit message generation and worktree management |
| [`backend`](plugins/backend/) | LSP server configuration and linter templates |

## Installation

Clone the repository and run the installer. It creates symbolic links from your Claude Code config directory into this repo so edits sync back automatically.

```bash
git clone https://github.com/bobmaertz/prompt-library.git ~/.claude-plugins
cd ~/.claude-plugins
./scripts/install.sh
```

The installer places each plugin's components into `~/.config/claude/`:

| Component | Destination |
|-----------|-------------|
| Skills | `~/.config/claude/skills/<skill-name>/` |
| Commands | `~/.config/claude/commands/<command-name>.md` |
| Hooks | `~/.config/claude/hooks/plugins/<plugin-name>.json` |

Override the default config path:

```bash
CLAUDE_CONFIG_DIR=/custom/path ./scripts/install.sh
```

## Uninstallation

```bash
./scripts/uninstall.sh
```

Removes only the symlinks created by the installer. Backup files are left in place.

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

## Syncing Across Machines

Because installation uses symlinks, any change made through either the config directory or the repository is immediately reflected in both. To sync across machines:

```bash
# Push from one machine
git add -A && git commit -m "Update plugins" && git push

# Pull on another machine
git pull
./scripts/install.sh   # only needed for new plugins
```

## License

MIT
