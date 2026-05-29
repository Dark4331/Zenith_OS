#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 
dnf install -y fastfetch git curl tmux

mkdir -p /usr/share/backgrounds/zenith
cp /ctx/default.jpg /usr/share/backgrounds/zenith/default.jpg

# Forza lo sfondo Zenith OS per tutti gli utenti
mkdir -p /usr/share/glib-2.0/schemas
cat <<EOF > /usr/share/glib-2.0/schemas/10_zenith_background.gschema.override
[org.gnome.desktop.background]
picture-uri='file:///usr/share/backgrounds/zenith/default.jpg'
picture-uri-dark='file:///usr/share/backgrounds/zenith/default.jpg'
EOF

# Compila i nuovi schemi di GNOME
glib-compile-schemas /usr/share/glib-2.0/schemas/

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
