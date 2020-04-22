#!/bin/bash
set -x -e
adb root
adb remount

adb shell stop api-daemon
echo "Stop api-daemon"

echo "Update the files of api-daemon"
adb push ../kaios-services-prefs.js /system/b2g/defaults/pref/
adb shell mkdir -p /data/local/service/api-daemon/http_root
adb shell rm -r /data/local/service/api-daemon/*

adb push ../target/armv7-linux-androideabi/debug/api-daemon /data/local/service/api-daemon/api-daemon
adb shell chmod 777 /data/local/service/api-daemon/api-daemon
adb push config-device-dev.toml /data/local/service/api-daemon/config.toml
adb push ../prebuilts/http_root /data/local/service/api-daemon/http_root

adb shell start api-daemon
echo "Start api-daemon"
