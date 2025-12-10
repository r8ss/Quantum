#!/bin/bash

MODEL=SM-A225F
CSC=BKD
IMEI=350167020473859

FW_DIR="fw_download"
BIN_DIR="bin"
WORK_DIR="work"
OUT_DIR="out"

echo ""
echo "--- Downloading $MODEL $CSC firmware ---"
chmod +x ./scripts/download_firmware.sh
bash ./scripts/download_firmware.sh "$MODEL" "$CSC" "$IMEI" "$FW_DIR" "$MODEL"

echo ""
echo "--- Extracting $MODEL $CSC firmware ---"
chmod +x ./scripts/extract_firmware.sh
bash ./scripts/extract_firmware.sh "$(pwd)/${FW_DIR}/${MODEL}"

echo ""
echo "--- Disabling $MODEL Security ---"
chmod +x ./QuantumROM/mods/security_disabler.sh
chmod +x ./QuantumROM/mods/musti_disabler.sh
bash ./QuantumROM/mods/security_disabler.sh "$(pwd)/${FW_DIR}/${MODEL}"
bash ./QuantumROM/mods/musti_disabler.sh "$(pwd)/${FW_DIR}/${MODEL}"
