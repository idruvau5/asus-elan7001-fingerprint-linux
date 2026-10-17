#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO=https://github.com/goodix-fp-linux-dev/libfprint.git
COMMIT=07306bbc9256942595e31fb0f407b364ffa24d07
[[ $EUID -ne 0 ]] || { echo 'Run as your normal user, not sudo.' >&2; exit 1; }
command -v sudo >/dev/null && command -v apt-get >/dev/null || { echo 'sudo and apt-get are required.' >&2; exit 1; }
sudo apt-get update
sudo apt-get install -y build-essential meson ninja-build pkg-config git ca-certificates libglib2.0-dev libgusb-dev libusb-1.0-0-dev libpam0g-dev libopencv-dev doctest-dev fprintd libpam-fprintd
work=$(mktemp -d /tmp/elan-fprint.XXXXXX); trap 'rm -rf "$work"' EXIT
git clone --branch sigfm --single-branch "$REPO" "$work/libfprint"
git -C "$work/libfprint" checkout --detach "$COMMIT"
git -C "$work/libfprint" apply "$ROOT/patches/elanspi-touch.patch"
meson setup "$work/build" "$work/libfprint" --prefix=/opt/libfprint-sigfm -Dbuildtype=debugoptimized -Ddrivers=all
ninja -C "$work/build"
sudo ninja -C "$work/build" install
sudo install -d -m 755 /etc/systemd/system/fprintd.service.d
sudo install -m 644 "$ROOT/config/fprintd-elanspi.conf" /etc/systemd/system/fprintd.service.d/10-elanspi-sigfm.conf
sudo systemctl daemon-reload
sudo systemctl restart fprintd
echo 'Installed. Close Fingwit before enrollment or verification.'
echo 'Enroll with: fprintd-enroll -f right-middle-finger'
