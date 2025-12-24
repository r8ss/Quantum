#!/bin/bash
# download_firmware.sh
# Usage: bash download_firmware.sh MODEL CSC IMEI DOWNLOAD_FOLDER FIRMWARE_FOLDER

if [ "$#" -ne 5 ]; then
    echo "Usage: bash $0 MODEL CSC IMEI DOWNLOAD_FOLDER FIRMWARE_FOLDER"
    exit 1
fi

MODEL=$1
CSC=$2
IMEI=$3
FW_DIR=$4
F_FOLDER=$5

rm -rf "${FW_DIR}${F_FOLDER}"
mkdir -p "${FW_DIR}/${F_FOLDER}"

echo "======================================"
echo " Samsung FW Downloader "
echo "======================================"
echo "MODEL: $MODEL | CSC: $CSC"
echo "Fetching latest firmware..."
echo

# --- Step 1: Check Update ---
version=$(python3 -m samloader -m "$MODEL" -r "$CSC" -i "$IMEI" checkupdate 2>&1)
if [ $? -ne 0 ] || [ -z "$version" ]; then
    echo "❌ MODEL/CSC/IMEI not valid or no update found."
    echo "Error: $version"
    exit 1
else
    echo "✅ Update found: $version"
    echo "Starting download..."
fi

# --- Step 3: Download Firmware ---
python3 -m samloader -m "$MODEL" -r "$CSC" -i "$IMEI" download -v "$version" -O "${FW_DIR}/${F_FOLDER}"
if [ $? -ne 0 ]; then
    echo "❌ Download failed. Check IMEI/MODEL/CSC."
    exit 1
fi

# --- Step 4: Decrypt Firmware ---
enc_file=$(find "${FW_DIR}/${F_FOLDER}" -name "*.enc*" | head -n 1)

if [ -z "$enc_file" ]; then
    echo "❌ No encrypted firmware file found!"
    exit 1
fi

# --- Step 5: Decrypting firmware...
python3 -m samloader -m "$MODEL" -r "$CSC" -i "$IMEI" decrypt -v "$version" -i "$enc_file" -o "${FW_DIR}/${F_FOLDER}/${MODEL}.zip"
if [ $? -ne 0 ]; then
    echo "❌ Decryption failed."
    exit 1
fi

# --- Show Firmware Info ---
file_size=$(du -m "${FW_DIR}/${F_FOLDER}/${MODEL}.zip" | cut -f1)
echo "✅ Firmware decrypted successfully!"
echo "Firmware Size: ${file_size} MB"
echo "Saved to: ${FW_DIR}/${F_FOLDER}/${MODEL}.zip"
echo ""

# --- Cleanup ---
rm -f "$enc_file"
