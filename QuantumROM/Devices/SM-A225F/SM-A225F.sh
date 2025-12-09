#!/bin/bash

MODEL=SM-A225F
CSC=BKD
IMEI=350167020473859

FW_DIR="fw_download"
BIN_DIR="bin"
WORK_DIR="work"
OUT_DIR="out"

echo "--- Downloading $MODEL $CSC firmware ---"
chmod +x ./scripts/download_firmware.sh
bash ./scripts/download_firmware.sh "$MODEL" "$CSC" "$IMEI" "$FW_DIR" "$MODEL"
