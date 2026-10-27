
# Generic Guide for R1/R3 Devices

Most of it also applies to other Hiby based devices like the TempoTec
Variations v1.

## Before you start

If you can boot the recovery mode (Vol+ and power key), you don’t need
to follow this guide. Just place the correct upt file in the root of
your SD and recover using the recovery mode.

## What you need

- Cloner (cloner-2.5.80.2-windows_alpha or cloner-2.5.80.2-ubuntu_alpha).
    Heads up when you open the cloner the reported version is different
    from the one in the archive, this is expected (it will show 2.5.58.6).
    Provided in this repo in the **tools** folder.

- For windows users: Cloner driver (cloner-win32-driver)
    Included in the cloner zip.

- A recovery image (the upt file is missing u-boot, the recovery kernel
    and recovery rootfs so that is not enough). They are provided in this
    repo.
    Both have been updated to work with the 2.5.80.2 version of the cloner.
    Provided in the **\<player name\>/firmware/recovery_cloner** folder.

    Currently images for the R1, R3 II 2025 and TempoTec Variations v1
    are available in this repo.

- Know the bootrom key combo (for example the R1 uses the next track key)

- Accepting that this will reset your device to factory settings, so all
    your customizations/settings will be lost.

## How to recovery your Hiby in case of a brick

1. Make sure your player is off, hold the next track button and plug it
    to your PC. For windows PCs you need to install the cloner driver.
    If your player doesn’t show up you can try to hold the power button
    and the next track button till it shows up.

2. If you succeeded there should be a libusb-win32 device section in
    your device manager with an "usb cloner device".

    ![device_manager](/resources/guides/UNBRICKING.md/device_manager.png)

3. Next, you will need to unpack the cloner, and open the cloner.exe.
    In the bottom right corner there’s a combo box that allows you to
    select the language, pick English.

    ![cloner_step1](/resources/guides/UNBRICKING.md/cloner_step1.png)

4. Now click "Load Image" and select the recovery image you downloaded
    before.

    ![cloner_step2](/resources/guides/UNBRICKING.md/cloner_step2.png)

5. Just press "Start", if all went well your device should now start to
    be flashed. It takes 1 minute or so. After its done your player will
    reboot and you are done!

    ![cloner_step3](/resources/guides/UNBRICKING.md/cloner_step3.png)

### How it should progress

1. Loading 1st and 2nd preloaders, checking if your device matches the
    supplied config and erasing the NAND.
    ![cloner_progress_1](/resources/guides/UNBRICKING.md/cloner_step4_prog1.png)

2. Flashing the boot loader, kernel and rootfs images.
    ![cloner_progress_2](/resources/guides/UNBRICKING.md/cloner_step4_prog2.png)

3. Successful flash, device reboots.
    ![cloner_progress_3](/resources/guides/UNBRICKING.md/cloner_step4_prog3.png)

## Troubleshooting

### Device not detected

If the cloner just shows you this, make sure you have the drivers
installed and your device is plugged in (check device manager).
![cloner_waiting](/resources/guides/UNBRICKING.md/cloner_waiting.png)

### Wrong loaders

If you get SoC detection errors or similar (check screenshot
bellow) you will need to update the loaders in your recovery
package with the ones that come with the cloner you are trying
to use, check Additional Notes for information how to accomplish
that.

![cloner_error1](/resources/guides/UNBRICKING.md/cloner_error1.png)
![cloner_error2](/resources/guides/UNBRICKING.md/cloner_error2.png)

## Additional Notes

### Adapting existing recovery packages

If you have a recovery package that doesn’t work with your cloner
version, eg you are facing a SoC detection error for example,
this can easily be fixed.

You need to modify the recovery package with 7z and replace the
files in the firmwares/x1600 folder with the ones that come with
the cloner tool you are trying to use (config.cfg, spl.bin,
uboot.bin), these files are also located in the firmwares/x1600
folder in the cloner folder. Check bellow for more details on
the recovery file structure.

### Recovery file structure (.zip/.ingenic)

The recovery file is just a regular zip file.

```
├───configs (SoC configs, multiple can exist in the archive)
│   │   mac_device.cfg
│   │   nandinfo.cfg
│   │   platforms.cfg    (This file points to the right config inside the x1600 folder)
│   │   rules.cfg
│   │   sn_device.cfg
│   │   spiflashinfo.cfg (Configs for the spi flash chips)
│   │
│   └───x1600 (again multiple configs can be present)
│           x16xx_sfc_nand_linux.cfg (Actual config for the device, Includes DDR type, partition table and what to flash)
|
├───ddrs (DDR configs, just leave it as is)
|
├───firmwares (loaders for the Ingenic SoCs, they need to match with the ones the cloner is bundled with)
│   └───x1600 (loaders for the x1600 SoC)
│       config.cfg (config for the SoC, including CPU and RAM frequency)
│       spl.bin    (1st stage loader, loaded to ram during flashing)
│       uboot.bin  (2nd stage loader, loaded to ram during flashing)
|
├───images (Images that will get flashed to the Hiby nand)
│       kernel.bin       (main kernel to be loaded, can be Hiby's or a custom firmware, xImage in the upt files)
│       kernel2.bin      (recovery kernel, used for OTA updates and the Vol+ update/recovery mode)
│       rootfs.squashfs  (main os root file system)
│       rootfs2.squashfs (recovery os file system)
│       u-boot.bin       (u-boot loader)
|
└───security (something likely related to secure boot, Hiby is not using this)
```

For more details check the Ingenic documentation provided with the cloner.

### Preloading a custom firmware

You can replace the kernel.bin and rootfs.squashfs files with the ones
from your favorite custom firmware. So you can also recovery and flash
your custom firmware in one go.

### Advanced settings

For advanced users, you can unlock advanced options by setting the
lock level to 0 and typing the following password "!@#". This exposes
a lot of potentially dangerous options, if you break your device you
get to keep the pieces.
