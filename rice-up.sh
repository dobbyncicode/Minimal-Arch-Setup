#!/usr/bin/env bash
# ──────────────────────────────
# Recursive symlink deploy for Hyprland & co
# Overrides any existing files/folders
# ──────────────────────────────

set -e

# -- Colors -- #
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# ──────────────────────────────
# Directories
# ──────────────────────────────
SOURCE_DIR="$(pwd)/config"
TARGET_DIR="$HOME/.config"

echo -e "${BLUE}Starting symlink deployment...${RESET}"

mkdir -p "$TARGET_DIR"

# ──────────────────────────────
# Recursive linking function
# ──────────────────────────────
link_recursive() {
    local src="$1"
    local dest="$2"

    for item in "$src"/*; do
        local base=$(basename "$item")
        local dest_item="$dest/$base"

        # Remove existing file or folder if exists
        if [ -e "$dest_item" ] || [ -L "$dest_item" ]; then
            rm -rf "$dest_item"
            echo -e "${RED}Removed existing:${RESET} $dest_item"
        fi

        if [ -d "$item" ]; then
            mkdir -p "$dest_item"
            echo -e "${YELLOW}Processing directory:${RESET} $dest_item"
            link_recursive "$item" "$dest_item"
        else
            ln -s "$item" "$dest_item"
            echo -e "${GREEN}Linked:${RESET} $item -> $dest_item"
        fi
    done
}

# ──────────────────────────────
# Execute
# ──────────────────────────────
link_recursive "$SOURCE_DIR" "$TARGET_DIR"

echo -e "${BLUE}Symlink deployment complete!${RESET}"
