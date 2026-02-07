#!/usr/bin/env bash
set -xeuo pipefail

rm -f /etc/profile.d/gamerslop.sh

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

dnf5 install -y bsdtar
cd /tmp/xone
./install/firmware.sh --skip-disclaimer

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

# Build and install hgaiser's gamescope fork (required for Moonshine)
echo "== Building gamescope-moonshine =="

dnf5 install -y --skip-unavailable \
  cmake gcc gcc-c++ git-core meson ninja-build \
  glm-devel google-benchmark-devel libXcursor-devel libXmu-devel \
  spirv-headers-devel stb_image-devel stb_image-static \
  stb_image_resize-devel stb_image_resize-static \
  stb_image_write-devel stb_image_write-static \
  hwdata-devel libavif-devel libcap-devel libdecor-devel \
  libdisplay-info-devel libdrm-devel libeis-devel \
  libliftoff-devel pipewire-devel systemd-devel \
  luajit-devel SDL2-devel vulkan-headers vulkan-loader-devel \
  wayland-protocols-devel wayland-devel \
  wlroots-devel libxkbcommon-devel xorg-x11-server-Xwayland-devel \
  libX11-devel libXcomposite-devel libXdamage-devel libXext-devel \
  libXfixes-devel libXrender-devel libXres-devel libXtst-devel libXxf86vm-devel \
  glslang

git clone --depth=1 --branch=moonshine https://github.com/hgaiser/gamescope /tmp/gamescope-moonshine
pushd /tmp/gamescope-moonshine

git submodule update --init --depth=1
meson setup build/ -Dprefix=/usr -Dpipewire=enabled
ninja -C build/
meson install -C build/ --skip-subprojects

popd

# Verify gamescope-moonshine was installed
if ! /usr/bin/gamescope --help | head -1; then
  echo "ERROR: gamescope installation failed"
  exit 1
fi

systemctl enable coolercontrold.service
