#!/bin/bash

set -ouex pipefail

### Install packages
# Installazione pulita e sicura di tutti i pacchetti di Zenith OS e dell'ambiente Niri
dnf install -y fastfetch git curl tmux niri hyprpaper waybar fuzzel mako foot

#### Abilita i servizi di sistema necessari
systemctl enable podman.socket
