#!/usr/bin/env bash
# =============================================================================
#  QuantumROM — images_zip.sh
#  Packages raw .img files + a fastboot flash script into a zip.
#
#  Called by build_quantum.sh when CREATE_IMAGES_ZIP="true".
#  Required exported vars:
#    QT_DIR        → root of the QuantumROM repo
#    DEVICES_DIR   → path to device configs
#    STOCK_DEVICE  → stock device model (e.g. SM-G980F)
#    TARGET_DEVICE → target device model (e.g. SM-A346E)
#    OUT_DIR       → build output directory
#
#  Output zip structure:
#    QuantumROM-SM-G980F-20260628-IMAGES.zip
#    ├── system.img
#    ├── product.img
#    ├── vendor.img
#    ├── odm.img
#    ├── boot.img
#    ├── dtbo.img
#    ├── bin/               ← fastboot binaries (Windows/Linux)
#    │   ├── fastboot.exe
#    │   ├── AdbWinApi.dll
#    │   └── ...
#    ├── flash.sh           ← fastboot flash script (Linux/Mac)
#    ├── flash.bat          ← fastboot flash script (Windows)
#    └── extras/            ← everything else from device extra/
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log()   { echo -e "${CYAN}[IMAGES]${RESET} $*"; }
ok()    { echo -e "${GREEN}[OK]${RESET}     $*"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET}   $*"; }
die()   { echo -e "${RED}[ERROR]${RESET}  $*" >&2; exit 1; }

# ── Resolve paths ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QT_DIR="${QT_DIR:-$(dirname "$SCRIPT_DIR")}"
DEVICES_DIR="${DEVICES_DIR:-$QT_DIR/QuantumROM/Devices}"
OUT_DIR="${OUT_DIR:-$QT_DIR/OUT}"

: "${STOCK_DEVICE:?  STOCK_DEVICE is not set.}"
: "${TARGET_DEVICE:? TARGET_DEVICE is not set.}"

DEVICE_DIR="$DEVICES_DIR/$STOCK_DEVICE"
EXTRA_DIR="$DEVICE_DIR/extra"
TODAY="$(date '+%Y%m%d')"
ZIP_NAME="QuantumROM-${STOCK_DEVICE}-${TODAY}-IMAGES.zip"
FINAL_ZIP="$OUT_DIR/$ZIP_NAME"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

log "Starting images zip generation..."
log "  Stock device : $STOCK_DEVICE"
log "  Target device: $TARGET_DEVICE"
log "  Output       : $FINAL_ZIP"
echo ""

# ── Sanity checks ─────────────────────────────────────────────────────────────
[[ -d "$DEVICE_DIR" ]] || die "Device directory not found: $DEVICE_DIR"
[[ -d "$EXTRA_DIR"  ]] || die "Extra directory not found: $EXTRA_DIR"

# ── Locate build partitions ───────────────────────────────────────────────────
SYSTEM_IMG="$OUT_DIR/system.img"
PRODUCT_IMG="$OUT_DIR/product.img"

ODM_IMG=""
VENDOR_IMG=""
for c in "$EXTRA_DIR/odm.img" "$EXTRA_DIR/odm/odm.img"; do
    [[ -f "$c" ]] && { ODM_IMG="$c"; break; }
done
for c in "$EXTRA_DIR/vendor.img" "$EXTRA_DIR/vendor/vendor.img"; do
    [[ -f "$c" ]] && { VENDOR_IMG="$c"; break; }
done

[[ -f "$SYSTEM_IMG"  ]] || die "system.img not found at $SYSTEM_IMG"
[[ -f "$PRODUCT_IMG" ]] || die "product.img not found at $PRODUCT_IMG"
[[ -n "$ODM_IMG"     ]] || die "odm.img not found inside $EXTRA_DIR"
[[ -n "$VENDOR_IMG"  ]] || die "vendor.img not found inside $EXTRA_DIR"

ok "system.img  → $SYSTEM_IMG"
ok "product.img → $PRODUCT_IMG"
ok "odm.img     → $ODM_IMG"
ok "vendor.img  → $VENDOR_IMG"

# ── Copy partition images ─────────────────────────────────────────────────────
log "Copying partition images..."
cp -f "$SYSTEM_IMG"  "$STAGING/system.img"
cp -f "$PRODUCT_IMG" "$STAGING/product.img"
cp -f "$ODM_IMG"     "$STAGING/odm.img"
cp -f "$VENDOR_IMG"  "$STAGING/vendor.img"
ok "Partitions copied."

# ── Extract boot and dtbo ─────────────────────────────────────────────────────
log "Looking for boot-dtbo zip in $EXTRA_DIR ..."
BOOT_DTBO_ZIP="$(find "$EXTRA_DIR" -maxdepth 2 -type f -name "boot-dtbo.*.zip" | head -n1)"
[[ -n "$BOOT_DTBO_ZIP" ]] || die "No boot-dtbo.<codename>.zip found inside $EXTRA_DIR"
ok "Found: $(basename "$BOOT_DTBO_ZIP")"

log "Extracting boot.img and dtbo.img..."
BOOT_TMP="$(mktemp -d)"
7z e -y "$BOOT_DTBO_ZIP" -o"$BOOT_TMP" boot.img dtbo.img >/dev/null 2>&1 || \
    unzip -o "$BOOT_DTBO_ZIP" boot.img dtbo.img -d "$BOOT_TMP" >/dev/null 2>&1

[[ -f "$BOOT_TMP/boot.img" ]] || die "boot.img not found inside $(basename "$BOOT_DTBO_ZIP")"
[[ -f "$BOOT_TMP/dtbo.img" ]] || die "dtbo.img not found inside $(basename "$BOOT_DTBO_ZIP")"

cp -f "$BOOT_TMP/boot.img" "$STAGING/boot.img"
cp -f "$BOOT_TMP/dtbo.img" "$STAGING/dtbo.img"
rm -rf "$BOOT_TMP"
ok "boot.img and dtbo.img copied."

# ── Copy fastboot binaries for Windows ────────────────────────────────────────
IMAGES_ZIP_DIR="$QT_DIR/QuantumROM/images_zip"
BIN_DIR="$IMAGES_ZIP_DIR/bin"
if [[ -d "$BIN_DIR" ]]; then
    log "Copying fastboot binaries (Windows)..."
    cp -r "$BIN_DIR" "$STAGING/bin"
    ok "bin/ copied."
else
    warn "bin/ not found at $BIN_DIR — Windows batch will not work."
fi

# ── Generate flash.sh ─────────────────────────────────────────────────────────
log "Generating flash.sh..."
cat > "$STAGING/flash.sh" << EOF
#!/usr/bin/env bash
# =============================================================================
#  QuantumROM — flash.sh
#  Flashes all partitions via fastboot.
#  Port: $TARGET_DEVICE -> $STOCK_DEVICE
#  Built: $TODAY
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log()  { echo -e "\${CYAN}[FLASH]\${RESET} \$*"; }
ok()   { echo -e "\${GREEN}[OK]\${RESET}    \$*"; }
die()  { echo -e "\${RED}[ERROR]\${RESET} \$*" >&2; exit 1; }

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"

command -v fastboot &>/dev/null || die "fastboot not found. Install android-tools-fastboot."

echo ""
echo -e "\${BOLD}================================================="
echo -e "  QuantumROM Image Flasher"
echo -e "  Port: $TARGET_DEVICE -> $STOCK_DEVICE"
echo -e "=================================================\${RESET}"
echo ""

log "Checking fastboot device..."
fastboot devices | grep -q "fastboot" || die "No device found in fastboot mode."

log "Flashing super partitions..."
fastboot flash system  "\$SCRIPT_DIR/system.img"  && ok "system  flashed"
fastboot flash product "\$SCRIPT_DIR/product.img" && ok "product flashed"
fastboot flash vendor  "\$SCRIPT_DIR/vendor.img"  && ok "vendor  flashed"
fastboot flash odm     "\$SCRIPT_DIR/odm.img"     && ok "odm     flashed"

log "Flashing kernel partitions..."
fastboot flash boot    "\$SCRIPT_DIR/boot.img"    && ok "boot    flashed"
fastboot flash dtbo    "\$SCRIPT_DIR/dtbo.img"    && ok "dtbo    flashed"

echo ""
echo -e "\${BOLD}\${GREEN}All done! Rebooting...\${RESET}"
fastboot reboot
EOF

chmod +x "$STAGING/flash.sh"
ok "flash.sh generated."

# ── Generate flash.bat ─────────────────────────────────────────────────────────
log "Generating flash.bat..."
cat > "$STAGING/flash.bat" << EOF
@echo off
setlocal enabledelayedexpansion
title QuantumROM Image Flasher

echo =================================================
echo   QuantumROM Image Flasher
echo   Port: $TARGET_DEVICE -^> $STOCK_DEVICE
echo   Built: $TODAY
echo =================================================
echo.

:: Use bundled fastboot from /bin
set "FB=%~dp0bin\\fastboot.exe"
echo [FLASH] Checking fastboot device...
!FB! devices | findstr "fastboot" >nul
if errorlevel 1 (
    echo [ERROR] No device found in fastboot mode.
    pause
    exit /b 1
)

echo [FLASH] Flashing super partitions...
!FB! flash system  "%~dp0system.img"  && echo [OK]    system  flashed
!FB! flash product "%~dp0product.img" && echo [OK]    product flashed
!FB! flash vendor  "%~dp0vendor.img"  && echo [OK]    vendor  flashed
!FB! flash odm     "%~dp0odm.img"     && echo [OK]    odm     flashed

echo [FLASH] Flashing kernel partitions...
!FB! flash boot    "%~dp0boot.img"    && echo [OK]    boot    flashed
!FB! flash dtbo    "%~dp0dtbo.img"    && echo [OK]    dtbo    flashed

echo.
echo [OK] Flash complete, press ENTER to reboot...
pause >nul
!FB! reboot
endlocal
EOF

ok "flash.bat generated."

# ── Staging summary ───────────────────────────────────────────────────────────
echo ""
log "Images zip contents:"
find "$STAGING" | sed "s|$STAGING||" | sort | while read -r f; do
    [[ -z "$f" ]] && continue
    sz="$(du -sh "$STAGING$f" 2>/dev/null | cut -f1)"
    echo -e "  ${BOLD}$f${RESET}  ($sz)"
done
echo ""

# ── Pack zip ─────────────────────────────────────────────────────────────────
log "Packing $ZIP_NAME ..."
mkdir -p "$OUT_DIR"
cd "$STAGING"
7z a -tzip "$FINAL_ZIP" ./* -mx=0 >/dev/null
cd - >/dev/null

ok "Images zip ready → $FINAL_ZIP"
echo -e "${BOLD}${GREEN}✅  images_zip.sh done! → $FINAL_ZIP${RESET}"
