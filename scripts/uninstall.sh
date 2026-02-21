#!/usr/bin/env bash
#
# Claude Plugin Library Uninstaller
#
# Removes symlinks from ~/.claude/plugins/cache/ and deregisters plugins from
# ~/.claude/settings.json. Does not remove backup files.
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PLUGIN_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
PLUGINS_CACHE_DIR="$CLAUDE_DIR/plugins/cache"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

print_info()    { echo -e "${BLUE}i${NC} $1"; }
print_success() { echo -e "${GREEN}+${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }

print_header() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Remove a symlink only if it points into this plugin library
remove_symlink() {
    local link_path="$1"
    local description="$2"

    if [ -L "$link_path" ]; then
        local target
        target=$(readlink "$link_path")
        if [[ "$target" == "$PLUGIN_LIB_DIR"* ]]; then
            rm "$link_path"
            print_success "Removed: $description"
            return 0
        else
            print_info "Skipped: $description (points elsewhere)"
            return 1
        fi
    else
        print_info "Not found: $description"
        return 1
    fi
}

# Remove a directory if it is empty
remove_if_empty() {
    local dir_path="$1"
    if [ -d "$dir_path" ] && [ -z "$(ls -A "$dir_path")" ]; then
        rmdir "$dir_path"
        print_info "Removed empty directory: $dir_path"
    fi
}

# Remove a plugin from enabledPlugins in ~/.claude/settings.json
deregister_plugin() {
    local plugin_name="$1"

    [ -f "$SETTINGS_FILE" ] || return 0

    python3 - "$SETTINGS_FILE" "$plugin_name" <<'PYEOF'
import json, sys

settings_file, plugin_name = sys.argv[1], sys.argv[2]

with open(settings_file) as f:
    settings = json.load(f)

if 'enabledPlugins' in settings:
    settings['enabledPlugins'] = [
        p for p in settings['enabledPlugins']
        if p.get('name') != plugin_name
    ]

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
PYEOF
}

uninstall_plugins() {
    print_header "Uninstalling Claude Code Plugins"

    local removed=0

    for plugin in "$PLUGIN_LIB_DIR/plugins"/*/; do
        [ -d "$plugin" ] || continue
        local plugin_name
        plugin_name=$(basename "$plugin")

        if remove_symlink "$PLUGINS_CACHE_DIR/$plugin_name" "plugin: $plugin_name"; then
            removed=$((removed + 1))
            deregister_plugin "$plugin_name"
            print_info "  deregistered from $(basename "$SETTINGS_FILE")"
        fi
    done

    remove_if_empty "$PLUGINS_CACHE_DIR"
    remove_if_empty "$(dirname "$PLUGINS_CACHE_DIR")"

    if [ "$removed" -eq 0 ]; then
        print_info "No plugin symlinks found to remove"
    fi
}

show_summary() {
    print_header "Uninstallation Summary"

    echo "Removed symlinks from: $PLUGINS_CACHE_DIR"
    echo "Updated settings file: $SETTINGS_FILE"
    echo ""

    local backups
    backups=$(find "$PLUGINS_CACHE_DIR" -name "*.backup.*" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$backups" -gt 0 ]; then
        print_warning "$backups backup file(s) left in $PLUGINS_CACHE_DIR — remove manually when ready."
    fi

    echo ""
    print_success "Uninstallation complete!"
    echo ""
    print_info "The repository at $PLUGIN_LIB_DIR has not been modified."
}

main() {
    print_header "Claude Plugin Library Uninstaller"

    echo "This will remove plugin symlinks and deregister plugins from settings."
    echo ""
    echo "Plugin cache:  $PLUGINS_CACHE_DIR"
    echo "Settings file: $SETTINGS_FILE"
    echo ""
    echo "Backup files will be preserved."
    echo ""

    read -r -p "Continue with uninstallation? [Y/n] " REPLY
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
        print_warning "Uninstallation cancelled"
        exit 0
    fi

    uninstall_plugins
    show_summary
}

main "$@"
