#!/bin/bash

adb root
adb remount

echo "beging to logging about memory"

/local/code/master/kaios/tools/get_about_memory.py --uncompressed-gc-cc-log -m

echo "end logging"

curdate="`date +%Y-%m-%d-%H:%M:%S`";

mv /home/dhcui/about-memory-0 about-memory-$curdate


