#!/bin/bash
# Test if out/ exists already and delete it if yes.
if [ -d "out" ] ; then
  echo "out folder exists. So remove it."
  rm -rf out
fi
mkdir out


# Open system.img and check if it is user build
echo "Hacking system.img"
#LD_LIBRARY_PATH=./lib/out_host_linux-x86_lib64 ./bin/simg2img system.img tmp/system.raw
cd tmp/ && mkdir system && mount -t ext4 -o loop system.bin system/
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


