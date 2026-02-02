#!/bin/bash

# Device info
export STOCK_DEVICE=$1
export TARGET_DEVICE=$2
export TARGET_DEVICE_CSC=$3
export TARGET_DEVICE_IMEI=$4

# Directories
export DEVICES_DIR="$(pwd)/QuantumROM/Devices"
export OUT_DIR="$(pwd)/OUT"
export WORK_DIR="$(pwd)/WORK"
export FIRM_DIR="$(pwd)/FIRMWARE"
export APKTOOL="$(pwd)/bin/apktool/apktool.jar"
export VNDKS_COLLECTION="$(pwd)/QuantumRom/vndks"

export BUILD_PARTITIONS=(product system)

# Binary
chmod -R 755 "$(pwd)/bin"

# Source
source "$(pwd)/scripts/QuantumRom.sh"
source "$DEVICES_DIR/$STOCK_DEVICE/config"

DOWNLOAD_FIRMWARE "$TARGET_DEVICE" "$TARGET_DEVICE_CSC" "$TARGET_DEVICE_IMEI" "$FIRM_DIR"

EXTRACT_FIRMWARE "$FIRM_DIR/$TARGET_DEVICE"
EXTRACT_FIRMWARE_IMG "$FIRM_DIR/$TARGET_DEVICE"

PREPARE_PARTITIONS "$FIRM_DIR/$TARGET_DEVICE"
APPLY_STOCK_CONFIG "$FIRM_DIR/$TARGET_DEVICE"

INSTALL_FRAMEWORK "$FIRM_DIR/$TARGET_DEVICE/system/system/framework/framework-res.apk"

DECOMPILE "$APKTOOL" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework/ssrm.jar" "$WORK_DIR"
DECOMPILE "$APKTOOL" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework/services.jar" "$WORK_DIR"

PATCH_FLAG_SECURE "$WORK_DIR/services"
PATCH_SECURE_FOLDER "$WORK_DIR/services"
PATCH_KNOX_GUARD "$WORK_DIR/services"
PATCH_SSRM "$WORK_DIR/ssrm" "siop_a22_mt6769t" "dvfs_policy_mt6769t_xx"

RECOMPILE "$APKTOOL" "$WORK_DIR/ssrm" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework" "$WORK_DIR"
RECOMPILE "$APKTOOL" "$WORK_DIR/services" "$$FIRM_DIR/$TARGET_DEVICE/system/system/framework" "$WORK_DIR"

PATCH_BT_LIB "$FIRM_DIR/$TARGET_DEVICE" "$WORK_DIR"

BUILD_IMG "$FIRM_DIR/$TARGET_DEVICE" "erofs" "$OUT_DIR"
