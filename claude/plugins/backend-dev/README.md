# Backend Dev Plugin

Configuration references and tooling for backend development workflows. Focuses on LSP setup and linter configuration so Claude Code has accurate context about your language server and code quality standards.

## Contents

| Path | Purpose |
|------|---------|
| `config/lsp-settings.md` | LSP server settings reference for common languages |
| `config/linters.md` | Linter configuration templates and conventions |

## Philosophy

This plugin is intentionally **configuration-as-documentation** — it doesn't run tools itself, but provides:

1. The settings you should have in your editor/LSP so diagnostics are accurate
2. The linter configs that should exist in projects so Claude Code knows your standards
3. Templates you can copy into new projects

## Supported Languages

| Language | LSP Server | Linter(s) |
|----------|-----------|-----------|
| TypeScript/JavaScript | `typescript-language-server` | ESLint, Biome |
| Python | `pylsp` / `pyright` | Ruff, pylint, mypy |
| Go | `gopls` | `golangci-lint` |
| Rust | `rust-analyzer` | Clippy |
| Bash/Shell | `bash-language-server` | shellcheck |

## Usage

Reference these configs when setting up a new project or onboarding Claude Code to an existing one. Copy the relevant linter config template into your project root, then point your editor's LSP at the language-specific settings.
