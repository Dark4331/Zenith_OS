#!/bin/bash

set -ouex pipefail

### Install packages
# Installazione pulita e sicura di tutti i pacchetti di Zenith OS e dell'ambiente Niri
dnf install -y fastfetch git curl tmux niri hyprpaper waybar fuzzel mako foot

#### Abilita i servizi di sistema necessari
systemctl enable podman.socket

# Configurazione dello sfondo personalizzato
mkdir -p /usr/share/backgrounds/zenith
cp /ctx/default.jpg /usr/share/backgrounds/zenith/default.jpg

# Forza lo sfondo Zenith OS per tutti gli utenti (Dark e Light mode)
mkdir -p /usr/share/glib-2.0/schemas
cat <<EOF > /usr/share/glib-2.0/schemas/10_zenith_background.gschema.override
[org.gnome.desktop.background]
picture-uri='file:///usr/share/backgrounds/zenith/default.jpg'
picture-uri-dark='file:///usr/share/backgrounds/zenith/default.jpg'
EOF

# Compila i nuovi schemi di GNOME
glib-compile-schemas /usr/share/glib-2.0/schemas/

#### Example for enabling a System Unit File
systemctl enable podman.socket
