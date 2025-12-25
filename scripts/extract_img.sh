#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <ROM_DIR>"
    exit 1
fi

ROM_DIR="$1"

# Setup
chmod +x "$(pwd)/../bin/extract.erofs"

for imgfile in "$ROM_DIR"/*.img; do
    [ -e "$imgfile" ] || continue

    if [[ "$(basename "$imgfile")" == "boot.img" ]]; then
        continue
    fi

    partition=$(basename "${imgfile%.img}")
    fstype=$(blkid -o value -s TYPE "$imgfile" 2>/dev/null)

    case "$fstype" in
        ext4)
            echo "$imgfile Detected $fstype."
            IMG_SIZE=$(stat -c%s -- "$imgfile")
            echo "$imgfile size is $IMG_SIZE bytes."
            echo "Extracting $imgfile in $ROM_DIR/$partition"
            python3 (pwd)/../bin/py_scripts/imgextractor.py "$imgfile" "$ROM_DIR" >/dev/null 2>&1
            ;;
        erofs)
            echo ""
            echo "$imgfile Detected $fstype."
            IMG_SIZE=$(stat -c%s -- "$imgfile")
            echo "$imgfile size is $IMG_SIZE bytes."
            echo "Extracting $imgfile in $ROM_DIR/$partition"
            printf $IMG_SIZE > "$ROM_DIR/config/$partition_size.txt"
            (pwd)/../bin/extract.erofs -i "$imgfile" -x -o "$ROM_DIR" >/dev/null 2>&1
            rm -f "$ROM_DIR/config/"*_fs_options
            ;;
        *)
            echo "[$imgfile] Unknown filesystem type ($fstype), skipping"
            exit 1
            ;;
    esac
done

# Remove all original .img
rm -rf "$ROM_DIR"/*.img
