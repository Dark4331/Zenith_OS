# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM registry.gitlab.com/origami-linux/images/origami-nvidia:latest

RUN sed -i '/^NAME=/d;/^PRETTY_NAME=/d;/^ID=/d;/^VARIANT_ID=/d' /usr/lib/os-release

RUN echo '' >> /usr/lib/os-release && \
    echo 'NAME="Zenith OS"' >> /usr/lib/os-release && \
    echo 'PRETTY_NAME="Zenith OS"' >> /usr/lib/os-release && \
    echo 'ID=fedora' >> /usr/lib/os-release && \
    echo 'VARIANT_ID=bootc' >> /usr/lib/os-release

RUN ln -sf ../usr/lib/os-release /etc/os-release
## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.


# Copy Homebrew files from the brew image
# And enable
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /usr/bin/systemctl preset brew-setup.service && \
    /usr/bin/systemctl preset brew-update.timer && \
    /usr/bin/systemctl preset brew-upgrade.timer


RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

RUN dnf install -y niri swww waybar fuzzel mako foot

COPY branding/watermark.png /usr/share/plymouth/themes/spinner/watermark.png

COPY branding/watermark.png /usr/share/plymouth/themes/spinner/animation.png || true
COPY branding/watermark.png /usr/share/plymouth/themes/spinner/background.png || true
RUN plymouth-set-default-theme spinner
RUN dracut --regenerate-all --force

RUN mkdir -p /usr/share/backgrounds/zenith_os
COPY branding/default-wallpaper.png /usr/share/backgrounds/zenith_os/default-wallpaper.png

RUN mkdir -p /etc/skel/.config/niri
COPY branding/config.kdl /etc/skel/.config/niri/config.kdl

RUN mkdir -p /etc/fastfetch
COPY branding/zenith_ascii.txt /etc/fastfetch/zenith_ascii.txt
COPY branding/config.jsonc /etc/fastfetch/config.jsonc

