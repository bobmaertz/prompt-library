# LSP Settings Reference

Language server configurations for use with your editor (VS Code, Neovim, etc.) and Claude Code diagnostics.

---

## TypeScript / JavaScript

**Language Server**: `typescript-language-server` (via `tsserver`)

### VS Code (`settings.json`)
```json
{
  "typescript.preferences.importModuleSpecifier": "relative",
  "typescript.preferences.quoteStyle": "single",
  "typescript.suggest.autoImports": true,
  "typescript.updateImportsOnFileMove.enabled": "always",
  "typescript.tsdk": "node_modules/typescript/lib",
  "javascript.preferences.quoteStyle": "single",
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  }
}
```

### Neovim (lua, `lspconfig`)
```lua
require('lspconfig').ts_ls.setup({
  settings = {
    typescript = {
      preferences = {
        importModuleSpecifier = "relative",
        quoteStyle = "single",
      },
    },
    javascript = {
      preferences = {
        quoteStyle = "single",
      },
    },
  },
})
```

### `tsconfig.json` baseline
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

---

## Python

**Language Servers**: `pyright` (type checking) or `pylsp` (feature-rich)

### VS Code (`settings.json`)
```json
{
  "python.languageServer": "Pylance",
  "python.analysis.typeCheckingMode": "strict",
  "python.analysis.autoImportCompletions": true,
  "python.analysis.inlayHints.variableTypes": true,
  "python.analysis.inlayHints.functionReturnTypes": true,
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll.ruff": "explicit",
      "source.organizeImports.ruff": "explicit"
    }
  }
}
```

### Neovim (lua, `lspconfig`)
```lua
require('lspconfig').pyright.setup({
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "strict",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})
```

### `pyrightconfig.json` baseline
```json
{
  "include": ["src"],
  "exclude": ["**/__pycache__", ".venv"],
  "typeCheckingMode": "strict",
  "pythonVersion": "3.11",
  "venvPath": ".",
  "venv": ".venv"
}
```

---

## Go

**Language Server**: `gopls`

### VS Code (`settings.json`)
```json
{
  "go.useLanguageServer": true,
  "gopls": {
    "ui.semanticTokens": true,
    "analyses": {
      "unusedparams": true,
      "shadow": true,
      "fieldalignment": true
    },
    "staticcheck": true,
    "gofumpt": true
  },
  "[go]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  }
}
```

### Neovim (lua, `lspconfig`)
```lua
require('lspconfig').gopls.setup({
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})
```

---

## Rust

**Language Server**: `rust-analyzer`

### VS Code (`settings.json`)
```json
{
  "rust-analyzer.checkOnSave.command": "clippy",
  "rust-analyzer.checkOnSave.extraArgs": ["--", "-W", "clippy::all"],
  "rust-analyzer.inlayHints.typeHints.enable": true,
  "rust-analyzer.inlayHints.parameterHints.enable": true,
  "[rust]": {
    "editor.defaultFormatter": "rust-lang.rust-analyzer",
    "editor.formatOnSave": true
  }
}
```

### Neovim (lua, `lspconfig`)
```lua
require('lspconfig').rust_analyzer.setup({
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = "clippy",
        extraArgs = { "--", "-W", "clippy::all" },
      },
      inlayHints = {
        typeHints = { enable = true },
        parameterHints = { enable = true },
      },
    },
  },
})
```

---

## Shell / Bash

**Language Server**: `bash-language-server`

### Installation
```bash
npm install -g bash-language-server
```

### VS Code (`settings.json`)
```json
{
  "bashIde.shellcheckPath": "shellcheck",
  "bashIde.enableSourceErrorDiagnostics": true,
  "[shellscript]": {
    "editor.defaultFormatter": "foxundermoon.shell-format",
    "editor.formatOnSave": true
  }
}
```

### Neovim (lua, `lspconfig`)
```lua
require('lspconfig').bashls.setup({
  filetypes = { "sh", "bash", "zsh" },
})
```

---

## Common Patterns

### Format on Save (all languages)
Always enable `editor.formatOnSave: true` per language to ensure consistent formatting before Claude Code reads files.

### Diagnostics
LSP diagnostics surface in Claude Code when it reads files. Ensure your language server is running and configured before asking Claude Code to fix lint errors.

### Path mapping
If your project uses path aliases (e.g., `@/` → `src/`), configure them in both `tsconfig.json` and your LSP settings so auto-imports resolve correctly.
