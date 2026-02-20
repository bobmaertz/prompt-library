# Claude Code Plugins

A plugin is a self-contained collection of related commands, skills, hooks, and configuration that extend Claude Code for a specific purpose.

## Directory Structure

```
claude/plugins/
├── general-purpose/    # Research commands, gum helpers, general utilities
├── backend-dev/        # LSP config, linters, backend-focused tooling
└── code-review/        # Peer review and security review agents
```

Each plugin follows this internal layout:

```
<plugin-name>/
├── README.md           # Plugin overview and usage
├── commands/           # Slash commands (/command-name)
│   └── *.md
├── skills/             # Invokable skills (sub-agents, background tasks)
│   └── <skill-name>/
│       └── SKILL.md
├── hooks/              # Event-driven hooks (pre-commit, post-tool, etc.)
│   └── *.md
└── config/             # Reference configs, templates, settings
    └── *.md
```

## Installation

The `scripts/install.sh` script traverses this directory and symlinks each plugin's commands, skills, and hooks into the Claude Code config directory (`~/.config/claude/`).

Plugins are installed flat — meaning a skill at `code-review/skills/peer-reviewer/` becomes `~/.config/claude/skills/peer-reviewer/`. Ensure skill and command names are unique across plugins.

## Adding a New Plugin

1. Create a directory under `claude/plugins/<plugin-name>/`
2. Add a `README.md` describing purpose, commands, and usage
3. Populate `commands/`, `skills/`, `hooks/`, and/or `config/` as needed
4. Re-run `scripts/install.sh` to pick up the new plugin

## Current Plugins

| Plugin | Purpose |
|--------|---------|
| `general-purpose` | Research workflows, gum-based CLI helpers, general utilities |
| `backend-dev` | LSP configuration, linter setup, backend development tooling |
| `code-review` | Peer review and security review as background agents |
