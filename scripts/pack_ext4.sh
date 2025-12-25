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

for partition_path in "$ROM_DIR"/*; do
    [ -d "$partition_path" ] || continue

    partition=$(basename "$partition_path")

    if [ "$partition" == "config" ]; then
        echo "Skipping config folder..."
        continue
    fi

    file_contexts="$ROM_DIR/config/${partition}_file_contexts"
    fs_config="$ROM_DIR/config/${partition}_fs_config"
    SIZE=$(cat "$ROM_DIR/config/${partition}_size.txt")

    if [ "$partition" = "system" ]; then
        mount_point="/"
    else
        mount_point="/$partition"
    fi

    echo ""
    echo "Creating $partition.img from $partition_path..."
    sort -u "$file_contexts" -o "$file_contexts"
    sort -u "$fs_config" -o "$fs_config"
    ./bin/make_ext4fs -J -T -1 \
        -S "$file_contexts" \
        -C "$fs_config" \
        -l "$SIZE" \
        -L "$mount_point" \
        -a "$partition" \
        "$OUT_DIR/$partition.img" "$ROM_DIR/$partition"
done

# --- Move boot.img to $OUT_DIR ---
mv "$ROM_DIR/boot.img" "$OUT_DIR/"
# --- Cleaning up $ROM_DIR ---
rm -rf "$ROM_DIR"/*
