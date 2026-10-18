# ASUS ELAN7001 press fingerprint driver for Linux

This repository contains the device-specific Linux driver build for the ASUS VivoBook X530FN/S530FN fingerprint reader.

Hardware covered:

- Laptop: ASUS VivoBook X530FN/S530FN
- ACPI/SPI device: `ELAN7001`
- Fingerprint sensor: ELAN eFSA96SA, 96x96 class
- Touchpad HID companion: `04f3:3087`
- Capture mode: Windows-style press/touch; no swipe
- Linux stack: `fprintd` plus a SIGFM-enabled libfprint build

The installer clones the pinned `goodix-fp-linux-dev/libfprint` `sigfm` branch, applies the press-mode patch, builds it under `/opt/libfprint-sigfm`, and configures fprintd to use it. It captures the complete native 96x96 press frame, throttles idle polling, and resets the sensor when capture ownership ends. This preserves more fingerprint keypoints and prevents the Linux wait-up polling loop that previously triggered the ELAN thermal guard.

It also configures five fingerprint attempts within 60 seconds for sudo, boot login, and Cinnamon screen unlock, with password fallback after the attempts are exhausted.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/idruvau5/asus-elan7001-fingerprint-linux/v0.1.4/install.sh -o /tmp/install-elan-fingerprint.sh
bash /tmp/install-elan-fingerprint.sh
```

Then enroll one finger, with Fingwit and other fingerprint clients closed:

```bash
fprintd-enroll -f right-middle-finger
fprintd-list "$USER"
fprintd-verify
```

Use the same finger for every enrollment stage. Lift completely for two seconds between touches; the narrow sensor needs overlapping, centered placements.

## Limitations

The Windows matcher is proprietary. This package uses the open SIGFM matcher with the press capture flow reconstructed from the official ASUS Windows package. It is device-specific and should not be installed on unrelated fingerprint hardware.
