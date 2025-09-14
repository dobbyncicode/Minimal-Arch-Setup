#!/usr/bin/env bash

# ── Colors ────────────────────────────────────────────────
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
BOLD="\e[1m"
RESET="\e[0m"

# ── Config ────────────────────────────────────────────────
FONTS=(
    nerd-fonts-inter
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ttf-firacode-nerd
    ttf-jetbrains-mono-nerd
)

PACKAGES=(
    alsa-utils
    blueprint-compiler
    brave-bin
    cli11
    dbus
    fontconfig
    gobject-introspection
    glib2
    gtk4
    gtk4-layer-shell
    granite7
    gvfs
    hyprland
    hyprpolkitagent
    hyprshot
    json-glib
    kitty
    kvantum
    libdrm
    libpipewire
    libinput
    libgee
    lxappearance
    matugen-bin
    mesa
    meson
    mpv
    pam
    pavucontrol
    pkg-config
    pipewire
    pipewire-pulse
    qt5ct
    qt6ct
    qt6-base
    qt6-5compat
    qt6-declarative
    qt6-imageformats
    qt6-multimedia
    qt6-wayland
    qt6-shadertools
    qt6-svg
    quickshell
    sassc
    scdoc
    sddm
    spirv-tools
    swaync
    swww
    thunar
    ufw
    unzip
    vala
    waybar
    wayland
    wayland-protocols
    wofi
    wireplumber
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-user-dirs
    zip
    zsh
)

SERVICES=( sddm )

# ── Globals ──────────────────────────────────────────────
LOGDIR="$(dirname "$0")/../logs"
LOGFILE="$LOGDIR/install_errors.log"
SUCCESS_PKGS=()
FAILED_PKGS=()
SUCCESS_FONTS=()
FAILED_FONTS=()

# ── Functions ─────────────────────────────────────────────
progress_bar() {
    local current=$1 total=$2 pkg=$3
    local percent=$((current * 100 / total))
    local width=30
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    local FILL="="
    local bar="$(printf "%${filled}s" "" | tr ' ' "$FILL")$(printf "%${empty}s" "")"

    printf "\r\033[K${BLUE}[${bar}]${RESET} %3d%%  ${YELLOW}(%s)${RESET}" \
        "$percent" "$pkg"
}

update_system() {
    print_section "Updating System" "$YELLOW"
    if sudo pacman -Syu --noconfirm >/dev/null 2>>"$LOGFILE"; then
        printf "${GREEN}✓ System packages updated.${RESET}\n"
    else
        printf "${RED}✗ Failed updating system packages (see log).${RESET}\n"
    fi

    if yay -Syu --noconfirm >/dev/null 2>>"$LOGFILE"; then
        printf "${GREEN}✓ AUR packages updated.${RESET}\n"
    else
        printf "${RED}✗ Failed updating AUR packages (see log).${RESET}\n"
    fi
}

install_list() {
    local type=$1; shift
    local list=("$@")
    local total=${#list[@]}
    local current=0

    print_section "Installing $type" "$YELLOW"
    for pkg in "${list[@]}"; do
        current=$((current+1))
        progress_bar "$current" "$total" "$pkg"

        if yay -S --noconfirm --needed "$pkg" >/dev/null 2>>"$LOGFILE"; then
            if pacman -Q "$pkg" &>/dev/null; then
                if [[ "$type" == "fonts" ]]; then
                    SUCCESS_FONTS+=("$pkg")
                else
                    SUCCESS_PKGS+=("$pkg")
                fi
            else
                if [[ "$type" == "fonts" ]]; then
                    FAILED_FONTS+=("$pkg")
                else
                    FAILED_PKGS+=("$pkg")
                fi
                {
                    echo "--- Failed (not found after yay): $pkg ---"
                    echo
                } >> "$LOGFILE"
            fi
        else
            if [[ "$type" == "fonts" ]]; then
                FAILED_FONTS+=("$pkg")
            else
                FAILED_PKGS+=("$pkg")
            fi
            {
                echo "--- Failed (yay error): $pkg ---"
                echo
            } >> "$LOGFILE"
        fi
    done

    echo
    printf "${GREEN}✓ %s installation complete.${RESET}\n" "$type"

    if [[ "$type" == "fonts" ]]; then
        printf "${YELLOW}→ Updating font cache...${RESET}\n"
        if sudo -n fc-cache -fv >/dev/null 2>>"$LOGFILE"; then
            printf "${GREEN}✓ Font cache updated.${RESET}\n"
        else
            printf "${RED}✗ Failed updating font cache (see log).${RESET}\n"
        fi
    fi
}

enable_services() {
    print_section "Enabling Services" "$YELLOW"
    for svc in "${SERVICES[@]}"; do
        printf "→ %s... " "$svc"
        if sudo -n systemctl enable "$svc" >/dev/null 2>>"$LOGFILE"; then
            printf "${GREEN}enabled${RESET}\n"
        else
            printf "${RED}failed${RESET}\n"
        fi
    done
}

print_section() {
    local title=$1 color=$2
    echo
    printf "${BOLD}${color}── %s ──${RESET}\n" "$title"
}

list_pretty() {
    local arr=($(printf "%s\n" "$@" | sort))
    local cols=3 i=0
    for pkg in "${arr[@]}"; do
        printf "  • %-20s" "$pkg"
        ((++i % cols == 0)) && echo
    done
    ((i % cols)) && echo
}

report_summary() {
    echo
    printf "${BOLD}=== Installation Summary ===${RESET}\n"

    if [ ${#SUCCESS_PKGS[@]} -gt 0 ]; then
        print_section "Installed Packages" "$GREEN"
        list_pretty "${SUCCESS_PKGS[@]}"
    fi
    if [ ${#FAILED_PKGS[@]} -gt 0 ]; then
        print_section "Failed Packages" "$RED"
        list_pretty "${FAILED_PKGS[@]}"
        printf "\n${YELLOW}See details in:${RESET} %s\n" "$LOGFILE"
    fi

    if [ ${#SUCCESS_FONTS[@]} -gt 0 ]; then
        print_section "Installed Fonts" "$GREEN"
        list_pretty "${SUCCESS_FONTS[@]}"
    fi
    if [ ${#FAILED_FONTS[@]} -gt 0 ]; then
        print_section "Failed Fonts" "$RED"
        list_pretty "${FAILED_FONTS[@]}"
    fi
}

# ── Main ─────────────────────────────────────────────────
clear
printf "${BOLD}${BLUE}Arch Hyprland Auto-Rice Installer${RESET}\n"

sudo -v || { echo "Need sudo privileges"; exit 1; }

# ensure Logs directory exists
mkdir -p "$LOGDIR"

{
    echo "=== Installation Log - $(date '+%Y-%m-%d %I:%M:%S %p') ==="
    echo
} > "$LOGFILE"

update_system
install_list "packages" "${PACKAGES[@]}"
install_list "fonts" "${FONTS[@]}"
enable_services
report_summary

printf "\n${GREEN}All done! Reboot and enjoy your rice.${RESET}\n"
