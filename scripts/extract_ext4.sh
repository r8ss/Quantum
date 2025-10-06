#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <ROM_DIR>"
    exit 1
fi

ROM_DIR="$1"

for imgfile in $ROM_DIR/*.img; do
    [ -e "$imgfile" ] || continue

    if [[ "$(basename "$imgfile")" == "boot.img" ]]; then
        continue
    fi

    python3 ./bin/py_scripts/imgextractor.py "$imgfile" "$ROM_DIR"
done

find "$ROM_DIR" -type f -name "*.img" ! -name "boot.img" -exec rm -f {} +
