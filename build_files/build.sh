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

dnf5 install -y /var/tmp/akmods-rpms/ublue-os/ublue-os-akmods*.rpm

dnf5 install -y /var/tmp/akmods-rpms/kmods/kmod-xone*.rpm

# Clean up the copied RPM payload (optional, keeps image smaller)
rm -rf /var/tmp/akmods-rpms

# xone dongle firmware is a fucking nightmare.
# i guess the firmware looks for specific hardware revisions,
# so we have to get the firmware into the correct location
# for a bunch of random hardware revisions.
# Probably could be in a user systemd unit or something idk
FWDIR="/usr/lib/firmware"

if [[ -f "${FWDIR}/xow_dongle.bin" ]]; then
  install -Dpm0644 "${FWDIR}/xow_dongle.bin" "${FWDIR}/xone_dongle_02fe.bin"
else
  echo "WARNING: ${FWDIR}/xow_dongle.bin not found; xone dongle firmware may not be installed."
fi

if [[ -f "${FWDIR}/xow_dongle_045e_02e6.bin" ]]; then
  install -Dpm0644 "${FWDIR}/xow_dongle_045e_02e6.bin" "${FWDIR}/xone_dongle_02e6.bin"
  install -Dpm0644 "${FWDIR}/xow_dongle_045e_02e6.bin" "${FWDIR}/xone_dongle_045e_02e6.bin"
fi

ls -l "${FWDIR}"/xow_dongle*.bin "${FWDIR}"/xone_dongle*.bin 2>/dev/null || true

# disable COPRs
dnf5 -y copr disable codifryed/CoolerControl
dnf5 -y copr disable lizardbyte/beta
dnf5 -y copr disable avengemedia/dms-git
dnf5 -y copr disable ublue-os/bazzite

# Scopebuddy
curl -Lo /usr/local/bin/scopebuddy https://raw.githubusercontent.com/HikariKnight/ScopeBuddy/refs/heads/main/bin/scopebuddy
chmod +x /usr/local/bin/scopebuddy
ln -sf scopebuddy /usr/local/bin/scb

# enable units
systemctl enable coolercontrold.service
