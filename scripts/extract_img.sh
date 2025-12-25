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
            echo -e "$imgfile Detected ext4.\nExtracting in ${ROM_DIR}/$(basename "${imgfile%.img}")"
            python3 ./bin/py_scripts/imgextractor.py "$imgfile" "$ROM_DIR" 2>/dev/null
            ;;
        erofs)
            echo ""
            echo -e "$imgfile Detected erofs.\nExtracting in ${ROM_DIR}/$(basename "${imgfile%.img}")"
            ./bin/extract.erofs -i "$imgfile" -x -o "$ROM_DIR" 2>/dev/null
            printf '%s\n' "$(stat -c%s "$imgfile")" > "${ROM_DIR}/config/$(basename "${imgfile%.img}")_size.txt"
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
