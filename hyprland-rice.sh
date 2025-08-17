#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────
#  Config Values
# ──────────────────────────────
USER="dobbyncicode"
REPO="Minimal-Arch-Setup"
BRANCH="main"
ROOT_PATH="Configs/Hyprland"
API_URL="https://api.github.com/repos/$USER/$REPO/git/trees/$BRANCH?recursive=1"
RAW_BASE="https://raw.githubusercontent.com/$USER/$REPO/$BRANCH/$ROOT_PATH"
TARGET_DIR="$HOME/.config/hypr"

# ──────────────────────────────
#  Prevent Root
# ──────────────────────────────
if [ "$EUID" -eq 0 ]; then
    echo "⚠ Do not run as root. Exiting."
    exit 1
fi

# ──────────────────────────────
#  Fetch File Tree
# ──────────────────────────────
echo "→ Fetching file list from GitHub..."
file_list=$(curl -s "$API_URL" \
  | grep "\"path\": \"${ROOT_PATH}/" \
  | cut -d '"' -f4)

# ──────────────────────────────
#  Sync Files
# ──────────────────────────────
echo "→ Syncing files to $TARGET_DIR..."
for filepath in $file_list; do
  rel="${filepath#${ROOT_PATH}/}"
  dest="$TARGET_DIR/$rel"
  mkdir -p "$(dirname "$dest")"
  echo "↓ Downloading: $rel"
  curl -fsSL "$RAW_BASE/$rel" -o "$dest"
  [[ "$rel" == *.sh ]] && chmod +x "$dest"
done

# ──────────────────────────────
#  Final Sanity Check
# ──────────────────────────────
if [ ! -f "$TARGET_DIR/hyprland.conf" ]; then
  echo "✖ Missing hyprland.conf — sync failed."
  exit 1
fi

echo "✔ Sync complete! Files are in $TARGET_DIR"
