#!/bin/bash

# ──────────────────────────────
# Config
# ──────────────────────────────
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
TRANSITIONS=("fade" "wipe" "grow" "outer")
TRANSITION="${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}"
DURATION="1"
POSITION="center"
BEZIER=".2,0,.4,1"

# ──────────────────────────────
# Check wallpapers exist
# ──────────────────────────────
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) | sort)
if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
    notify-send "❌ No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# ──────────────────────────────
# Pick wallpaper
# ──────────────────────────────
SELECTED=$(printf '%s\n' "${WALLPAPERS[@]}" \
    | sed "s|$WALLPAPER_DIR/||" \
    | wofi --dmenu --prompt "🌄 Choose wallpaper" --insensitive)

# ──────────────────────────────
# Apply wallpaper
# ──────────────────────────────
if [[ -n "$SELECTED" ]]; then
    FILE="$WALLPAPER_DIR/$SELECTED"
    [ -x "$(command -v matugen)" ] && matugen image "$FILE"
    swww img "$FILE" \
        --transition-type "$TRANSITION" \
        --transition-duration "$DURATION" \
        --transition-pos "$POSITION" \
        --transition-bezier "$BEZIER"
fi
