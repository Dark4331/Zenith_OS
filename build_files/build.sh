#!/bin/bash

set -ouex pipefail

### Install packages
# Sostituito hyprpaper con swaybg (garantito nei repo ufficiali Fedora)
dnf install -y fastfetch git curl tmux niri swaybg waybar fuzzel mako foot

#### Abilita i servizi di sistema necessari
systemctl enable podman.socket
