#!/bin/bash

if [ -d "omni" ] ; then
  echo "omni folder exists. So remove it."
  rm -rf omni
fi

if [ -f "omni.ja" ] ; then
  echo "omni.ja folder exists. So remove it."
  rm -f omni.ja
fi

#some tools need install 

#apt-get install mtd-utils

#some information 

#cat /proc/mtd
#mtdinfo /dev/mtd
#/dev/ubi
#ls /sys/class/ubi#
#http://www.linux-mtd.infradead.org/faq/ubifs.html

# nand flash fot Micron 
#modprobe nandsim first_id_byte=0x2c second_id_byte=0x38 third_id_byte=0x00 fourth_id_byte=0x26

#FIXME parameter maybe need change according to hardware ? not sure 

modprobe nandsim first_id_byte=0xec second_id_byte=0xd5 third_id_byte=0x51 fourth_id_byte=0xa6

ls /dev/mtd*

flash_erase /dev/mtd0 0 0

# udev should create MTD device nodes automatically.
# If it does not, we can create /dev/mtd0 manually with
# mknod /dev/mtd0 c 90 0


# Wipe the MTD device out. Note, we could use flash_eraseall, but we do not
# want to lose erase counters
ubiformat /dev/mtd0 -O 4096 -f system.img

# Load UBI module
modprobe ubi mtd=0,4096

if [ -d "system" ] ; then
  echo "system folder exists. So remove it."
  rm -rf system
fi

mkdir system


mount -t ubifs ubi0_0 system/




BUILD_TYPE=`grep -w ro.build.type system/build.prop`
BUILD_TYPE=${BUILD_TYPE#*=}
if [ "$BUILD_TYPE" != "user" ] ; then
  echo "system.img is not user build!!!"
  umount system
  rmmod ubifs ubi nandsim
  exit 0
fi


#hack omni.ja

cp system/b2g/omni.ja .
unzip -d omni omni.ja
cd omni
sed -i '/configFuncs.indexOf/a\ \ \ \ enableAdb\ =\ true' chrome/chrome/content/devtools/adb.js
zip -r omni.ja *
cp omni.ja ../system/b2g/omni.ja
cd ../


# Create a hacked system.img
echo "Creating hacked system.img"

# exec mkfs FIXME parameter maybe need change according to project
./bin/mkfs_ubifs -F -r system -o system_hack.img -m 4096 -e 253952 -c 1291 -v ubi_android.ini

echo "Done"

#exec ubinize FIXME parameter maybe need change according to project
./bin/ubinize -o out/system_hack.img -m 4096 -p 262144 -O 4096 -v ubi_android.ini

# Attach mtd0 to UBI - UBI will detect that the MTD device is
# empty and automatically format it. This command will also create
# UBI device 0 and udev should create /dev/ubi0 node
#ubiattach /dev/ubi_ctrl -m 0

## Create an UBI volume - the created volume will be empty
#ubimkvol /dev/ubi0 -N test_volume -s 500MiB

# Mount UBIFS - it will automatically format the empty volume
#mount -t ubifs ubi0:test_volume /mnt/ubifs

#It is also possible to wipe out an existing UBIFS volume represented by /dev/ubi0_0 using the following command:

#ubiupdatevol /dev/ubi0_0 -t




#Now you have the filesystem in /mnt/ubifs. Use the following to get rid of it:
echo "unmount and rmmod"
umount system
rmmod ubifs ubi nandsim

echo "Copy hack image file to share disk for windows"

cp -R out /home/dhcui/dahui-share/



