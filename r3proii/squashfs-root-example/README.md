# squashfs-root-example

This directory contains a sample filesystem derived from the decompressed HiBy R3 Pro II flash image.

## Important Notes

- This folder is for reference and exploration only — it cannot be used to build firmware
- File permissions are incorrect (a limitation of git not preserving filesystem permissions) which means binaries like busybox would fail to execute
- Use the `unpack.sh` script in `unpacking_and_repacking/` to generate a proper `squashfs-root` directory with correct permissions for firmware building
- This folder may be useful as a reference for QEMU once board emulation support is complete

## What This Contains

A snapshot of the HiBy R3 Pro II root filesystem including:
- Init scripts (`/etc/init.d/`)
- OTA update scripts (`/etc/ota_bin/`)
- Hardware driver initialization scripts (`/module_driver/`)
- Resource files, fonts, and UI layouts (`/usr/resource/`)
- Key binaries (`/usr/bin/hiby_player`, `/usr/bin/sys_server`, etc.)
