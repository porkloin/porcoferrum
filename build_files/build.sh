#!/usr/bin/env bash
set -xeuo pipefail

dnf5 -y copr enable codifryed/CoolerControl
dnf5 install -y coolercontrol liquidctl
dnf5 -y copr disable codifryed/CoolerControl

dnf -y copr enable bieszczaders/kernel-cachyos
dnf -y copr disable bieszczaders/kernel-cachyos

dnf5 -y --enablerepo=copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos \
  install \
  kernel-cachyos \
  kernel-cachyos-devel-matched

KERNEL_VERSION="$(ls /usr/lib/modules | sort -V | tail -n1)"
KERNEL_SRC="/usr/src/kernels/${KERNEL_VERSION}"

echo "== Target kernel: ${KERNEL_VERSION} =="

if [[ ! -d "${KERNEL_SRC}" ]]; then
  echo "ERROR: Missing kernel headers at ${KERNEL_SRC}"
  exit 1
fi

git clone --depth=1 https://github.com/dlundqvist/xone /tmp/xone
pushd /tmp/xone

make -C "${KERNEL_SRC}" M="$PWD" modules
make -C "${KERNEL_SRC}" M="$PWD" modules_install

popd

depmod -a "${KERNEL_VERSION}"

if ! find "/usr/lib/modules/${KERNEL_VERSION}" -iname 'xone*.ko*' | grep -q .; then
  echo "ERROR: xone module not installed"
  exit 1
fi

curl -Lo /usr/local/bin/scopebuddy \
  https://raw.githubusercontent.com/HikariKnight/ScopeBuddy/refs/heads/main/bin/scopebuddy
chmod +x /usr/local/bin/scopebuddy
ln -sf scopebuddy /usr/local/bin/scb

systemctl enable coolercontrold.service
