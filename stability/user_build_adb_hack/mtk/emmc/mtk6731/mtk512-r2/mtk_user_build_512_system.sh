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


# Open system.img and check if it is user build
echo "Hacking system.img"
LD_LIBRARY_PATH=./lib ./bin/simg2img system.img tmp/system.raw
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
sed -i 's/this.remoteDebuggerEnabled&&(!(this.lockEnabled&&this.locked)||usbFuncActive)/true/' chrome/chrome/content/devtools/adb.js
zip -r omni.ja *
cp omni.ja ../system/b2g/omni.ja
cd ../../

# Create a hacked system.img
echo "Creating hacked system.img"
LD_LIBRARY_PATH=./lib ./bin/make_ext4fs -s -S tmp/ramdisk/file_contexts -l 1073741824 -a system out/system_hack.img tmp/system/
echo "Done."

# Umount system image
# echo "Umount system image"
 umount tmp/system/

