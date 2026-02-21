#!/usr/bin/env bash
#
# Claude Plugin Library Installer
#
# Symlinks each plugin from plugins/ into ~/.claude/plugins/cache/ and registers
# it in ~/.claude/settings.json, matching the Claude Code plugin installation
# format described at https://code.claude.com/docs/en/plugins
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PLUGIN_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Claude Code config root — all plugin state lives under ~/.claude/
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
PLUGINS_CACHE_DIR="$CLAUDE_DIR/plugins/cache"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

print_info()    { echo -e "${BLUE}i${NC} $1"; }
print_success() { echo -e "${GREEN}+${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error()   { echo -e "${RED}x${NC} $1"; }

print_header() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Create a symlink with automatic backup of any existing target
create_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"

    local target_dir
    target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ]; then
            local existing_link
            existing_link=$(readlink "$target")
            if [ "$existing_link" = "$source" ]; then
                print_info "$description (already linked)"
                return 0
            fi
        fi
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "$description already exists, backing up to $(basename "$backup")"
        mv "$target" "$backup"
    fi

    ln -s "$source" "$target"
    print_success "$description"
}

# Add a plugin to the enabledPlugins list in ~/.claude/settings.json
register_plugin() {
    local plugin_name="$1"

    # Create settings.json if it doesn't exist yet
    if [ ! -f "$SETTINGS_FILE" ]; then
        mkdir -p "$(dirname "$SETTINGS_FILE")"
        echo '{}' > "$SETTINGS_FILE"
    fi

    python3 - "$SETTINGS_FILE" "$plugin_name" <<'PYEOF'
import json, sys

settings_file, plugin_name = sys.argv[1], sys.argv[2]

with open(settings_file) as f:
    settings = json.load(f)

settings.setdefault('enabledPlugins', [])

if any(p.get('name') == plugin_name for p in settings['enabledPlugins']):
    sys.exit(0)  # already registered

settings['enabledPlugins'].append({'name': plugin_name})

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
PYEOF
}

install_plugins() {
    print_header "Installing Claude Code Plugins"

    local plugins_dir="$PLUGIN_LIB_DIR/plugins"

    if [ ! -d "$plugins_dir" ]; then
        print_error "No plugins directory found at $plugins_dir"
        exit 1
    fi

    mkdir -p "$PLUGINS_CACHE_DIR"

    local installed=0

    for plugin in "$plugins_dir"/*/; do
        [ -d "$plugin" ] || continue
        local plugin_name
        plugin_name=$(basename "$plugin")

        # Symlink the entire plugin directory into the cache
        create_symlink \
            "${plugin%/}" \
            "$PLUGINS_CACHE_DIR/$plugin_name" \
            "plugin: $plugin_name"

        # Register in ~/.claude/settings.json
        register_plugin "$plugin_name"
        print_info "  registered in $(basename "$SETTINGS_FILE")"

        installed=$((installed + 1))
    done

    echo ""
    print_success "Installed $installed plugin(s)"
}

show_summary() {
    print_header "Installation Summary"

    echo "Plugin library:  $PLUGIN_LIB_DIR/plugins"
    echo "Plugin cache:    $PLUGINS_CACHE_DIR"
    echo "Settings file:   $SETTINGS_FILE"
    echo ""

    local count
    count=$(find "$PLUGINS_CACHE_DIR" -maxdepth 1 -type l 2>/dev/null | wc -l | tr -d ' ')
    echo "  Plugins installed: $count"
    echo ""

    print_success "Installation complete!"
    echo ""
    print_info "Because the cache entries are symlinks, edits made through Claude Code"
    print_info "sync back to this repository automatically."
    print_info ""
    print_info "To push changes:"
    echo "  cd $PLUGIN_LIB_DIR"
    echo "  git add -A && git commit -m \"Update plugins\" && git push"
}

main() {
    print_header "Claude Plugin Library Installer"

    echo "Each plugin will be symlinked into the Claude Code plugin cache and"
    echo "registered in settings.json as an enabled plugin."
    echo ""
    echo "Plugin cache:  $PLUGINS_CACHE_DIR"
    echo "Settings file: $SETTINGS_FILE"
    echo ""
    echo "Override with: CLAUDE_DIR=/path ./scripts/install.sh"
    echo ""

    read -r -p "Continue with installation? [Y/n] " REPLY
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
        print_warning "Installation cancelled"
        exit 0
    fi

    install_plugins
    show_summary
}

main "$@"
