#!/bin/bash
echo ""
echo Attempting to enable gecko log for ril/message/network modules..
echo ""

adb wait-for-device &&
adb shell stop b2g &&
adb root
adb remount
adb shell setprop persist.log.tag.ril VERBOSE


# enable gecko ril/message/network log
PREFS_JS=$(adb shell echo -n "/data/b2g/mozilla/*.default")/prefs.js
adb pull $PREFS_JS
echo 'user_pref("ril.debugging.enabled", true);' >> prefs.js &&
echo 'user_pref("mms.debugging.enabled", true);' >> prefs.js &&
echo 'user_pref("network.debugging.enabled", true);' >> prefs.js &&
adb push prefs.js $PREFS_JS &&

echo ""
echo Attempting to enable QCT propertity telephony log...
adb shell setprop persist.log.tag.ril VERBOSE &&
echo ""

echo Done!!
echo ""

adb shell start b2g
