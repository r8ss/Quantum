#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: bash $0 MODEL"
    exit 1
fi

MODEL=$1
FW_DIR="fw_download"
BIN_DIR="bin"
WORK_DIR="work"
OUT_DIR="out"


# --- Setup Directories ---
chmod +x ./scripts/setup_directories.sh
bash ./scripts/setup_directories.sh "FW_DIR" "WORK_DIR" "OUT_DIR"


# --- Extract Firmware ---
chmod +x ./scripts/extract_firmware.sh
bash ./scripts/extract_firmware.sh "$(pwd)/${FW_DIR}/${MODEL}" "${MODEL}.zip"


# --- Run IMG Unpack cmd ---
chmod +x ./scripts/extract_ext4.sh
bash ./scripts/extract_ext4.sh "$(pwd)/${FW_DIR}/${MODEL}"


# --- Run Debloat cmd ---
chmod +x ./QuantumROM/mods/debloater.sh
bash ./QuantumROM/mods/debloater.sh "$(pwd)/${FW_DIR}/${MODEL}"


# --- Run Security Disabler cmd ---
chmod +x ./QuantumROM/mods/security_disabler.sh
chmod +x ./QuantumROM/mods/musti_disabler.sh
bash ./QuantumROM/mods/security_disabler.sh "$(pwd)/${FW_DIR}/${MODEL}"
bash ./QuantumROM/mods/musti_disabler.sh "$(pwd)/${FW_DIR}/${MODEL}"

