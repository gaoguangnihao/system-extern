#/bash
echo 'begin!'
adb root 
adb shell setenforce 0
adb remount 
adb shell setprop kaios.log.enable 1 
#adb shell setprop kaios.log.filter hal:5,TCPSocket:5,TCPSocketc:5,TCPSocketp:5
#adb shell setprop kaios.log.filter Layers:5,hal:5,fontlist:5,fontinit:5,textrun:5,gfx2d:5,textrunui:5,cmapdata:5,textperf:5,userfonts:5
adb shell setprop kaios.log.filter Layers:5,hal:5,fontlist:5,fontinit:5,textrun:5,gfx2d:5,userfonts:5,frame:5
adb shell stop b2g 
adb shell start b2g
echo 'Done!'
