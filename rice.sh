#!/usr/bin/env bash

# ── Colors ────────────────────────────────────────────────
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"

# ── Config ────────────────────────────────────────────────
REPO_DIR="$HOME/Builds/Minimal-Arch-Setup"
SRC_CONFIG="$REPO_DIR/config"
DEST_CONFIG="$HOME/.config"

LOGFILE="$REPO_DIR/rice_errors.log"
SUCCESS_LINKS=()
FAILED_LINKS=()

# ── Functions ─────────────────────────────────────────────
print_section() {
    local title=$1 color=$2
    echo
    printf "${BOLD}${color}── %s ──${RESET}\n" "$title"
}

progress_bar() {
    local current=$1 total=$2 item=$3
    local percent=$((current * 100 / total))
    local width=30
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    local bar="$(printf "%${filled}s" "" | tr ' ' "=")$(printf "%${empty}s" "")"

    printf "\r\033[K${BLUE}[${bar}]${RESET} %3d%%  ${YELLOW}(%s)${RESET}" \
        "$percent" "$item"
}

link_configs() {
    local configs=($(ls -1 "$SRC_CONFIG"))
    local total=${#configs[@]}
    local current=0

    print_section "Linking Configs" "$YELLOW"
    for item in "${configs[@]}"; do
        current=$((current+1))
        progress_bar "$current" "$total" "$item"

        src="$SRC_CONFIG/$item"
        dest="$DEST_CONFIG/$item"

        mkdir -p "$DEST_CONFIG"

        if ln -sfn "$src" "$dest" 2>>"$LOGFILE"; then
            SUCCESS_LINKS+=("$item")
        else
            FAILED_LINKS+=("$item")
            echo "--- Failed to link $item ---" >> "$LOGFILE"
        fi
    done
    echo
    printf "${GREEN}✓ Config linking complete.${RESET}\n"
}

report_summary() {
    echo
    printf "${BOLD}=== Rice Summary ===${RESET}\n"

    if [ ${#SUCCESS_LINKS[@]} -gt 0 ]; then
        print_section "Linked Configs" "$GREEN"
        for i in "${SUCCESS_LINKS[@]}"; do
            printf "  • %s\n" "$i"
        done
    fi

    if [ ${#FAILED_LINKS[@]} -gt 0 ]; then
        print_section "Failed Configs" "$RED"
        for i in "${FAILED_LINKS[@]}"; do
            printf "  • %s\n" "$i"
        done
        printf "\n${YELLOW}See details in:${RESET} %s\n" "$LOGFILE"
    fi
}

# ── Main ─────────────────────────────────────────────────
clear
printf "${BOLD}${BLUE}Arch Hyprland Auto-Rice (Config Linking)${RESET}\n"
: > "$LOGFILE"

link_configs
report_summary

printf "\n${GREEN}✨ Dotfiles linked! Time to enjoy the rice.${RESET}\n"
