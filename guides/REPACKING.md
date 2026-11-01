# Firmware Repacking

## Requirements
*The following packages need to be installed*
- 7zip (for `7z` command) (could probably use other tools instead)
- squashfs-tools (for `mksquashfs` command)
- cdrtools (for the `mkisofs` command)

## Scripts for Repacking
There is a script that does this automatically: [repack-helper.sh](/unpacking_and_repacking/repack-helper.sh). You just run it (no flags or anything), and follow the steps it gives you.

And if your device isn't one of the ones in the automatic repacker you can do one of the following:
1. You could add your device as a new folder in the [`/firmwares/`](/firmwares/) directory.
2. Or you could just use the generic unpacker script [`/scripts/unpack.sh`](/scripts/repack.sh), which should work for everything

The scripts should work for all devices using this type of firmware, so there's no need to manually repack.


## Steps for Manual Repacking
(TODO) for now, just look at the script
