#!/bin/bash

# Config
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
TRANSITIONS=("fade" "wipe" "grow" "outer")
TRANSITION="${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}"
DURATION="1"
POSITION="center"
BEZIER=".2,0,.4,1"

# Check wallpapers exist
if ! ls "$WALLPAPER_DIR"/*.{jpg,png} >/dev/null 2>&1; then
    notify-send "❌ No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Pick wallpaper
SELECTED=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) \
    | sed "s|$WALLPAPER_DIR/||" \
    | sort \
    | wofi --dmenu --prompt "🌄 Choose wallpaper" --insensitive)

# Apply
if [[ -n "$SELECTED" ]]; then
    [ -x "$(command -v matugen)" ] && matugen image "$WALLPAPER_DIR/$SELECTED"
    swww img "$WALLPAPER_DIR/$SELECTED" \
        --transition-type "$TRANSITION" \
        --transition-duration "$DURATION" \
        --transition-pos "$POSITION" \
        --transition-bezier "$BEZIER"
fi
