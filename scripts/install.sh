#!/usr/bin/env bash
#
# Claude Plugin Library Installer
#
# Installs plugins from this library into the Claude Code configuration directory
# using symbolic links so changes sync back to the repository automatically.
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the absolute path to the plugin library directory
PLUGIN_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default Claude Code configuration path
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.config/claude}"

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
        print_info "Created directory: $target_dir"
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
        print_warning "$description exists, backing up to: $(basename "$backup")"
        mv "$target" "$backup"
    fi

    ln -s "$source" "$target"
    print_success "$description"
}

# Install all plugins found in the plugins/ directory
install_plugins() {
    print_header "Installing Claude Code Plugins"

    local plugins_dir="$PLUGIN_LIB_DIR/plugins"

    if [ ! -d "$plugins_dir" ]; then
        print_error "No plugins directory found at $plugins_dir"
        exit 1
    fi

    local installed=0

    for plugin in "$plugins_dir"/*/; do
        [ -d "$plugin" ] || continue
        local plugin_name
        plugin_name=$(basename "$plugin")

        print_info "Installing plugin: $plugin_name"

        # Install skills
        if [ -d "$plugin/skills" ]; then
            for skill in "$plugin/skills"/*/; do
                [ -d "$skill" ] || continue
                local skill_name
                skill_name=$(basename "$skill")
                create_symlink \
                    "$skill" \
                    "$CLAUDE_CONFIG_DIR/skills/$skill_name" \
                    "  skill: $skill_name"
            done
        fi

        # Install commands
        if [ -d "$plugin/commands" ]; then
            for command in "$plugin/commands"/*.md; do
                [ -f "$command" ] || continue
                local command_name
                command_name=$(basename "$command")
                create_symlink \
                    "$command" \
                    "$CLAUDE_CONFIG_DIR/commands/$command_name" \
                    "  command: $command_name"
            done
        fi

        # Install hooks.json into a per-plugin namespace
        if [ -f "$plugin/hooks/hooks.json" ]; then
            local hooks_dir="$CLAUDE_CONFIG_DIR/hooks/plugins"
            mkdir -p "$hooks_dir"
            create_symlink \
                "$plugin/hooks/hooks.json" \
                "$hooks_dir/$plugin_name.json" \
                "  hooks: $plugin_name"
        fi

        installed=$((installed + 1))
    done

    echo ""
    print_success "Installed $installed plugin(s)"
}

# Print a summary of what was installed
show_summary() {
    print_header "Installation Summary"

    echo "Plugin library: $PLUGIN_LIB_DIR"
    echo "Claude config:  $CLAUDE_CONFIG_DIR"
    echo ""

    if [ -d "$CLAUDE_CONFIG_DIR/skills" ]; then
        skill_count=$(find "$CLAUDE_CONFIG_DIR/skills" -maxdepth 1 -type l 2>/dev/null | wc -l | tr -d ' ')
        echo "  Skills:   $skill_count symlinked"
    fi
    if [ -d "$CLAUDE_CONFIG_DIR/commands" ]; then
        command_count=$(find "$CLAUDE_CONFIG_DIR/commands" -maxdepth 1 -type l 2>/dev/null | wc -l | tr -d ' ')
        echo "  Commands: $command_count symlinked"
    fi
    if [ -d "$CLAUDE_CONFIG_DIR/hooks/plugins" ]; then
        hook_count=$(find "$CLAUDE_CONFIG_DIR/hooks/plugins" -maxdepth 1 -type l 2>/dev/null | wc -l | tr -d ' ')
        echo "  Hooks:    $hook_count plugin(s) symlinked"
    fi

    echo ""
    print_success "Installation complete!"
    echo ""
    print_info "Files edited in $CLAUDE_CONFIG_DIR automatically sync back to the repository."
    print_info "To push changes:"
    echo "  cd $PLUGIN_LIB_DIR"
    echo "  git add -A && git commit -m \"Update plugins\" && git push"
}

main() {
    print_header "Claude Plugin Library Installer"

    echo "Source:  $PLUGIN_LIB_DIR/plugins"
    echo "Target:  $CLAUDE_CONFIG_DIR"
    echo ""
    echo "Override the target path with: CLAUDE_CONFIG_DIR=/path ./scripts/install.sh"
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
