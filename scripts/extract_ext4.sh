#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <ROM_DIR>"
    exit 1
fi

ROM_DIR="$1"

# Setup
chmod +x ./bin/extract.erofs

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
            python3 ./bin/py_scripts/imgextractor.py "$imgfile" "$ROM_DIR"
            ;;
        erofs)
            echo "[$imgfile] Detected EROFS"
            ./bin/extract.erofs "$imgfile" "$ROM_DIR/$(basename "${imgfile%.img}")"
            ;;
        *)
            echo "[$imgfile] Unknown filesystem type ($fstype), skipping"
            exit 1
            ;;
    esac
done

# Remove original .img files except boot.img and split outputs
find "$ROM_DIR" -type f -name "*.img" ! -name "boot.img" -exec rm -f {} +
