if "%~1"=="" (
    ADB_FLAGS=
) else (
    ADB_FLAGS="-s %~1"
)

adb devices
adb %ADB_FLAGS% reboot bootloader
fastboot devices

echo "Flash Apps..."
fastboot %ADB_FLAGS% flash boot boot.img
fastboot %ADB_FLAGS% flash system system.img
fastboot %ADB_FLAGS% flash cache cache.img
fastboot %ADB_FLAGS% flash userdata userdata.img
fastboot %ADB_FLAGS% flash recovery recovery.img

echo "Done..."
fastboot %ADB_FLAGS% reboot

echo "Just close the terminal as you wish."
