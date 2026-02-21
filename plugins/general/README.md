# General Purpose Plugin

Core utilities for everyday Claude Code workflows: deep research, interactive CLI helpers via `gum`, and general-purpose sub-agents.

## Commands

| Command | Description |
|---------|-------------|
| `/research` | Kick off a structured research session using specialized sub-agents |
| `/explore-repo` | Map the current repository's architecture, conventions, and entry points |
| `/docs` | Look up documentation or generate missing docs for a file or module |

## Skills

| Skill | Description |
|-------|-------------|
| `research` | Orchestrates web, code, and documentation research via parallel sub-agents |
| `repo-explorer` | Maps repository structure, architecture patterns, conventions, and dependencies |
| `docs` | Documentation lookup (local + external) and generation in the project's existing style |

## Dependencies

- [`gum`](https://github.com/charmbracelet/gum) — CLI tool for interactive shell prompts, spinners, and selections. Used by the `scripts/gum-research.sh` helper. Install with: `brew install gum` or `go install github.com/charmbracelet/gum@latest`

## Usage

```
/research <your question or topic>
```

For interactive research with a gum-powered menu, run `scripts/gum-research.sh` directly from the terminal.

## Files

```
general/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── commands/
│   ├── research.md           # /research slash command
│   ├── explore-repo.md       # /explore-repo slash command
│   └── docs.md               # /docs slash command
├── skills/
│   ├── research/
│   │   └── SKILL.md          # Research orchestration skill
│   ├── repo-explorer/
│   │   └── SKILL.md          # Repository mapping and analysis skill
│   └── docs/
│       └── SKILL.md          # Documentation lookup and generation skill
├── scripts/
│   └── gum-research.sh       # Interactive gum-powered research launcher
└── config/
    ├── gum.md                # Gum configuration and usage reference
    └── best-practices.md     # Development best practices reference
```
