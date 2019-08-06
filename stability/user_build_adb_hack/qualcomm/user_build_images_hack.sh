#!/bin/bash

# Test if tmp/ exists already and delete it if yes.
if [ -d "tmp" ] ; then
  echo "tmp folder exists. So remove it."
  rm -rf tmp
fi
mkdir tmp

# Test if out/ exists already and delete it if yes.
if [ -d "out" ] ; then
  echo "out folder exists. So remove it."
  rm -rf out
fi
mkdir out

# Open boot.img and check if it us user build
echo "Hacking boot.img"
BOOT_IMAGE_CREATE=`./bin/unmkbootimg -i boot.img`
mv kernel ramdisk.cpio.gz tmp/
cd tmp/
mkdir ramdisk
cd ramdisk
gunzip -c ../ramdisk.cpio.gz | cpio -i
RO_ADB_SECURE=`grep -w ro.adb.secure default.prop`
if [ "$RO_ADB_SECURE" == "" ] ; then
  echo "boot.img is not user build!!!"
  exit 0
fi

# Replace with hacked user build adbd
cp ../../bin/adbd_hack sbin/adbd
sed -i 's/ro.secure=1/ro.secure=0/g' default.prop
sed -i 's/ro.debuggable=0/ro.debuggable=1/g' default.prop
sed -i 's/ro.adb.secure=1//g' default.prop

# Create a new ramdisk based on the changes
find . | cpio -o -H newc | gzip > ../ramdisk.cpio.gz
cd ../
#BOOT_IMAGE_CREATE=${BOOT_IMAGE_CREATE#*:}
#BOOT_IMAGE_CREATE=${BOOT_IMAGE_CREATE/"boot.img"/"../out/boot_hack.img"}
#$BOOT_IMAGE_CREATE
echo "Creating a hacked boot.img"
../bin/mkbootimg --base 0 --pagesize 2048 --kernel_offset 0x80008000 --ramdisk_offset 0x81000000 --second_offset 0x80f00000 --tags_offset 0x80000100 --cmdline 'console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 earlyprintk androidboot.selinux=permissive' --kernel kernel --ramdisk ramdisk.cpio.gz -o ../out/boot_hack.img
if [ "$?" -ne "0" ] ; then
  echo "Fail to create a hacked boot.img"
  exit 0
else
  echo "Done."
fi
cd ../

# Open system.img and check if it is user build
echo "Hacking system.img"
LD_LIBRARY_PATH=./lib/out_host_linux-x86_lib64 ./bin/simg2img system.img tmp/system.raw
cd tmp/ && mkdir system && mount -t ext4 -o loop system.raw system/
BUILD_TYPE=`grep -w ro.build.type system/build.prop`
BUILD_TYPE=${BUILD_TYPE#*=}
if [ "$BUILD_TYPE" != "user" ] ; then
  echo "system.img is not user build!!!"
  exit 0
fi

# Open omni.ja and revise adb.js
cp system/b2g/omni.ja .
unzip -d omni omni.ja
cd omni
sed -i '/configFuncs.indexOf/a\ \ \ \ enableAdb\ =\ true' chrome/chrome/content/devtools/adb.js
zip -r omni.ja *
cp omni.ja ../system/b2g/omni.ja
cd ../../

# Create a hacked system.img
echo "Creating hacked system.img"
LD_LIBRARY_PATH=./lib/out_host_linux-x86_lib64 ./bin/make_ext4fs -s -T -1 -S tmp/ramdisk/file_contexts -L system -l 838860800 -a system out/system_hack.img tmp/system/ 2>&1 /dev/null
echo "Done."

# Umount system image
# echo "Umount system image"
umount tmp/system/

# Flash hacked boot.img and system.img
echo "Update hacked boot.img and system.img to device and then reboot..."
FASTBOOT_AVAILABLE=`./bin/fastboot devices`
if [ "$FASTBOOT_AVAILABLE" == "" ] ; then
  echo "Device is not in fastboot mode!!!"
  exit 0
fi
./bin/fastboot flash boot out/boot_hack.img
./bin/fastboot flash system out/system_hack.img
./bin/fastboot reboot
