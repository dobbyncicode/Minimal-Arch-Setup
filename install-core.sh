#!/bin/bash

# -- This script is written for my lazy-ass self and for me only -- #
# -- I am just too lazy to type everything so I made this once -- #
# -- IDC really if you think this is a bad code, it gets the job done for my use-case -- #

# -- Colors -- #
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# -- Keep sudo alive, I'm lazy to even interact with the tty -- #
echo -e "${BLUE}==> Requesting sudo access...${RESET}"
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &
trap "kill $!" EXIT

# -- Check yay. Idk, I'm too lazy to maybe think about building yay as a normal people does this -- #
echo -e "${BLUE}==> Checking for yay...${RESET}"
if ! command -v yay &>/dev/null; then
    echo -e "${YELLOW}==> yay not found. Building yay...${RESET}"
    mkdir -p ~/Builds && cd ~/Builds || exit 1
    if [ ! -d yay-bin ]; then
        git clone https://aur.archlinux.org/yay-bin.git || { echo -e "${RED}Failed to clone yay-bin repo.${RESET}"; exit 1; }
    fi
    cd yay-bin || exit 1
    makepkg -si --noconfirm >/dev/null 2>&1 || { echo -e "${RED}Failed to build yay.${RESET}"; exit 1; }
    cd ~ || exit 1
else
    echo -e "${GREEN}==> yay is already installed.${RESET}"
fi

# -- Fonts & Packages -- #
FONTS=(
    inter-font
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ttf-firacode-nerd
    ttf-jetbrains-mono-nerd
)

PACKAGES=(
    alsa-utils
    brave-bin
    fontconfig
    gvfs
    hyprland
    hyprpolkitagent
    hyprshot
    kitty
    libinput
    lxappearance
    matugen-bin
    mpv
    pavucontrol
    pipewire
    pipewire-pulse
    qt5ct
    qt6ct
    sddm
    swaync
    swww
    thunar
    ufw
    waybar
    wayland-protocols
    wofi
    wireplumber
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-user-dirs
    zsh
)

SERVICES=(
    sddm
)

# -- Install helper function -- #
install_pkg() {
    local pkg="$1"
    if yay -S "$pkg" >/dev/null 2>&1; then
        if yay -S --needed --noconfirm "$pkg" >/dev/null 2>&1; then
            echo -e "${GREEN}  ==> Installed: ${pkg}${RESET}"
        else
            echo -e "${RED}  ==> Failed to install: ${pkg}${RESET}"
        fi
    else
        echo -e "${RED}  ==> Package does not exist: ${pkg}${RESET}"
    fi
}

# -- Install packages -- #
echo -e "${BLUE}==> Installing core packages...${RESET}"
for package in "${PACKAGES[@]}"; do
    echo -e "${YELLOW} ==> Installing ${package}...${RESET}"
    install_pkg "$package"
done
echo -e "${GREEN}==> Core packages installed!${RESET}"

# -- Install fonts -- #
echo -e "${BLUE}==> Adding fonts...${RESET}"
for font in "${FONTS[@]}"; do
    echo -e "${YELLOW} ==> Adding ${font}...${RESET}"
    install_pkg "$font"
done
echo -e "${BLUE}==> Refreshing font cache...${RESET}"
sudo fc-cache -f >/dev/null 2>&1
echo -e "${GREEN}==> Fonts cache refreshed!${RESET}"

# -- Enable services -- #
echo -e "${BLUE}==> Enabling system services...${RESET}"
for service in "${SERVICES[@]}"; do
    echo -e "${YELLOW} ==> Enabling ${service}...${RESET}"
    if sudo systemctl enable --now "$service" >/dev/null 2>&1; then
        echo -e "${GREEN}  ==> Enabled: ${service}${RESET}"
    else
        echo -e "${RED}  ==> Failed to enable: ${service}${RESET}"
    fi
done
echo -e "${GREEN}==> System services enabled!${RESET}"
