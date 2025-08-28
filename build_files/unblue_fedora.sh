#!/bin/bash

set -ouex pipefail

# Revert all the modifications fedora does to GNOME here

# Remove fedora backgrounds and install the gnome ones
dnf5 remove -y fedora-backgrounds fedora-workstation-background desktop-backgrounds-gnome f*-backgrounds*
dnf5 install -y gnome-backgrounds

# Get rid of schema overrides
# Remove gnome-software fedora configuration
# Begone are the Fedora logos and backgrounds
# The GDM config has enable-smartcard-authentication false for some reason
# Mutter features are marked experimental, enable them at your own
rm /usr/share/glib-2.0/schemas/org.gnome.software-fedora.gschema.override
rm /usr/share/glib-2.0/schemas/org.gnome.login-screen.gschema.override
# Comes from the background pkg we removed
# rm /usr/share/glib-2.0/schemas/10_org.gnome.desktop.background.fedora.gschema.override
# rm /usr/share/glib-2.0/schemas/10_org.gnome.desktop.screensaver.fedora.gschema.override
rm /usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override
rm /usr/share/glib-2.0/schemas/00_org.gnome.shell.gschema.override
rm /usr/share/glib-2.0/schemas/org.gnome.mutter.fedora.gschema.override
glib-compile-schemas /usr/share/glib-2.0/schemas

# Remove shell extensions and classic session, including the fedora logo
dnf5 remove -y gnome-classic-session gnome-shell-extension*

# Use the gnome default
dnf5 remove -y ptyxis
dnf5 install -y gnome-console

dnf remove -y firefox

# Remove restyling of KDE apps to pretend to be Adwaita cause someone
# missed the memo of not messing with the apps by default
flatpak mask \
    org.kde.KStyle.Adwaita \
    org.kde.PlatformTheme.QGnomePlatform \
    org.kde.WaylandDecoration.QAdwaitaDecorations \
    org.kde.WaylandDecoration.QGnomePlatform-decoration

dnf5 install -y sysprof-cli sysprof-agent sysprof

# FIXME: rebuild nautilus without the ptyxis patch

# Remove gnome-tour fedora logo
# Fuck this copr is unworkable, I am not spending a minute more on this dumpster fire
# will just replace the gresources file instead
install -Dm644 /ctx/gnome-tour.resources.gresource "/usr/share/gnome-tour/resources.gresource"

# Use upstream mime apps from gnome-session
# and make sure we have epiphany->firefox and console->ptyxis
# Main for now cause we only added this in 49.
curl -L -o mimeapps.list https://gitlab.gnome.org/GNOME/gnome-session/-/raw/main/data/gnome-mimeapps.list
install -Dm0644 -t /usr/share/applications/ mimeapps.list

# Install logos
install -Dm644 -t "/usr/share/pixmaps" /ctx/logos/gnome-boot-logo.png
install -Dm644 -t "/usr/share/pixmaps" /ctx/logos/gnome_brandmark.png
install -Dm644 -t "/usr/share/pixmaps" /ctx/logos/gnome_brandmark.svg
install -Dm644 /ctx/logos/gnome_brandmark.png "/usr/share/pixmaps/fedora-logo-small.png"
install -Dm644 /ctx/logos/gnome_brandmark.png "/usr/share/pixmaps/fedora-logo.png"
install -Dm644 /ctx/logos/gnome_brandmark.svg "/usr/share/pixmaps/fedora-logo-sprite.svg"
install -Dm644 /ctx/logos/gnome_brandmark.svg "/usr/share/icons/hicolor/scalable/apps/gnome-logo-icon.svg"
install -Dm644 /ctx/logos/org.gnome.Installer.svg "/usr/share/icons/hicolor/scalable/apps/org.gnome.Installer.svg"
install -Dm644 /ctx/logos/adwaita-triangles.svg "/usr/share/icons/hicolor/scalable/apps/adwaita-triangles.svg"
install -Dm644 /ctx/logos/adwaita-triangles.png "/usr/share/icons/hicolor/512x512/apps/adwaita-triangles.png"
install -Dm644 -t "/usr/share/pixmaps" /ctx/logos/ctx/logos/adwaita-triangles.png
install -Dm644 -t "/usr/share/pixmaps" /ctx/logos/ctx/logos/adwaita-triangles.svg
gtk-update-icon-cache --quiet /usr/share/icons/hicolor/

install -Dm644 /ctx/logos/gnome-boot-logo.png "/usr/share/plymouth/themes/spinner/watermark.png"
# Change plymouth settings
# curl -L -o plymouthd.defaults https://gitlab.gnome.org/GNOME/gnome-build-meta/-/raw/master/files/plymouth/plymouthd.defaults
cat >plymouthd.defaults <<EOF
[Daemon]
Theme=bgrt
ShowDelay=0
DeviceTimeout=8
EOF
install -Dm644 plymouthd.defaults "/usr/share/plymouth/plymouthd.defaults"

# regen initramfs
bash /ctx/initramfs.sh
