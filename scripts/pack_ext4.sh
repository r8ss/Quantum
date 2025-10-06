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

    folder_name=$(basename "$folder_path")

    if [ "$folder_name" == "config" ]; then
        echo "Skipping config folder..."
        continue
    fi

    partition_name="$folder_name"
    file_contexts_file="$ROM_DIR/config/$folder_name/${folder_name}_file_contexts"
    fs_config_file="$ROM_DIR/config/$folder_name/${folder_name}_fs_config"
    SIZE=$(du -sb "$ROM_DIR/$folder_name" | awk '{printf "%d", $1 * 1.07}')

    if [ "$folder_name" = "system" ]; then
        mount_point="/"
    else
        mount_point="/$folder_name"
    fi

    echo ""
    echo "Creating $partition_name.img from $folder_path..."
    sort -u "$file_contexts_file" -o "$file_contexts_file"
    sort -u "$fs_config_file" -o "$fs_config_file"
    ./bin/make_ext4fs -J -T -1 \
        -S "$file_contexts_file" \
        -C "$fs_config_file" \
        -l "$SIZE" \
        -L "$mount_point" \
        -a "$partition_name" \
        "$OUT_DIR/$partition_name.img" "$ROM_DIR/$partition_name"
done

# --- Move boot.img to $OUT_DIR ---
mv "$ROM_DIR/boot.img" "$OUT_DIR/"
# --- Cleaning up $ROM_DIR ---
rm -rf "$ROM_DIR"/*
