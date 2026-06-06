#!/bin/bash

set -ouex pipefail

## DNF5 Speedup
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

## System apps
dnf install -y fastfetch 
dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# User apps
dnf -y install nautilus kitty mpv gnome-terminal gnome-system-monitor 

dnf install -y plymouth-plugin-script

# Nautilus open any terminal extension
curl -Lo /etc/yum.repos.d/nautilus-open-any-terminal.repo \
  https://copr.fedorainfracloud.org/coprs/monkeygold/nautilus-open-any-terminal/repo/fedora-$(rpm -E %fedora)/monkeygold-nautilus-open-any-terminal-fedora-$(rpm -E %fedora).repo
dnf install -y nautilus-open-any-terminal
glib-compile-schemas /usr/share/glib-2.0/schemas
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty

# Install Niri 
dnf -y install niri swaybg

# Install Dank Linux shell
curl --output-dir "/etc/yum.repos.d/" \
  --remote-name "https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-$(rpm -E %fedora)/avengemedia-dms-fedora-$(rpm -E %fedora).repo"
dnf -y install quickshell dms greetd dms-greeter --allowerasing 

# Install greetd login manager
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
cp -rf /ctx/dot_config/niri/config.kdl /etc/skel/.config/niri/config.kdl

mkdir -p /etc/skel/.config/kitty/
cp -rf /ctx/dot_config/kitty/dank-theme.conf /etc/skel/.config/kitty/dank-theme.conf

# ---- BRANDING: SETUP ----
mkdir -p /etc/fastfetch
mkdir -p /usr/share/backgrounds/zenith
cp -f /ctx/branding/logo.png /usr/share/plymouth/themes/spinner/watermark.png
cp -f /ctx/branding/logo.png /usr/share/pixmaps/origami-logo.png
cp -f /ctx/branding/logo.png /usr/share/quickshell/dms/assets/danklogonormal.svg
cp -f /ctx/branding/logo.png /usr/share/quickshell/dms-greeter/assets/danklogonormal.svg
cp -f /ctx/branding/logo.png /usr/share/pixmaps/origami-logo.svg
cp /ctx/branding/wallpaper.png /usr/share/backgrounds/zenith/default.jpg
cp /ctx/branding/ascii-logo.txt /etc/fastfetch/zenith_ascii.txt
cp /ctx/branding/config.jsonc /etc/fastfetch/config.jsonc
#-*--------
mkdir -p /etc/dracut.conf.d
echo 'add_drivers+=" vboxvideo "' > /etc/dracut.conf.d/vbox.conf
#-----------
mkdir -p /etc/plymouth
cat > /etc/plymouth/plymouthd.conf << EOF
[Daemon]
Theme=hexagon
ShowDelay=0
DeviceTimeout=8
EOF
#---------

cp -f /ctx/branding/plymouthd.defaults /usr/share/plymouth/plymouthd.defaults
mkdir -p /usr/share/plymouth/themes/hexagon/
cp -rf /ctx/hexagon/. /usr/share/plymouth/themes/hexagon/
ln -sf /usr/share/plymouth/themes/hexagon/hexagon.plymouth /usr/share/plymouth/themes/default.plymouth

sed -i 's/auto-mode/manual/g' /usr/share/plymouth/themes/bgrt/bgrt.plymouth
# Regenerate dracut for boot changes
dracut --regenerate-all --force || true
echo 'GRUB_DISABLE_OS_PROBER="true"' >> /etc/default/grub
# Enable podman socket
systemctl enable podman.socket

# Disable Origami tips
mv /etc/profile.d/origami-aliases.sh /etc/profile.d/origami-aliases.sh.bak || true

# Remove COSMIC shell and waybar
dnf -y remove cosmic-comp cosmic-initial-setup cosmic-settings cosmic-settings-daemon cosmic-store waybar

# Clean up DNF cache to reduce image size
dnf5 -y clean all
rm -rf /run/dnf /run/selinux-policy
rm -rf /var/lib/dnf
