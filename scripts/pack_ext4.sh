#!/bin/bash

if [ -z "$3" ]; then
    echo "Usage: $0 <ROM_DIR> <BIN_DIR> <OUT_DIR>"
    exit 1
fi

ROM_DIR="$1"
BIN_DIR="$2"
OUT_DIR="$3"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

for folder_path in "$ROM_DIR"/*; do
    [ -d "$folder_path" ] || continue

    partition=$(basename "$folder_path")

    if [ "$partition" == "config" ]; then
        echo "Skipping config folder..."
        continue
    fi

    partition="$partition"
    file_contexts_file="$ROM_DIR/config/$partition/${partition}_file_contexts"
    fs_config_file="$ROM_DIR/config/$partition/${partition}_fs_config"
    SIZE=$(du -sb "$ROM_DIR/$partition" | awk '{printf "%d", $1 * 1.07}')

    if [ "$partition" = "system" ]; then
        mount_point="/"
    else
        mount_point="/$partition"
    fi

    echo ""
    echo "Creating $partition.img from $folder_path..."
    sort -u "$file_contexts_file" -o "$file_contexts_file"
    sort -u "$fs_config_file" -o "$fs_config_file"
    ./bin/make_ext4fs -J -T -1 \
        -S "$file_contexts_file" \
        -C "$fs_config_file" \
        -l "$SIZE" \
        -L "$mount_point" \
        -a "$partition" \
        "$OUT_DIR/$partition.img" "$ROM_DIR/$partition"
done

# --- Move boot.img to $OUT_DIR ---
mv "$ROM_DIR/boot.img" "$OUT_DIR/"
# --- Cleaning up $ROM_DIR ---
rm -rf "$ROM_DIR"/*
