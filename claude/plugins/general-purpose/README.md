# General Purpose Plugin

Core utilities for everyday Claude Code workflows: deep research, interactive CLI helpers via `gum`, and general-purpose sub-agents.

## Commands

| Command | Description |
|---------|-------------|
| `/research` | Kick off a structured research session using specialized sub-agents |

## Skills

| Skill | Description |
|-------|-------------|
| `research` | Orchestrates web, code, and documentation research via parallel sub-agents |

## Dependencies

- [`gum`](https://github.com/charmbracelet/gum) — CLI tool for interactive shell prompts, spinners, and selections. Used by the `scripts/gum-research.sh` helper. Install with: `brew install gum` or `go install github.com/charmbracelet/gum@latest`

## Usage

```
/research <your question or topic>
```

For interactive research with a gum-powered menu, run `scripts/gum-research.sh` directly from the terminal.

## Files

```
general-purpose/
├── commands/
│   └── research.md           # /research slash command
├── skills/
│   └── research/
│       └── SKILL.md          # Research orchestration skill
├── scripts/
│   └── gum-research.sh       # Interactive gum-powered research launcher
└── config/
    └── gum.md                # Gum configuration and usage reference
```
