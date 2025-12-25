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

echo "-- Downloading $MODEL $CSC firmware --"
chmod +x ./scripts/download_firmware.sh
bash ./scripts/download_firmware.sh "$MODEL" "$CSC" "$IMEI" "$FW_DIR" "$MODEL"

echo ""
echo "-- Extracting $MODEL $CSC Firmware --"
chmod +x ./scripts/extract_firmware.sh
bash ./scripts/extract_firmware.sh "$(pwd)/${FW_DIR}/${MODEL}" "${MODEL}.zip"

echo ""
echo "-- Removing $MODEL $CSC Security --"
chmod +x ./QuantumROM/mods/musti_disabler.sh
bash ./QuantumROM/mods/musti_disabler.sh "$(pwd)/${FW_DIR}/${MODEL}"
