#!/bin/bash

set -ouex pipefail

# These come from ublue main
# https://github.com/ublue-os/main/blob/main/packages.json
sudo dnf5 remove -y htop nvtop adw-gtk3-theme

# Replace the logos
dnf5 swap -y fedora-logos generic-logos

bash /ctx/unblue_fedora.sh

# Install the os-release file
# This makes the bootc-builder unhappy
# ID=unblue
# ID_LIKE="fedora"
install -Dm0644 -t /usr/lib /ctx/os-release
# VERSION="${VERSION:-00.00000000}"
# echo "OSTREE_VERSION=\"${VERSION}"\" >>/usr/lib/os-release
