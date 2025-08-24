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
IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://$IMAGE_REGISTRY/$IMAGE_NAME"

cat >$IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-registry": "$IMAGE_REGISTRY",
  "image-ref": "$IMAGE_REF",
  "image-tag": "$IMAGE_TAG"
}
EOF

# Fix issues caused by ID no longer being fedora
sed -i "s|^EFIDIR=.*|EFIDIR=\"fedora\"|" /usr/sbin/grub2-switch-to-blscfg
