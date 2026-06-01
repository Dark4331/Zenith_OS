#!/bin/bash

set -ouex pipefail

### 1. Installazione pacchetti di Zenith OS + Ambiente Niri (Wayland)

dnf install -y fastfetch git curl tmux niri swww waybar fuzzel mako foot

### 2. Preparazione cartella per lo Sfondo Nativo di Zenith OS
mkdir -p /usr/share/backgrounds/zenith
if [ -f /ctx/default.jpg ]; then
    cp /ctx/default.jpg /usr/share/backgrounds/zenith/default.jpg
fi


PLYMOUTH_DIR="/usr/share/plymouth/themes/spinner"
if [ -d "$PLYMOUTH_DIR" ]; then
   
    cp "$PLYMOUTH_DIR/watermark.png" "$PLYMOUTH_DIR/logo.png" || true
    cp "$PLYMOUTH_DIR/watermark.png" "$PLYMOUTH_DIR/bgrt-fallback.png" || true
fi

#### Abilitazione servizi di sistema indispensabili
systemctl enable podman.socket
