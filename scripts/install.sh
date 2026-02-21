#!/usr/bin/env bash
#
# Prompt Library Installer
#
# Installs prompt library resources using symbolic links so changes sync back to the repository.
# Supports both Claude Code and Cursor.
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the absolute path to the prompt library directory
PROMPT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default installation paths
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.config/claude}"
CURSOR_CONFIG_DIR="${CURSOR_CONFIG_DIR:-$HOME/.cursor}"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"

    # Create parent directory if it doesn't exist
    local target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
        print_info "Created directory: $target_dir"
    fi

    # Check if target already exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ]; then
            local existing_link=$(readlink "$target")
            if [ "$existing_link" = "$source" ]; then
                print_info "$description (already linked)"
                return 0
            fi
        fi

        # Backup existing file/directory
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "$description exists, backing up to: $backup"
        mv "$target" "$backup"
    fi

    # Create the symlink
    ln -s "$source" "$target"
    print_success "$description"
}

# Function to install Claude Code resources
install_claude() {
    print_header "Installing Claude Code Resources"

    # Check if any Claude resources exist
    if [ ! -d "$PROMPT_LIB_DIR/claude" ]; then
        print_warning "No Claude resources found in $PROMPT_LIB_DIR/claude"
        return 0
    fi

    # Install skills
    if [ -d "$PROMPT_LIB_DIR/claude/skills" ] && [ "$(ls -A "$PROMPT_LIB_DIR/claude/skills" 2>/dev/null)" ]; then
        for skill in "$PROMPT_LIB_DIR/claude/skills"/*; do
            if [ -d "$skill" ]; then
                skill_name=$(basename "$skill")
                create_symlink \
                    "$skill" \
                    "$CLAUDE_CONFIG_DIR/skills/$skill_name" \
                    "Claude skill: $skill_name"
            fi
        done
    fi

    # Install slash commands
    if [ -d "$PROMPT_LIB_DIR/claude/commands" ] && [ "$(ls -A "$PROMPT_LIB_DIR/claude/commands" 2>/dev/null)" ]; then
        for command in "$PROMPT_LIB_DIR/claude/commands"/*; do
            if [ -f "$command" ]; then
                command_name=$(basename "$command")
                create_symlink \
                    "$command" \
                    "$CLAUDE_CONFIG_DIR/commands/$command_name" \
                    "Claude command: $command_name"
            fi
        done
    fi

    # Install hooks
    if [ -d "$PROMPT_LIB_DIR/claude/hooks" ] && [ "$(ls -A "$PROMPT_LIB_DIR/claude/hooks" 2>/dev/null)" ]; then
        for hook in "$PROMPT_LIB_DIR/claude/hooks"/*; do
            if [ -f "$hook" ]; then
                hook_name=$(basename "$hook")
                create_symlink \
                    "$hook" \
                    "$CLAUDE_CONFIG_DIR/hooks/$hook_name" \
                    "Claude hook: $hook_name"
            fi
        done
    fi

    # Install prompts (as a directory)
    if [ -d "$PROMPT_LIB_DIR/claude/prompts" ] && [ "$(ls -A "$PROMPT_LIB_DIR/claude/prompts" 2>/dev/null)" ]; then
        create_symlink \
            "$PROMPT_LIB_DIR/claude/prompts" \
            "$CLAUDE_CONFIG_DIR/prompts" \
            "Claude prompts directory"
    fi

    # Install plugins
    if [ -d "$PROMPT_LIB_DIR/claude/plugins" ]; then
        for plugin in "$PROMPT_LIB_DIR/claude/plugins"/*/; do
            if [ ! -d "$plugin" ]; then continue; fi
            plugin_name=$(basename "$plugin")

            # Plugin skills
            if [ -d "$plugin/skills" ]; then
                for skill in "$plugin/skills"/*/; do
                    if [ -d "$skill" ]; then
                        skill_name=$(basename "$skill")
                        create_symlink \
                            "$skill" \
                            "$CLAUDE_CONFIG_DIR/skills/$skill_name" \
                            "Claude skill ($plugin_name): $skill_name"
                    fi
                done
            fi

            # Plugin commands
            if [ -d "$plugin/commands" ]; then
                for command in "$plugin/commands"/*; do
                    if [ -f "$command" ]; then
                        command_name=$(basename "$command")
                        create_symlink \
                            "$command" \
                            "$CLAUDE_CONFIG_DIR/commands/$command_name" \
                            "Claude command ($plugin_name): $command_name"
                    fi
                done
            fi

            # Plugin hooks (hooks.json symlinked into Claude settings hooks dir)
            if [ -f "$plugin/hooks/hooks.json" ]; then
                hooks_dir="$CLAUDE_CONFIG_DIR/hooks/plugins"
                if [ ! -d "$hooks_dir" ]; then
                    mkdir -p "$hooks_dir"
                    print_info "Created directory: $hooks_dir"
                fi
                create_symlink \
                    "$plugin/hooks/hooks.json" \
                    "$hooks_dir/$plugin_name.json" \
                    "Claude hooks ($plugin_name)"
            fi
        done
        print_success "Plugins installed"
    fi
}

# Function to install Cursor resources
install_cursor() {
    print_header "Installing Cursor Resources"

    # Check if any Cursor resources exist
    if [ ! -d "$PROMPT_LIB_DIR/cursor" ]; then
        print_warning "No Cursor resources found in $PROMPT_LIB_DIR/cursor"
        return 0
    fi

    # Install rules
    if [ -d "$PROMPT_LIB_DIR/cursor/rules" ] && [ "$(ls -A "$PROMPT_LIB_DIR/cursor/rules" 2>/dev/null)" ]; then
        for rule in "$PROMPT_LIB_DIR/cursor/rules"/*; do
            if [ -f "$rule" ]; then
                rule_name=$(basename "$rule")
                create_symlink \
                    "$rule" \
                    "$CURSOR_CONFIG_DIR/rules/$rule_name" \
                    "Cursor rule: $rule_name"
            fi
        done
    fi

    # Install prompts
    if [ -d "$PROMPT_LIB_DIR/cursor/prompts" ] && [ "$(ls -A "$PROMPT_LIB_DIR/cursor/prompts" 2>/dev/null)" ]; then
        create_symlink \
            "$PROMPT_LIB_DIR/cursor/prompts" \
            "$CURSOR_CONFIG_DIR/prompts" \
            "Cursor prompts directory"
    fi
}

# Function to show installation summary
show_summary() {
    print_header "Installation Summary"

    echo "Prompt Library: $PROMPT_LIB_DIR"
    echo ""
    echo "Claude Code Configuration:"
    echo "  Location: $CLAUDE_CONFIG_DIR"
    if [ -d "$CLAUDE_CONFIG_DIR/skills" ]; then
        echo "  Skills: $(find "$CLAUDE_CONFIG_DIR/skills" -type l 2>/dev/null | wc -l) symlinked"
    fi
    if [ -d "$CLAUDE_CONFIG_DIR/commands" ]; then
        echo "  Commands: $(find "$CLAUDE_CONFIG_DIR/commands" -type l 2>/dev/null | wc -l) symlinked"
    fi
    if [ -d "$CLAUDE_CONFIG_DIR/hooks" ]; then
        echo "  Hooks: $(find "$CLAUDE_CONFIG_DIR/hooks" -type l 2>/dev/null | wc -l) symlinked"
    fi
    if [ -d "$CLAUDE_CONFIG_DIR/hooks/plugins" ]; then
        echo "  Plugin hooks: $(find "$CLAUDE_CONFIG_DIR/hooks/plugins" -type l 2>/dev/null | wc -l) symlinked"
    fi

    echo ""
    echo "Cursor Configuration:"
    echo "  Location: $CURSOR_CONFIG_DIR"
    if [ -d "$CURSOR_CONFIG_DIR/rules" ]; then
        echo "  Rules: $(find "$CURSOR_CONFIG_DIR/rules" -type l 2>/dev/null | wc -l) symlinked"
    fi

    echo ""
    print_success "Installation complete!"
    echo ""
    print_info "Any changes you make to files in your config directories will automatically"
    print_info "sync back to the prompt library repository."
    echo ""
    print_info "To push changes back to the repository:"
    echo "  cd $PROMPT_LIB_DIR"
    echo "  git add -A"
    echo "  git commit -m \"Update prompts\""
    echo "  git push"
}

# Main installation
main() {
    print_header "Prompt Library Installer"

    echo "This will install prompt library resources using symbolic links."
    echo "Source: $PROMPT_LIB_DIR"
    echo ""
    echo "Target directories:"
    echo "  Claude: $CLAUDE_CONFIG_DIR"
    echo "  Cursor: $CURSOR_CONFIG_DIR"
    echo ""

    # Ask for confirmation
    read -p "Continue with installation? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        print_warning "Installation cancelled"
        exit 0
    fi

    # Install resources
    install_claude
    install_cursor

    # Show summary
    show_summary
}

# Run main function
main "$@"
