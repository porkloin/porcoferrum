#!/bin/bash

set -ouex pipefail

# enable COPRs + other dnf shit
dnf5 -y copr enable codifryed/CoolerControl
dnf5 -y copr enable lizardbyte/beta
dnf5 -y copr enable avengemedia/dms-git
dnf5 -y copr enable ublue-os/bazzite
dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo

# fresh DMS regardless of zirc upstream updates
dnf5 -y \
  --enablerepo copr:copr.fedorainfracloud.org:avengemedia:dms-git \
  --enablerepo copr:copr.fedorainfracloud.org:avengemedia:danklinux \
  distro-sync \
  --setopt=install_weak_deps=False \
  dms \
  dms-cli \
  dms-greeter \
  dgop \
  dsearch

# install extra shit
dnf5 install -y \
  tmux \
  coolercontrol \
  liquidctl \
  steam \
  gamescope \
  mangohud \
  Sunshine

if [[ ! -d /var/tmp/akmods-rpms ]]; then
  echo "ERROR: /var/tmp/akmods-rpms not present; akmods COPY stage failed."
  exit 1
fi

# xone
dnf5 install -y /var/tmp/akmods-rpms/ublue-os/ublue-os-akmods*.rpm
dnf5 install -y /var/tmp/akmods-rpms/kmods/kmod-xone*.rpm

# xone firmware shit
dnf5 install -y curl cabextract

curl -fsSL \
  https://raw.githubusercontent.com/medusalix/xone/main/install/firmware.sh \
  -o /usr/local/bin/xone-get-firmware.sh

chmod +x /usr/local/bin/xone-get-firmware.sh

xone-get-firmware.sh

# disable COPRs
dnf5 -y copr disable codifryed/CoolerControl
dnf5 -y copr disable lizardbyte/beta
dnf5 -y copr disable avengemedia/dms-git
dnf5 -y copr disable ublue-os/bazzite

# Scopebuddy
curl -Lo /usr/local/bin/scopebuddy https://raw.githubusercontent.com/HikariKnight/ScopeBuddy/refs/heads/main/bin/scopebuddy
chmod +x /usr/local/bin/scopebuddy
ln -s scopebuddy /usr/local/bin/scb

# enable units
systemctl enable coolercontrold.service
