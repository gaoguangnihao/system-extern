#!/bin/bash
adb root
adb remount

adb shell setprop persist.debug.coredump all
adb shell "echo "/data/core/%e.%p.%t.core" > /proc/sys/kernel/core_pattern"
adb shell "echo "1" > /proc/sys/fs/suid_dumpable"




