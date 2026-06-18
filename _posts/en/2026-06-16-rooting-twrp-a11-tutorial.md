---
layout: post
title: Root & Install TWRP Samsung Galaxy A11 (SM-A115F) — Android 12
lang: en
lang-ref: rooting-twrp-a11
category:
  - tutorial
  - android
  - samsung
---

## Introduction

This tutorial covers the steps to **root** (Magisk) and **install TWRP** on a Samsung Galaxy A11 SM-A115F with **Android 12 (XXS6CWK2)** firmware. All steps are done from **Linux** using **Heimdall** and **ADB** — no Odin/Windows needed.

> ⚠️ **Disclaimer**: All risks are your own. Back up important data before starting.

## Device Specifications

| Item | Detail |
|------|--------|
| Model | SM-A115F (a11q) |
| SoC | Qualcomm Snapdragon 450 (SDM450) |
| RAM | 2GB / 3GB |
| Stock OS | Android 12 (One UI Core 4.1) |
| Firmware | A115FXXS6CWK2 |
| Bootloader | Unlocked (flash.locked=0) |
| Partition | A-only (not VAB) |

## Prerequisites

### Software
- **Linux** (Ubuntu/Debian/Arch) with sudo access
- **Heimdall** v1.4.2+ or v2.x
- **ADB & Fastboot**
- **Python 3** + `lz4` module
- **Magisk app** (download from [github.com/topjohnwu/Magisk](https://github.com/topjohnwu/Magisk/releases))

### Install Dependencies

**Ubuntu / Debian:**
```bash
sudo apt update
sudo apt install -y heimdall-flash adb fastboot python3-pip lz4
pip3 install lz4
```

**Arch Linux:**
```bash
sudo pacman -S --needed heimdall android-tools python-pip lz4
pip install lz4
```

### Required Files

**Provided in this tutorial's assets:**
- [`vbmeta_stock_patched.img`](./assets/posts/rooting-twrp-a11/vbmeta_stock_patched.img) — 8.5 KB
- [`magisk_patched-30700_opHBq.img`](./assets/posts/rooting-twrp-a11/magisk_patched-30700_opHBq.img) — 64 MB
- [`twrp-3.7.0_afaneh92-a11q.tar`](./assets/posts/rooting-twrp-a11/twrp-3.7.0_afaneh92-a11q.tar) — 33 MB
- [`recovery.img`](./assets/posts/rooting-twrp-a11/recovery.img) (TWRP) — 33 MB
- [`flash_twrp.sh`](./assets/posts/rooting-twrp-a11/flash_twrp.sh) — 7 KB

**Required from external / create yourself:**
- **Stock firmware** `AP_*.tar.md5` (~3.6 GB) — download from [SamFW](https://samfw.com/firmware/SM-A115F)
- **`stock_boot.img`** — extract from firmware (see §2)
- **`magisk_patched-*.img`** (64 MB) — patch via Magisk app (see §2)

---

## §0. Unlock Bootloader

Make sure the bootloader is unlocked:

1. **Settings → Developer Options → OEM Unlock** → **ON**
2. **Settings → About Phone → Software Information → Tap Build Number 7x** (to enable Developer Options)
3. Turn off the phone, enter **Download Mode**: `Vol Down + Vol Up` + plug in USB
4. On the Download Mode screen, **hold Vol Up for 7 seconds** until "Unlocking bootloader..." appears
5. Data will be wiped automatically
6. Phone reboots to system

> ⚠️ If OEM Unlock doesn't appear: make sure date & time are synced (Settings → General Management → Date and Time → Automatic date and time). Incorrect time hides the Developer Options toggle.

Verify:
```bash
adb shell "getprop ro.boot.flash.locked"
# Should: 0
adb shell "getprop ro.boot.verifiedbootstate"
# Should: orange
```

---

## §1. Patch vbmeta (Disable AVB)

AVB (Android Verified Boot) will refuse to boot a modified image. We patch byte 123 from `0x00` to `0x03` (VBMETA_VERIFICATION_DISABLE).

### Extract vbmeta from firmware
```bash
# Extract from AP tar
tar -xf AP_A115FXXS6CWK2_*.tar.md5 vbmeta.img.lz4

# Decompress lz4
python3 -c "
import lz4.block
with open('vbmeta.img.lz4', 'rb') as f:
    with open('vbmeta.img', 'wb') as out:
        out.write(lz4.block.decompress(f.read()))
"
```

### Patch byte 123 = 0x03
```bash
python3 << 'PYEOF'
with open('vbmeta.img', 'rb') as f:
    data = bytearray(f.read())
print(f"Size: {len(data)} bytes, Byte@123 before: 0x{data[123]:02x}")
data[123] = 0x03
with open('vbmeta_stock_patched.img', 'wb') as f:
    f.write(data)
print(f"Byte@123 after: 0x{data[123]:02x}")
PYEOF
```

**Result:** `vbmeta_stock_patched.img` (4096 bytes) — exact size, no overflow.

---

## §2. Root with Magisk

### Extract boot.img from firmware
```bash
tar -xf AP_A115FXXS6CWK2_*.tar.md5 boot.img.lz4

python3 -c "
import lz4.block
with open('boot.img.lz4', 'rb') as f:
    with open('stock_boot.img', 'wb') as out:
        out.write(lz4.block.decompress(f.read()))
"
```

### Patch with Magisk
```bash
# Push stock boot to phone
adb push stock_boot.img /sdcard/

# Install Magisk app
adb install Magisk-v27.0.apk
```

1. Open **Magisk app** on the phone
2. Tap **"Select and Patch a File"**
3. Select `/sdcard/stock_boot.img`
4. Wait until done — result: `magisk_patched-*.img` in `/sdcard/Download/`

### Pull patched result
```bash
adb pull /sdcard/Download/magisk_patched-*.img .
```

---

## §3. Flash vbmeta + Boot via Heimdall

This is the **most critical** step. Order must be correct.

### Enter Download Mode
```bash
adb reboot download
```

### Flash vbmeta (disable AVB)
```bash
heimdall flash --VBMETA vbmeta_stock_patched.img
```

### Flash Magisk-patched boot (root)
```bash
heimdall flash --BOOT magisk_patched-30700_opHBq.img
```

### Reboot
```bash
heimdall reboot
```

Verify root:
```bash
adb shell "su -c 'id -u'"
# Should: 0
# Note: on first run, a dialog will appear on the phone —
# open Magisk app → Superuser → Grant permission for ADB shell.
# If not granted, output will be empty or "Permission denied".
```

---

## §4. Flash TWRP via ADB

After root, we can flash TWRP directly from ADB without heimdall.

### Download the correct TWRP
```bash
# Download from this tutorial's assets, or from GitHub mirror
# wget https://github.com/3xp-l01t/Samsung-Galaxy-A115U1-Unofficial-TWRP/raw/refs/heads/main/twrp_images/twrp-3.7.0_afaneh92-a11q.tar

tar xvf ../assets/posts/rooting-twrp-a11/twrp-3.7.0_afaneh92-a11q.tar
# Output: recovery.img (33MB)
```

### Run the TWRP flash script
```bash
bash flash_twrp.sh
```

The script will:
1. Check ADB connection & root
2. Check security properties (flash.locked, verifiedbootstate, kgstate)
3. Push `recovery.img` to `/data/local/tmp/`
4. Backup & disable `recovery-from-boot.p`
6. Check recovery partition size
7. `dd` TWRP to recovery partition (`mmcblk0p61`)
8. Verify flash
9. **Reboot to TWRP (DO NOT boot to system!)**

### What to do in TWRP

```bash
# The script will auto-reboot to recovery.
# In TWRP:
```

1. **Wipe → Format Data** → type `yes` (⚠️ deletes all internal data)
2. **Reboot → Recovery** (verify TWRP is still there)
3. **Reboot → System**

> ⚠️ If stock recovery gets restored, repeat the TWRP flash from §4.

---

## §5. Troubleshooting

### "Only official released binaries are allowed"
- **KG state is prenormal**: wait 7 days + WiFi + Samsung account
- **Bootloader relocked**: unlock via Download Mode (Vol Up 7 seconds)
- **Binary revision mismatch**: make sure boot.img is from the SAME firmware

### Bootloop after flashing TWRP
```bash
# Enter TWRP: Vol Up + Power (hold)
# In TWRP: Format Data → reboot
```

### TWRP doesn't appear / stock recovery boots
TWRP is being restored by `recovery-from-boot.p`. Fix:
```bash
adb shell "su -c 'mount -o rw,remount /system && rm -f /system/etc/recovery-from-boot.p /system/bin/install-recovery.sh'"
```
Then redo the TWRP flash from §4.

### vbmeta overflow (boot verify image failed)
If `vbmeta_stock_patched.img` is larger than 4096 bytes, flashing it will corrupt neighboring partitions. Fix:
```bash
heimdall flash --VBMETA vbmeta_stock.img --VBMETABAK vbmeta_stock.img --DTBO dtbo.img
```

### "Security error" after boot
```bash
# Check status
adb shell "getprop ro.boot.flash.locked"     # should be 0
adb shell "getprop ro.boot.verifiedbootstate" # should be orange
adb shell "getprop ro.boot.warranty_bit"      # should be empty
```
If Warranty Bit = 1, the device has tripped eFuse — cannot permanently unlock.

---

## Reference Links

| Link | Purpose |
|------|---------|
| [XDA TWRP Thread](https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-a11-snapdragon.4197085/) | Official TWRP by afaneh92 |
| [GitHub 3xp-l01t Mirror](https://github.com/3xp-l01t/Samsung-Galaxy-A115U1-Unofficial-TWRP) | TWRP + vbmeta + Magisk downloads |
| [SamFW Firmware](https://samfw.com/firmware/SM-A115F) | Stock firmware downloads |
| [Magisk GitHub](https://github.com/topjohnwu/Magisk) | Root solution |
| [TrebleDroid Wiki](https://github.com/TrebleDroid/treble_experimentations/wiki/Samsung-Galaxy-A11) | Device-specific GSI info |
| [Telegram Group](https://t.me/samsung_galaxy_m01_a01_m11_a11) | A11/M11 community |

---

## Credits

- **afaneh92** — TWRP builder & XDA maintainer
- **3xp-l01t** — GitHub mirror of TWRP + files
- **topjohnwu** — Magisk
- Samsung Open Source Center — Kernel source

---

*This tutorial was written from hands-on experience with SM-A115F firmware XXS6CWK2. For devices with different firmware, some steps may need adjustment.*
