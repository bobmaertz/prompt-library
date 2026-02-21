# General Plugin

General-purpose Claude Code plugin covering research, repository exploration, documentation generation, code review, and git workflow automation.

## Commands

### Research & exploration
| Command | Description |
|---------|-------------|
| `/research` | Structured research session using parallel sub-agents |
| `/explore-repo` | Map the current repository's architecture, conventions, and entry points |
| `/docs` | Look up documentation or generate missing docs for a file or module |

### Code review
| Command | Description |
|---------|-------------|
| `/review` | Quick all-in-one review covering quality, security, best practices, and performance |
| `/peer-review` | Deep peer review as a background agent |
| `/security-review` | Security-focused review (OWASP Top 10) as a background agent |

### Git
| Command | Description |
|---------|-------------|
| `/commit` | Generate a commit message that matches this project's existing commit style |

## Skills

| Skill | Description |
|-------|-------------|
| `research` | Orchestrates web, code, and documentation research via parallel sub-agents |
| `repo-explorer` | Maps repository structure, architecture patterns, conventions, and dependencies |
| `docs` | Documentation lookup (local + external) and generation in the project's existing style |
| `peer-reviewer` | Reviews code for quality, best practices, performance, and maintainability |
| `security-reviewer` | Reviews code for OWASP Top 10, injection flaws, auth issues, and common vulnerabilities |
| `git-commit` | Analyzes staged changes and git history to produce a correctly-styled commit message |
| `git-worktree-manager` | Create, list, remove, and prune git worktrees for parallel agent workflows |

## Hooks

`hooks/hooks.json` defines two event hooks:

- **`TaskCompleted`** — after any task that modified source code, automatically invokes the `peer-reviewer` skill as a background agent
- **`PreToolUse` (Bash)** — before a `git commit` command, checks whether peer review found unresolved Critical or Major issues and blocks the commit if so

## Dependencies

- [`gum`](https://github.com/charmbracelet/gum) — used by `scripts/gum-research.sh` for interactive research menus. Install with `brew install gum` or `go install github.com/charmbracelet/gum@latest`

## Files

```
general/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── research.md
│   ├── explore-repo.md
│   ├── docs.md
│   ├── review.md
│   ├── peer-review.md
│   ├── security-review.md
│   └── commit.md
├── skills/
│   ├── research/SKILL.md
│   ├── repo-explorer/SKILL.md
│   ├── docs/SKILL.md
│   ├── peer-reviewer/SKILL.md
│   ├── security-reviewer/SKILL.md
│   ├── git-commit/SKILL.md
│   └── git-worktree-manager/
│       ├── SKILL.md
│       └── scripts/
├── hooks/
│   └── hooks.json
├── scripts/
│   └── gum-research.sh
└── config/
    ├── gum.md
    └── best-practices.md
```
