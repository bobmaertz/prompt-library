# Linter Configuration Reference

Templates and conventions for linter configuration files. Copy the relevant template into your project root.

---

## TypeScript / JavaScript — ESLint

**File**: `eslint.config.js` (flat config, ESLint v9+)

```js
// eslint.config.js
import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.strictTypeChecked,
  ...tseslint.configs.stylisticTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        project: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      // Enforce explicit return types on exported functions
      '@typescript-eslint/explicit-module-boundary-types': 'error',
      // No floating promises
      '@typescript-eslint/no-floating-promises': 'error',
      // No unused variables (allow _ prefix)
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      // Prefer const assertions
      '@typescript-eslint/prefer-as-const': 'error',
      // No explicit any
      '@typescript-eslint/no-explicit-any': 'error',
      // Consistent type imports
      '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports' }],
    },
  },
  {
    ignores: ['dist/**', 'node_modules/**', '**/*.js.map', 'coverage/**'],
  }
);
```

**Install**:
```bash
npm install -D eslint @eslint/js typescript-eslint
```

---

## TypeScript / JavaScript — Biome (ESLint + Prettier alternative)

**File**: `biome.json`

```json
{
  "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "correctness": {
        "noUnusedVariables": "error",
        "useExhaustiveDependencies": "warn"
      },
      "suspicious": {
        "noExplicitAny": "error",
        "noConsoleLog": "warn"
      },
      "style": {
        "useConst": "error",
        "useTemplate": "error"
      }
    }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "trailingCommas": "all",
      "semicolons": "always"
    }
  },
  "files": {
    "ignore": ["dist/**", "node_modules/**", "coverage/**"]
  }
}
```

**Install**:
```bash
npm install -D @biomejs/biome
```

---

## Python — Ruff

**File**: `ruff.toml` (or `[tool.ruff]` in `pyproject.toml`)

```toml
# ruff.toml
target-version = "py311"
line-length = 100
indent-width = 4

[lint]
select = [
  "E",   # pycodestyle errors
  "W",   # pycodestyle warnings
  "F",   # Pyflakes
  "I",   # isort
  "B",   # flake8-bugbear
  "C4",  # flake8-comprehensions
  "UP",  # pyupgrade
  "SIM", # flake8-simplify
  "TCH", # flake8-type-checking
  "ANN", # flake8-annotations
  "S",   # flake8-bandit (security)
  "N",   # pep8-naming
]
ignore = [
  "ANN101", # Missing type annotation for self
  "ANN102", # Missing type annotation for cls
]

[lint.per-file-ignores]
"tests/**" = ["S101"]  # Allow assert in tests

[format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "auto"
```

**Install**:
```bash
pip install ruff
# or
uv add --dev ruff
```

---

## Python — mypy

**File**: `mypy.ini` (or `[tool.mypy]` in `pyproject.toml`)

```ini
[mypy]
python_version = 3.11
strict = true
warn_return_any = true
warn_unused_configs = true
warn_redundant_casts = true
warn_unused_ignores = true
no_implicit_reexport = true
disallow_untyped_defs = true
disallow_any_generics = true
check_untyped_defs = true

# Per-module overrides for third-party stubs
[mypy-requests.*]
ignore_missing_imports = true
```

---

## Go — golangci-lint

**File**: `.golangci.yml`

```yaml
run:
  timeout: 5m
  go: '1.22'

linters:
  enable:
    - errcheck       # Check unchecked errors
    - govet          # Vet examines Go source code
    - staticcheck    # Staticcheck is a state of the art linter
    - unused         # Checks for unused code
    - gofmt          # Checks code is formatted with gofmt
    - goimports      # Checks imports are formatted with goimports
    - revive         # Fast, configurable, extensible linter
    - gosec          # Security-oriented checks
    - bodyclose      # Checks HTTP response body is closed
    - exhaustive     # Check exhaustiveness of enum switches
    - gocritic       # Diagnostic checks
    - noctx          # Finds sends http request without context.Context
    - prealloc       # Slice declarations that can be pre-allocated

linters-settings:
  errcheck:
    check-type-assertions: true
  govet:
    enable-all: true
  revive:
    rules:
      - name: exported
        disabled: false
  gosec:
    excludes:
      - G104  # Errors unhandled — covered by errcheck

issues:
  exclude-rules:
    - path: _test\.go
      linters:
        - gosec
        - errcheck
```

**Install**:
```bash
brew install golangci-lint
# or
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

---

## Rust — Clippy

Clippy is bundled with Rust. Configure via `clippy.toml` or workspace settings.

**File**: `clippy.toml`
```toml
# clippy.toml
msrv = "1.78"
cognitive-complexity-threshold = 15
too-many-arguments-threshold = 6
```

**`Cargo.toml` workspace lints**:
```toml
[workspace.lints.clippy]
all = "warn"
pedantic = "warn"
nursery = "warn"
# Selectively allow common false positives
module_name_repetitions = "allow"
must_use_candidate = "allow"
```

**Run**:
```bash
cargo clippy -- -W clippy::all -W clippy::pedantic -D warnings
```

---

## Shell — shellcheck

**File**: `.shellcheckrc`
```
# .shellcheckrc
shell=bash
enable=all
# SC2034: variable appears unused — too noisy for sourced files
disable=SC2034
```

**Install**:
```bash
brew install shellcheck
# or
apt install shellcheck
```

---

## CI Integration

Add linting to your CI pipeline (GitHub Actions example):

```yaml
# .github/workflows/lint.yml
name: Lint
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run linters
        run: |
          # TypeScript
          npm ci && npx eslint .
          # Python
          ruff check . && mypy src/
          # Go
          golangci-lint run
          # Shell
          shellcheck scripts/**/*.sh
```
