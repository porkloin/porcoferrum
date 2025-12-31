#!/bin/bash

set -ouex pipefail

# enable COPRs + other dnf shit
dnf5 -y copr enable codifryed/CoolerControl
dnf5 -y copr enable lizardbyte/beta
dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo

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

# enable units
systemctl enable coolercontrold.service
