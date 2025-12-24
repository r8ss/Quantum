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

    # Detect filesystem type using blkid
    fstype=$(blkid -o value -s TYPE "$imgfile" 2>/dev/null)

    case "$fstype" in
        ext4)
            echo "[$imgfile] Detected ext4"
            python3 "$(pwd)/../bin/py_scripts/imgextractor.py" "$imgfile" "$ROM_DIR"
            ;;
        erofs)
            echo "[$imgfile] Detected EROFS"
            "$(pwd)/../bin/extract.erofs" -i "$imgfile" -x -o "$ROM_DIR/$(basename "${imgfile%.img}")"
            ;;
        *)
            echo "[$imgfile] Unknown filesystem type ($fstype), skipping"
            exit 1
            ;;
    esac
done

# Remove a original .img
rm -rf *.img
