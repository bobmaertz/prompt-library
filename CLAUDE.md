# Claude Code Instructions

## Plugin Version Management

Whenever you make any change to a plugin's files — including commands, skills, hooks, scripts, config, or `plugin.json` itself — you **must** increment the plugin's version in its `.claude-plugin/plugin.json` before committing.

### Which version field to bump

Follow [Semantic Versioning](https://semver.org/) (`MAJOR.MINOR.PATCH`):

| Change type | Field to bump | Example |
|-------------|---------------|---------|
| Bug fix, typo, minor wording tweak | `PATCH` | `0.2.1` → `0.2.2` |
| New command, skill, hook, or non-breaking feature | `MINOR` | `0.2.1` → `0.3.0` |
| Breaking change (renamed/removed command or skill) | `MAJOR` | `0.2.1` → `1.0.0` |

### Plugin version file locations

| Plugin | Version file |
|--------|-------------|
| `general` | `plugins/general/.claude-plugin/plugin.json` |
| `backend` | `plugins/backend/.claude-plugin/plugin.json` |

### Rules

- Only bump the version for the plugin(s) you actually changed. If you edited files under `plugins/general/`, only increment `general`'s version.
- Never leave the version unchanged after modifying plugin files.
- Bump the version in the same commit as the plugin change, not in a separate commit.
