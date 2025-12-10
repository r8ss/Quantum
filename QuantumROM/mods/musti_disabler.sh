#!/bin/bash
set -e

#
# A simple Samsung services disabler by Ian Macdonald.
#

if [ "$#" -ne 1 ]; then
    echo "Usage: bash $0 <ROM_DIR>"
    exit 1
fi

ROM_DIR=$1

# Product
# Deleting frp line from $MODEL product build.prop.
sed -i "\~ro.frp.pst=/dev/block/bootdevice/by-name/frp~d" $ROM_DIR/product/etc/build.prop

# Vendor
# Deleting $MODEL stock recovery.
rm -rf "$ROM_DIR/vendor/recovery-from-boot.p"

disable_fbe() {
  local md5
  local i
  fstab_files=`grep -lr 'fileencryption' $ROM_DIR/vendor/etc`

  #
  # Exynos devices = fstab.exynos*.
  # MediaTek devices = fstab.mt*.
  # Snapdragon devices = fstab.qcom, fstab.emmc, fstab.default
  #
  for i in $fstab_files; do
    if [ -f $i ]; then
      echo " - Disabling file-based encryption (FBE) for /data..."
      echo " -   Found $i."
      # This comments out the offending line and adds an edited one.
      sed -i -e 's/^\([^#].*\)fileencryption=[^,]*\(.*\)$/# &\n\1encryptable\2/g' $i
    fi
  done
}

disable_fde() {
  local md5
  local i
  fstab_files=`grep -lr 'forceencrypt' $ROM_DIR/vendor/etc`

  #
  # Exynos devices = fstab.exynos*.
  # MediaTek devices = fstab.mt*.
  # Snapdragon devices = fstab.qcom, fstab.emmc, fstab.default
  #
  for i in $fstab_files; do
    if [ -f $i ]; then
      echo " - Disabling full-disk encryption (FDE) for /data..."
      echo " -   Found $i."
      md5=$( md5 $i )
      # This comments out the offending line and adds an edited one.
      sed -i -e 's/^\([^#].*\)forceencrypt=[^,]*\(.*\)$/# &\n\1encryptable\2/g' $i
      file_changed $i $md5
    fi
  done
}


echo " "
echo "Multi-disabler v3.1 for Samsung devices"
echo "running Android 9 or later."
echo "by Ian Macdonald, enhanced by afaneh92"
echo " "

disable_fbe
disable_fde
echo " "
echo "Multi-disabler"
