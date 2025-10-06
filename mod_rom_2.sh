#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: bash $0 MODEL CSC IMEI"
    exit 1
fi

MODEL=$1
FW_DIR="fw_download"
BIN_DIR="bin"
WORK_DIR="work"
OUT_DIR="out"

echo "--- Extracting Firmware ---"
chmod +x ./scripts/extract_firmware.sh
bash ./scripts/extract_firmware.sh "$(pwd)/${FW_DIR}/${MODEL}" "${MODEL}.zip"

echo "--- Unpacking images ---"
chmod +x ./scripts/extract_ext4.sh
bash ./scripts/extract_ext4.sh "$(pwd)/${FW_DIR}/${MODEL}"

echo "--- Debloating ---"
chmod +x ./QuantumROM/mods/debloater.sh
bash ./QuantumROM/mods/debloater.sh "$(pwd)/${FW_DIR}/${MODEL}"

echo "--- Disabling Security ---"
chmod +x ./QuantumROM/mods/security_disabler.sh
chmod +x ./QuantumROM/mods/musti_disabler.sh
bash ./QuantumROM/mods/security_disabler.sh "$(pwd)/${FW_DIR}/${MODEL}"
bash ./QuantumROM/mods/musti_disabler.sh "$(pwd)/${FW_DIR}/${MODEL}"

echo "--- Packing .img ---"
chmod +x ./bin/make_ext4fs
chmod +x ./scripts/pack_ext4.sh
bash ./scripts/pack_ext4.sh "$(pwd)/${FW_DIR}/${MODEL}" "$(pwd)/${BIN_DIR}" "$(pwd)/${OUT_DIR}"
