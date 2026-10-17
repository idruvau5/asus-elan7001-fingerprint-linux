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

# Use five fingerprint attempts within 60 seconds for sudo, boot login, and
# Cinnamon unlock. Keep package templates aligned with the active PAM stack.
for pam_file in /etc/pam.d/common-auth /usr/share/pam-configs/fprintd /usr/share/pam-configs/fingwit; do
  if [[ -f "$pam_file" ]]; then
    tmp=$(mktemp)
    sed -E 's/pam_fprintd\.so max-tries=[0-9]+ timeout=[0-9]+/pam_fprintd.so max-tries=5 timeout=60/g' "$pam_file" > "$tmp"
    sudo install -m 644 "$tmp" "$pam_file"
    rm -f "$tmp"
  fi
done

echo 'Installed. Close Fingwit before enrollment or verification.'
echo 'Fingerprint authentication allows five attempts with a 60-second window.'
echo 'Enroll with: fprintd-enroll -f right-middle-finger'
