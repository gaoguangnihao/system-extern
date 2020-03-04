#!/bin/sh 
ADB_FLAGS=
if [ -n "$1" ]; then
ADB_FLAGS="-s $1"
fi

adb devices
adb $ADB_FLAGS reboot bootloader
fastboot devices

echo "Flash Apps..."
fastboot $ADB_FLAGS flash boot boot.img
fastboot $ADB_FLAGS flash system system.img
fastboot $ADB_FLAGS flash cache cache.img
fastboot $ADB_FLAGS flash userdata userdata.img
fastboot $ADB_FLAGS flash recovery recovery.img

echo "Flash image done..."
fastboot $ADB_FLAGS reboot

echo "Wait for device connect..."
adb wait-for-device

echo "Just close the terminal as you wish."
