#!/usr/bin/env bash
#
# gum-research.sh
#
# Interactive research launcher using gum for a polished CLI experience.
# Prompts for research topic and mode, then formats a /research invocation.
#
# Dependencies: gum (https://github.com/charmbracelet/gum)
# Install: brew install gum
#

set -e

# Check for gum
if ! command -v gum &>/dev/null; then
    echo "Error: gum is not installed."
    echo "Install it with: brew install gum"
    echo "Or: go install github.com/charmbracelet/gum@latest"
    exit 1
fi

# Header
gum style \
    --foreground 212 --border-foreground 212 --border double \
    --align center --width 50 --margin "1 2" --padding "1 4" \
    "Research Assistant"

# Get research query
QUERY=$(gum input \
    --placeholder "What do you want to research?" \
    --prompt "> " \
    --width 60)

if [ -z "$QUERY" ]; then
    gum style --foreground 196 "No query provided. Exiting."
    exit 0
fi

# Select research modes
MODES=$(gum choose \
    --no-limit \
    --header "Select research modes (space to select, enter to confirm):" \
    "Web — articles, docs, GitHub, community" \
    "Codebase — existing implementations and patterns" \
    "Documentation — official API references and specs")

# Optional: focus area
FOCUS=$(gum input \
    --placeholder "Any specific focus or constraints? (optional)" \
    --prompt "> " \
    --width 60)

# Build the research prompt
PROMPT="Research: $QUERY"
if [ -n "$MODES" ]; then
    PROMPT="$PROMPT\n\nResearch modes: $MODES"
fi
if [ -n "$FOCUS" ]; then
    PROMPT="$PROMPT\n\nFocus: $FOCUS"
fi

# Confirm
echo ""
gum style --foreground 212 "Research query:"
echo "$PROMPT"
echo ""

if gum confirm "Start research?"; then
    gum spin --spinner dot --title "Launching research session..." -- sleep 1

    # Output the formatted prompt for use with Claude Code
    echo ""
    gum style --foreground 82 "Copy this into Claude Code:"
    echo ""
    echo "/research $QUERY"
    if [ -n "$FOCUS" ]; then
        echo ""
        echo "Focus: $FOCUS"
    fi
    if [ -n "$MODES" ]; then
        echo ""
        echo "Modes: $MODES"
    fi
else
    gum style --foreground 220 "Research cancelled."
fi
