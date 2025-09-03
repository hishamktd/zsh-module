#!/usr/bin/env zsh
# Clipboard utilities for Git module

# Helper function to copy text to clipboard
copy_to_clipboard() {
    local text="$1"
    
    # Detect clipboard utility
    if command -v pbcopy >/dev/null; then
        # macOS
        echo -n "$text" | pbcopy
        return 0
    elif command -v xclip >/dev/null; then
        # Linux with xclip
        echo -n "$text" | xclip -selection clipboard
        return 0
    elif command -v xsel >/dev/null; then
        # Linux with xsel
        echo -n "$text" | xsel --clipboard --input
        return 0
    elif command -v wl-copy >/dev/null; then
        # Wayland
        echo -n "$text" | timeout 3s wl-copy 2>/dev/null
        return 0
    else
        # No clipboard utility found
        return 1
    fi
}

# Copy text to clipboard with user feedback
copy_with_feedback() {
    local text="$1"
    local description="${2:-Text}"
    
    if copy_to_clipboard "$text"; then
        echo "$(zmod_color green "📋 $description copied to clipboard:") $text"
        return 0
    else
        echo "$(zmod_color yellow "🔗 $description:") $text"
        echo "$(zmod_color dim '(Clipboard utility not available)')"
        return 1
    fi
}