#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: bash $0 MODEL CSC IMEI"
    exit 1
fi

MODEL=$1
CSC=$2
IMEI=$3
FW_DIR="fw_download"
BIN_DIR="bin"
WORK_DIR="work"
OUT_DIR="out"

echo ""
# --- Setup Directories ---
chmod +x ./scripts/setup_directories.sh
bash ./scripts/setup_directories.sh "$FW_DIR" "$WORK_DIR" "$OUT_DIR"

echo ""
echo "--- Downloading $MODEL $CSC firmware ---"
chmod +x ./scripts/download_firmware.sh
bash ./scripts/download_firmware.sh "$MODEL" "$CSC" "$IMEI" "$FW_DIR" "$MODEL"

echo ""
echo "--- Extracting Firmware ---"
chmod +x ./scripts/extract_firmware.sh
bash ./scripts/extract_firmware.sh "$(pwd)/${FW_DIR}/${MODEL}" "${MODEL}.zip"

echo ""
echo "--- Unpacking images ---"
chmod +x ./scripts/extract_ext4.sh
bash ./scripts/extract_ext4.sh "$(pwd)/${FW_DIR}/${MODEL}"

echo ""
echo "--- Debloating ---"
chmod +x ./QuantumROM/mods/debloater.sh
bash ./QuantumROM/mods/debloater.sh "$(pwd)/${FW_DIR}/${MODEL}"

echo ""
echo "--- Disabling Security ---"
chmod +x ./QuantumROM/mods/security_disabler.sh
chmod +x ./QuantumROM/mods/musti_disabler.sh
bash ./QuantumROM/mods/security_disabler.sh "$(pwd)/${FW_DIR}/${MODEL}"
bash ./QuantumROM/mods/musti_disabler.sh "$(pwd)/${FW_DIR}/${MODEL}"

echo ""
echo "--- Packing .img ---"
chmod +x ./bin/make_ext4fs
chmod +x ./scripts/pack_ext4.sh
bash ./scripts/pack_ext4.sh "$(pwd)/${FW_DIR}/${MODEL}" "$(pwd)/${BIN_DIR}" "$(pwd)/${OUT_DIR}"

echo ""
echo "--- Compressing .img files in $OUT_DIR ---"
for i in "$OUT_DIR"/*.img; do [ -e "$i" ] && 7z a -mx9 "${i%.*}.img.xz" "$i"; done
rm -rf "$OUT_DIR"/*.img
