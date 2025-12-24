#!/bin/bash
# extract_firmware.sh
# Usage: bash extract_firmware.sh FW_FILE_DIR FW_FILE_NAME

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: bash $0 <FW_FILE_DIR> <FW_FILE_NAME>"
    exit 1
fi

echo "Running script: $(basename "$0")"
FW_FILE_DIR="$1"
FW_FILE_NAME="$2"

echo "Extracting firmware from ${FW_FILE_NAME}..."
7z x "${FW_FILE_DIR}/${FW_FILE_NAME}" -o"${FW_FILE_DIR}"

# Cleaning up original archive and text files
rm -f "${FW_FILE_DIR}/${FW_FILE_NAME}"
rm -f "${FW_FILE_DIR}"/*.txt

# Renaming .md5 files to remove extension
for file in "${FW_FILE_DIR}"/*.md5; do
    [ -f "$file" ] && mv -- "$file" "${file%.md5}"
done

echo "Extracting tar files..."
for file in "${FW_FILE_DIR}"/*.tar; do
    if [ -f "$file" ]; then
        tar -xvf "$file" -C "${FW_FILE_DIR}"
        rm -f "$file"
    fi
done

# Keep only super.img.lz4 and boot.img.lz4
find "${FW_FILE_DIR}" -type f \
    ! -name 'super.img.lz4' \
    ! -name 'boot.img.lz4' \
    -delete

echo "Decompressing .lz4 files..."
for file in "${FW_FILE_DIR}"/*.lz4; do
    [ -f "$file" ] && lz4 -d "$file" "${file%.lz4}"
done

# Clean up .lz4 files and metadata
rm -f "${FW_FILE_DIR}"/*.lz4
rm -rf "${FW_FILE_DIR}/meta-data"

echo "Converting sparse super.img to raw image..."
simg2img "${FW_FILE_DIR}/super.img" "${FW_FILE_DIR}/super_raw.img"
rm -f "${FW_FILE_DIR}/super.img"
mv "${FW_FILE_DIR}/super_raw.img" "${FW_FILE_DIR}/super.img"

echo "Unpacking super.img..."
lpunpack -o "${FW_FILE_DIR}" "${FW_FILE_DIR}/super.img"
rm -f "${FW_FILE_DIR}/super.img"
rm -f "${FW_FILE_DIR}/*_dlkm.img"
rm -f "${FW_FILE_DIR}/boot.img"

echo "Unpacking all img..."
chmod +x ./scripts/extract_img.sh
bash ./scripts/extract_img.sh "${FW_FILE_DIR}"

echo ""
echo "✅ Firmware extraction complete in ${FW_FILE_DIR}"
