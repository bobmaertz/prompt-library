# Gum Configuration & Usage Reference

[`gum`](https://github.com/charmbracelet/gum) is a CLI tool for building interactive, styled shell scripts. It's used in this plugin's scripts to provide spinners, prompts, confirmations, and selection menus.

## Installation

```bash
# macOS
brew install gum

# Go
go install github.com/charmbracelet/gum@latest

# Nix
nix-env -iA nixpkgs.gum

# Debian/Ubuntu
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install gum
```

## Core Commands Used in This Plugin

### `gum input` — Single-line text prompt
```bash
QUERY=$(gum input --placeholder "Enter search query" --width 60)
```

### `gum choose` — Selection menu
```bash
# Single selection
MODE=$(gum choose "Web" "Codebase" "Documentation")

# Multi-selection (space to select, enter to confirm)
MODES=$(gum choose --no-limit "Web" "Codebase" "Documentation")
```

### `gum confirm` — Yes/No confirmation
```bash
if gum confirm "Proceed?"; then
    echo "Confirmed"
fi
```

### `gum spin` — Spinner for async operations
```bash
gum spin --spinner dot --title "Searching..." -- sleep 2
gum spin --spinner line --title "Fetching..." -- some-command
```

### `gum style` — Styled text output
```bash
# Header
gum style --foreground 212 --border double --align center --padding "1 4" "Title"

# Colored text
gum style --foreground 82 "Success message"
gum style --foreground 196 "Error message"
gum style --foreground 220 "Warning message"
```

### `gum write` — Multi-line text input
```bash
BODY=$(gum write --placeholder "Enter description..." --width 60 --height 10)
```

### `gum filter` — Fuzzy-search a list
```bash
BRANCH=$(git branch | gum filter --placeholder "Select branch...")
```

## Color Reference (256-color ANSI)

| Code | Color | Use |
|------|-------|-----|
| 82 | Green | Success |
| 196 | Red | Error |
| 212 | Pink/Magenta | Accent/Headers |
| 220 | Yellow | Warning |
| 39 | Cyan | Info |
| 245 | Gray | Muted text |

## Theming with Environment Variables

```bash
export GUM_INPUT_CURSOR_FOREGROUND=212
export GUM_INPUT_PROMPT_FOREGROUND=212
export GUM_CHOOSE_CURSOR_FOREGROUND=212
export GUM_CHOOSE_SELECTED_FOREGROUND=82
export GUM_CONFIRM_PROMPT_FOREGROUND=212
export GUM_CONFIRM_SELECTED_BACKGROUND=212
```

Add these to your `~/.bashrc` or `~/.zshrc` for consistent gum theming.

## Scripts in This Plugin

| Script | Purpose |
|--------|---------|
| `scripts/gum-research.sh` | Interactive research launcher with topic input, mode selection, and focus specification |

## Adding New Gum Scripts

Place new scripts in `scripts/` with:
1. `#!/usr/bin/env bash` shebang
2. `set -e` for error handling
3. A `gum` availability check at the top
4. Clear comments explaining purpose and dependencies
