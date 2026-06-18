---
layout: post
title: Cara Root & Install TWRP Samsung Galaxy A11 (SM-A115F) — Android 12
lang: id
lang-ref: rooting-twrp-a11
category:
  - tutorial
  - android
  - samsung
---

## Pendahuluan

Tutorial ini berisi langkah-langkah **root** (Magisk) dan **install TWRP** di Samsung Galaxy A11 SM-A115F dengan firmware **Android 12 (XXS6CWK2)**. Semua proses dikerjakan dari **Linux** menggunakan **Heimdall** dan **ADB** — tidak perlu Odin/Windows.

> ⚠️ **Disclaimer**: Semua resiko ditanggung sendiri. Backup data penting sebelum memulai.

## Spesifikasi Device

| Item | Detail |
|------|--------|
| Model | SM-A115F (a11q) |
| SoC | Qualcomm Snapdragon 450 (SDM450) |
| RAM | 2GB / 3GB |
| Stock OS | Android 12 (One UI Core 4.1) |
| Firmware | A115FXXS6CWK2 |
| Bootloader | Unlocked (flash.locked=0) |
| Partisi | A-only (bukan VAB) |

## Prasyarat

### Software
- **Linux** (Ubuntu/Debian/Arch) dengan akses sudo
- **Heimdall** v1.4.2+ atau v2.x
- **ADB & Fastboot**
- **Python 3** + `lz4` module
- **Magisk app** (unduh dari [github.com/topjohnwu/Magisk](https://github.com/topjohnwu/Magisk/releases))

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

### Files yang Diperlukan

**Disediakan di assets tutorial ini:**
- [`vbmeta_stock_patched.img`](./assets/posts/rooting-twrp-a11/vbmeta_stock_patched.img) — 8.5 KB
- [`magisk_patched-30700_opHBq.img`](./assets/posts/rooting-twrp-a11/magisk_patched-30700_opHBq.img) — 64 MB
- [`twrp-3.7.0_afaneh92-a11q.tar`](./assets/posts/rooting-twrp-a11/twrp-3.7.0_afaneh92-a11q.tar) — 33 MB
- [`recovery.img`](./assets/posts/rooting-twrp-a11/recovery.img) (TWRP) — 33 MB
- [`flash_twrp.sh`](./assets/posts/rooting-twrp-a11/flash_twrp.sh) — 7 KB

**Diperlukan dari eksternal / buat sendiri:**
- **Stock firmware** `AP_*.tar.md5` (~3.6 GB) — unduh dari [SamFW](https://samfw.com/firmware/SM-A115F)
- **`stock_boot.img`** — ekstrak dari firmware (lihat §2)
- **`magisk_patched-*.img`** (64 MB) — patch via Magisk app (lihat §2)

---

## §0. Unlock Bootloader

Pastikan bootloader sudah di-unlock:

1. **Settings → Developer Options → OEM Unlock** → **ON**
2. **Settings → About Phone → Software Information → Tap Build Number 7x** (untuk enable Developer Options)
3. Matikan phone, masuk **Download Mode**: `Vol Down + Vol Up` + colok USB
4. Di layar Download Mode, **tekan Vol Up lama (7 detik)** sampai muncul "Unlocking bootloader..."
5. Data akan terhapus otomatis
6. Phone reboot ke system

> ⚠️ Jika OEM Unlock tidak muncul: pastikan tanggal & waktu sudah sinkron (Settings → General Management → Date and Time → Automatic date and time). Time yang salah bikin opsi Developer Options disembunyikan.

Verifikasi:
```bash
adb shell "getprop ro.boot.flash.locked"
# Harus: 0
adb shell "getprop ro.boot.verifiedbootstate"
# Harus: orange
```

---

## §1. Patch vbmeta (Disable AVB)

AVB (Android Verified Boot) akan nolak boot image yang dimodifikasi. Kita patch byte ke-123 dari `0x00` jadi `0x03` (VBMETA_VERIFICATION_DISABLE).

### Ekstrak vbmeta dari firmware
```bash
# Ekstrak dari AP tar
tar -xf AP_A115FXXS6CWK2_*.tar.md5 vbmeta.img.lz4

# Decompress lz4
python3 -c "
import lz4.block
with open('vbmeta.img.lz4', 'rb') as f:
    with open('vbmeta.img', 'wb') as out:
        out.write(lz4.block.decompress(f.read()))
"
```

### Patched byte 123 = 0x03
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

**Hasil:** `vbmeta_stock_patched.img` (4096 bytes) — ukuran tepat, tidak overflow.

---

## §2. Root dengan Magisk

### Ekstrak boot.img dari firmware
```bash
tar -xf AP_A115FXXS6CWK2_*.tar.md5 boot.img.lz4

python3 -c "
import lz4.block
with open('boot.img.lz4', 'rb') as f:
    with open('stock_boot.img', 'wb') as out:
        out.write(lz4.block.decompress(f.read()))
"
```

### Patch dengan Magisk
```bash
# Push stock boot ke phone
adb push stock_boot.img /sdcard/

# Install Magisk app
adb install Magisk-v27.0.apk
```

1. Buka **Magisk app** di phone
2. Tap **"Select and Patch a File"**
3. Pilih `/sdcard/stock_boot.img`
4. Tunggu selesai — hasil: `magisk_patched-*.img` di `/sdcard/Download/`

### Pull hasil patch
```bash
adb pull /sdcard/Download/magisk_patched-*.img .
```

---

## §3. Flash vbmeta + Boot via Heimdall

Ini adalah langkah yang **paling kritis**. Urutan harus benar.

### Masuk Download Mode
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

Verifikasi root:
```bash
adb shell "su -c 'id -u'"
# Harus: 0
# Catatan: saat pertama kali jalan, akan muncul dialog di phone —
# buka Magisk app → Superuser → Grant permission untuk ADB shell.
# Kalo gak di-grant, output kosong atau "Permission denied".
```

---

## §4. Flash TWRP via ADB

Setelah root, kita bisa flash TWRP langsung dari ADB tanpa heimdall.

### Download TWRP yang benar
```bash
# Unduh dari assets tutorial ini, atau dari GitHub mirror
# wget https://github.com/3xp-l01t/Samsung-Galaxy-A115U1-Unofficial-TWRP/raw/refs/heads/main/twrp_images/twrp-3.7.0_afaneh92-a11q.tar

tar xvf ../assets/posts/rooting-twrp-a11/twrp-3.7.0_afaneh92-a11q.tar
# Output: recovery.img (33MB)
```

### Jalankan script flash TWRP
```bash
bash flash_twrp.sh
```

Script ini melakukan:
1. Cek koneksi ADB & root
2. Cek security properties (flash.locked, verifiedbootstate, kgstate)
3. Push `recovery.img` ke `/data/local/tmp/`
4. Backup & disable `recovery-from-boot.p`
6. Cek ukuran partition recovery
7. `dd` TWRP ke partition recovery (`mmcblk0p61`)
8. Verifikasi flash
9. **Reboot ke TWRP (JANGAN ke system!)**

### Yang harus dilakukan di TWRP

```bash
# Script akan auto-reboot ke recovery.
# Di TWRP:
```

1. **Wipe → Format Data** → ketik `yes` (⚠️ hapus semua data internal)
2. **Reboot → Recovery** (verifikasi TWRP masih ada)
3. **Reboot → System**

> ⚠️ Jika stock recovery langsung ter-restore, ulangi flash TWRP dari §4.

---

## §5. Troubleshooting

### "Only official released binaries are allowed"
- **KG state masih prenormal**: tunggu 7 hari + WiFi + Samsung account
- **Bootloader ke-kunci lagi**: unlock lewat Download Mode (Vol Up 7 detik)
- **Binary revision mismatch**: pastikan boot.img dari firmware yang SAMA

### Bootloop setelah flash TWRP
```bash
# Masuk TWRP: Vol Up + Power (tahan)
# Di TWRP: Format Data → reboot
```

### Kalo TWRP gak muncul / stock recovery yang keboot
TWRP ke-restore oleh `recovery-from-boot.p`. Solusi:
```bash
adb shell "su -c 'mount -o rw,remount /system && rm -f /system/etc/recovery-from-boot.p /system/bin/install-recovery.sh'"
```
Lalu ulang flash TWRP dari §4.

### vbmeta overflow (boot verify image failed)
Jika `vbmeta_stock_patched.img` ukurannya > 4096 bytes, flash akan merusak partition tetangga. Fix:
```bash
heimdall flash --VBMETA vbmeta_stock.img --VBMETABAK vbmeta_stock.img --DTBO dtbo.img
```

### "Security error" setelah boot
```bash
# Cek status
adb shell "getprop ro.boot.flash.locked"     # harus 0
adb shell "getprop ro.boot.verifiedbootstate" # harus orange
adb shell "getprop ro.boot.warranty_bit"      # harus kosong
```
Kalo Warranty Bit = 1, device kena eFuse — tidak bisa unlock permanen.

---

## File Referensi

| Link | Kegunaan |
|------|----------|
| [XDA TWRP Thread](https://xdaforums.com/t/recovery-unofficial-twrp-for-galaxy-a11-snapdragon.4197085/) | Official TWRP by afaneh92 |
| [GitHub 3xp-l01t Mirror](https://github.com/3xp-l01t/Samsung-Galaxy-A115U1-Unofficial-TWRP) | Download TWRP + vbmeta + Magisk |
| [SamFW Firmware](https://samfw.com/firmware/SM-A115F) | Download stock firmware |
| [Magisk GitHub](https://github.com/topjohnwu/Magisk) | Root solution |
| [TrebleDroid Wiki](https://github.com/TrebleDroid/treble_experimentations/wiki/Samsung-Galaxy-A11) | Device-specific GSI info |
| [Telegram Group](https://t.me/samsung_galaxy_m01_a01_m11_a11) | Komunitas A11/M11 |

---

## Credits

- **afaneh92** — TWRP builder & XDA maintainer
- **3xp-l01t** — GitHub mirror of TWRP + files
- **topjohnwu** — Magisk
- Samsung Open Source Center — Kernel source

---

*Tutorial ini disusun dari pengalaman langsung pada SM-A115F firmware XXS6CWK2. Untuk device dengan firmware berbeda, beberapa langkah mungkin perlu penyesuaian.*
