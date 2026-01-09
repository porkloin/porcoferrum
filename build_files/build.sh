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
