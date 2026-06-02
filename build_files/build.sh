#!/bin/bash

set -ouex pipefail

## DNF5 Speedup
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

## System apps
dnf install -y fastfetch

# User apps
dnf -y install nautilus kitty mpv gnome-terminal gnome-system-monitor



# Nautilus open any terminal extension
curl -Lo /etc/yum.repos.d/nautilus-open-any-terminal.repo \
  https://copr.fedorainfracloud.org/coprs/monkeygold/nautilus-open-any-terminal/repo/fedora-$(rpm -E %fedora)/monkeygold-nautilus-open-any-terminal-fedora-$(rpm -E %fedora).repo
dnf install -y nautilus-open-any-terminal
glib-compile-schemas /usr/share/glib-2.0/schemas
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty


# Install Niri 
dnf -y install niri swaybg

# # Install Noctalia shell
# curl -fsSL https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo -o /etc/yum.repos.d/terra.repo
# dnf -y install terra-release
# dnf -y install noctalia-shell 
# # ABILITARE LE NOTIFICHE: systemctl --user enable --now swaync.service

# Install Dank Linux shell
sudo curl --output-dir "/etc/yum.repos.d/" \
  --remote-name "https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-$(rpm -E %fedora)/avengemedia-dms-fedora-$(rpm -E %fedora).repo"
dnf -y install quickshell dms greetd dms-greeter --allowerasing 
#
# Install greetd login manager with dank configuration (still needs some work)
mkdir -p /etc/greetd/
cat > /etc/greetd/config.toml << EOF
[terminal]
vt = 2
[default_session]
user = "greeter"
command = "dms-greeter --command niri"
EOF
rm -f /etc/systemd/system/display-manager.service
ln -s /usr/lib/systemd/system/greetd.service /etc/systemd/system/display-manager.service
systemctl enable --force greetd.service

mkdir -p /etc/skel/.config/systemd/user/graphical-session.target.wants
ln -s /usr/lib/systemd/user/dms.service /etc/skel/.config/systemd/user/graphical-session.target.wants/
mkdir -p /etc/skel/.config/niri/
cp -rf /ctx/dot_config/niri/config.kdl /etc/skel/.config/niri/

# ---- BRANDING: BOOTLOGO (PLYMOUTH) ----
# Sovrascriviamo il logo di sistema usato alla fine del boot
cp -f /ctx/branding/logo.png /usr/share/pixmaps/system-logo-white.png

# Sovrascriviamo il logo/watermark in TUTTI i temi Plymouth installati nel sistema.
# Rimuoviamo il || true qui: se la cartella /ctx/branding non esiste, la build DEVE bloccarsi.
for tema in /usr/share/plymouth/themes/*/; do
    if [ -d "$tema" ]; then
        cp -f /ctx/branding/logo.png "${tema}watermark.png" || true
        cp -f /ctx/branding/logo.png "${tema}logo.png" || true
    fi
done

# ---- BRANDING: WALLPAPER ----
mkdir -p /usr/share/backgrounds/zenith
cp -f /ctx/branding/wallpaper.png /usr/share/backgrounds/zenith/default.png

# ---- BRANDING: FASTFETCH ASCII ART ----
mkdir -p /usr/share/zenith
cp -f /ctx/branding/ascii-logo.txt /usr/share/zenith/ascii-logo.txt

# Generiamo la configurazione globale per tutti gli utenti
mkdir -p /etc/fastfetch
cat > /etc/fastfetch/config.jsonc << 'EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "/usr/share/zenith/ascii-logo.txt",
        "padding": {
            "right": 2
        }
    },
    "modules": [
        "title",
        "separator",
        "os",
        "host",
        "kernel",
        "uptime",
        "packages",
        "shell",
        "display",
        "de",
        "wm",
        "terminal",
        "cpu",
        "gpu",
        "memory"
    ]
}
EOF

# ---- OPERAZIONI DI SISTEMA (Mantieni pure || true qui per sicurezza nel container) ----
dracut --regenerate-all --force || true

#### Enable podman
systemctl enable podman.socket

# Disable Origami tips
sudo mv /etc/profile.d/origami-aliases.sh /etc/profile.d/origami-aliases.sh.bak || true

# Remove COSMIC shell and waybar
dnf -y remove cosmic-comp cosmic-initial-setup cosmic-settings cosmic-settings-daemon cosmic-store waybar

## CLEAN UP
dnf5 -y clean all
rm -rf /run/dnf /run/selinux-policy
rm -rf /var/lib/dnf
