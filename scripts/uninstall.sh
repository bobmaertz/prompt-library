#!/usr/bin/env bash
#
# Prompt Library Uninstaller
#
# Removes symbolic links created by the installer.
# Does not remove backup files.
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

# Function to remove symlink if it points to prompt library
remove_symlink() {
    local link_path="$1"
    local description="$2"

    if [ -L "$link_path" ]; then
        local target=$(readlink "$link_path")
        # Check if the symlink points to our prompt library
        if [[ "$target" == "$PROMPT_LIB_DIR"* ]]; then
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

# Function to remove directory if empty
remove_if_empty() {
    local dir_path="$1"
    if [ -d "$dir_path" ] && [ -z "$(ls -A "$dir_path")" ]; then
        rmdir "$dir_path"
        print_info "Removed empty directory: $dir_path"
    fi
}

# Function to uninstall Claude Code resources
uninstall_claude() {
    print_header "Uninstalling Claude Code Resources"

    local removed=0

    # Remove skills
    if [ -d "$CLAUDE_CONFIG_DIR/skills" ]; then
        for skill_link in "$CLAUDE_CONFIG_DIR/skills"/*; do
            if [ -e "$skill_link" ] || [ -L "$skill_link" ]; then
                skill_name=$(basename "$skill_link")
                if remove_symlink "$skill_link" "Skill: $skill_name"; then
                    ((removed++))
                fi
            fi
        done
        remove_if_empty "$CLAUDE_CONFIG_DIR/skills"
    fi

    # Remove commands
    if [ -d "$CLAUDE_CONFIG_DIR/commands" ]; then
        for command_link in "$CLAUDE_CONFIG_DIR/commands"/*; do
            if [ -e "$command_link" ] || [ -L "$command_link" ]; then
                command_name=$(basename "$command_link")
                if remove_symlink "$command_link" "Command: $command_name"; then
                    ((removed++))
                fi
            fi
        done
        remove_if_empty "$CLAUDE_CONFIG_DIR/commands"
    fi

    # Remove hooks
    if [ -d "$CLAUDE_CONFIG_DIR/hooks" ]; then
        for hook_link in "$CLAUDE_CONFIG_DIR/hooks"/*; do
            if [ -e "$hook_link" ] || [ -L "$hook_link" ]; then
                hook_name=$(basename "$hook_link")
                if remove_symlink "$hook_link" "Hook: $hook_name"; then
                    ((removed++))
                fi
            fi
        done
        remove_if_empty "$CLAUDE_CONFIG_DIR/hooks"
    fi

    # Remove prompts directory link
    if remove_symlink "$CLAUDE_CONFIG_DIR/prompts" "Prompts directory"; then
        ((removed++))
    fi

    if [ $removed -eq 0 ]; then
        print_info "No Claude Code symlinks found to remove"
    fi
}

# Function to uninstall Cursor resources
uninstall_cursor() {
    print_header "Uninstalling Cursor Resources"

    local removed=0

    # Remove rules
    if [ -d "$CURSOR_CONFIG_DIR/rules" ]; then
        for rule_link in "$CURSOR_CONFIG_DIR/rules"/*; do
            if [ -e "$rule_link" ] || [ -L "$rule_link" ]; then
                rule_name=$(basename "$rule_link")
                if remove_symlink "$rule_link" "Rule: $rule_name"; then
                    ((removed++))
                fi
            fi
        done
        remove_if_empty "$CURSOR_CONFIG_DIR/rules"
    fi

    # Remove prompts directory link
    if remove_symlink "$CURSOR_CONFIG_DIR/prompts" "Prompts directory"; then
        ((removed++))
    fi

    if [ $removed -eq 0 ]; then
        print_info "No Cursor symlinks found to remove"
    fi
}

# Function to show uninstallation summary
show_summary() {
    print_header "Uninstallation Summary"

    echo "Removed all symlinks pointing to: $PROMPT_LIB_DIR"
    echo ""

    # Check for backup files
    local claude_backups=$(find "$CLAUDE_CONFIG_DIR" -name "*.backup.*" 2>/dev/null | wc -l)
    local cursor_backups=$(find "$CURSOR_CONFIG_DIR" -name "*.backup.*" 2>/dev/null | wc -l)

    if [ $claude_backups -gt 0 ] || [ $cursor_backups -gt 0 ]; then
        print_warning "Backup files were left in place:"
        if [ $claude_backups -gt 0 ]; then
            echo "  Claude: $claude_backups backup(s) in $CLAUDE_CONFIG_DIR"
        fi
        if [ $cursor_backups -gt 0 ]; then
            echo "  Cursor: $cursor_backups backup(s) in $CURSOR_CONFIG_DIR"
        fi
        echo ""
        print_info "You can manually review and remove these backups if desired."
    fi

    echo ""
    print_success "Uninstallation complete!"
    echo ""
    print_info "The prompt library repository at $PROMPT_LIB_DIR"
    print_info "has not been modified and can be safely deleted if desired."
}

# Main uninstallation
main() {
    print_header "Prompt Library Uninstaller"

    echo "This will remove all symbolic links pointing to the prompt library."
    echo "Source: $PROMPT_LIB_DIR"
    echo ""
    echo "Target directories:"
    echo "  Claude: $CLAUDE_CONFIG_DIR"
    echo "  Cursor: $CURSOR_CONFIG_DIR"
    echo ""
    echo "Note: Backup files will be preserved."
    echo ""

    # Ask for confirmation
    read -p "Continue with uninstallation? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        print_warning "Uninstallation cancelled"
        exit 0
    fi

    # Uninstall resources
    uninstall_claude
    uninstall_cursor

    # Show summary
    show_summary
}

# Run main function
main "$@"
