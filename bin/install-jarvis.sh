#!/bin/bash

# Installs the Jarvis desktop assistant (https://github.com/quicexo28/jarvis-linux)
# on top of an existing Omarchy-on-CachyOS setup. Run this AFTER
# install-omarchy-on-cachyos.sh has completed and you have logged into Hyprland.
#
# What it does:
#  1) Clones (or updates) jarvis-linux into ~/jarvis-linux
#  2) Runs its Linux installer (pacman packages, npm deps, Python venv,
#     systemd user services: backend / stt / tts / wake / ui)
#  3) The installer wires Hyprland window rules + the Ctrl+Alt+J wake hotkey
#     into ~/.config/hypr/hyprland.conf

set -e

JARVIS_REPO="https://github.com/quicexo28/jarvis-linux.git"
JARVIS_DIR="$HOME/jarvis-linux"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git before running this script."
    exit 1
fi

# Warn if Hyprland config is not present yet (Omarchy not installed/logged in)
if [ ! -f "$HOME/.config/hypr/hyprland.conf" ]; then
    echo "Warning: ~/.config/hypr/hyprland.conf not found."
    echo "Jarvis will install, but the Hyprland hotkey/window rules will be skipped."
    echo "Run this script again after your first Omarchy login to wire them up."
    echo ""
fi

# Fetch or update jarvis-linux
if [ -d "$JARVIS_DIR/.git" ]; then
    echo "Updating existing Jarvis clone at $JARVIS_DIR..."
    git -C "$JARVIS_DIR" pull --ff-only
else
    echo "Cloning Jarvis to $JARVIS_DIR..."
    git clone "$JARVIS_REPO" "$JARVIS_DIR"
fi

# Run the Jarvis Linux installer
chmod +x "$JARVIS_DIR/scripts/linux/install.sh"
"$JARVIS_DIR/scripts/linux/install.sh"

echo ""
echo "Jarvis installation complete. Post-install checklist:"
echo " 1) Claude CLI: Jarvis answers via the 'claude' CLI. Install and log in:"
echo "      yay -S claude-code   (or: npm install -g @anthropic-ai/claude-code)"
echo " 2) Speaker enrollment: record at least one voice sample in the"
echo "    SpeakerIdPanel UI, otherwise all voice turns are ignored"
echo "    (speaker_confidence stays at 0)."
echo " 3) Set JARVIS_OWNER_SPEAKER in ~/.config/systemd/user/jarvis-backend.service"
echo "    to your enrolled speaker name, then: systemctl --user daemon-reload"
echo " 4) Start now (or just re-login):"
echo "      systemctl --user start jarvis-backend jarvis-stt jarvis-tts jarvis-ui"
echo " 5) Reload Hyprland to pick up the Ctrl+Alt+J wake hotkey: hyprctl reload"
