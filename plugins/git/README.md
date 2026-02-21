# Git Plugin

Git workflow automation for Claude Code: context-aware commit message generation and worktree management for parallel agent workflows.

## Commands

| Command | Description |
|---------|-------------|
| `/commit` | Generate a commit message that matches this project's existing commit style |

## Skills

| Skill | Description |
|-------|-------------|
| `git-commit` | Analyzes staged changes and git history to produce a correctly-styled commit message |
| `git-worktree-manager` | Create, list, remove, and prune git worktrees for isolated feature branch development |

## Usage

### Commit message generation

```
/commit
/commit auth refactor scope
```

The `git-commit` skill reads `git log` to detect the project's commit style (conventional commits, imperative phrases, ticket-prefixed, etc.) and matches it — never imposes a format the project doesn't use.

Optionally place a `.commitstyle` file in your repo root to lock in a format:

```
# .commitstyle
format: conventional
ticket-prefix: PROJ
max-subject-length: 72
use-body: true
trailers: Closes, Refs
```

### Worktree management

The `git-worktree-manager` skill is invoked automatically when you ask Claude to work on a ticket in isolation, create a feature branch worktree, or clean up stale worktrees.

```
Create a worktree for feature/add-auth
List all current worktrees
Remove the worktree for feature/old-feature and delete the branch
Prune any stale worktrees
```

Scripts are available directly in `skills/git-worktree-manager/scripts/` for shell use:

```bash
python3 skills/git-worktree-manager/scripts/create_worktree.py feature/add-auth
python3 skills/git-worktree-manager/scripts/list_worktrees.py
python3 skills/git-worktree-manager/scripts/remove_worktree.py feature/add-auth --delete-branch
python3 skills/git-worktree-manager/scripts/prune_worktrees.py --dry-run
```
