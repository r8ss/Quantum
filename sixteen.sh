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
export VNDKS_COLLECTION="$(pwd)/QuantumROM/vndks"

export BUILD_PARTITIONS=(product system)

# Source
sudo source "$(pwd)/scripts/QuantumRom.sh"
sudo source "$DEVICES_DIR/$STOCK_DEVICE/config"

sudo DOWNLOAD_FIRMWARE "$TARGET_DEVICE" "$TARGET_DEVICE_CSC" "$TARGET_DEVICE_IMEI" "$FIRM_DIR"

sudo EXTRACT_FIRMWARE "$FIRM_DIR/$TARGET_DEVICE"
sudo EXTRACT_FIRMWARE_IMG "$FIRM_DIR/$TARGET_DEVICE"

sudo PREPARE_PARTITIONS "$FIRM_DIR/$TARGET_DEVICE"
sudo APPLY_STOCK_CONFIG "$FIRM_DIR/$TARGET_DEVICE"

sudo INSTALL_FRAMEWORK "$FIRM_DIR/$TARGET_DEVICE/system/system/framework/framework-res.apk"

sudo DECOMPILE "$APKTOOL" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework/ssrm.jar" "$WORK_DIR"
sudo DECOMPILE "$APKTOOL" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework/services.jar" "$WORK_DIR"

sudo PATCH_FLAG_SECURE "$WORK_DIR/services"
sudo PATCH_SECURE_FOLDER "$WORK_DIR/services"
sudo PATCH_KNOX_GUARD "$WORK_DIR/services"
sudo PATCH_SSRM "$WORK_DIR/ssrm" "siop_a22_mt6769t" "dvfs_policy_mt6769t_xx"

sudo RECOMPILE "$APKTOOL" "$WORK_DIR/ssrm" "$FIRM_DIR/$TARGET_DEVICE/system/system/framework" "$WORK_DIR"
sudo RECOMPILE "$APKTOOL" "$WORK_DIR/services" "$$FIRM_DIR/$TARGET_DEVICE/system/system/framework" "$WORK_DIR"

sudo PATCH_BT_LIB "$FIRM_DIR/$TARGET_DEVICE" "$WORK_DIR"

sudo BUILD_IMG "$FIRM_DIR/$TARGET_DEVICE" "erofs" "$OUT_DIR"
