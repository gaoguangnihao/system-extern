## we should double check if key drive or focus issue?
*  1.1 adb log check focus and gecko key status 
*  1.2 adb shell getevent -l to check kernel 
*  1.3 use webide check system app and others variables ,as document.activeElement
*  1.4 check system keyevent process 
*  1.5 check windows/app status (adb shell b2g-info) find who is front app 
      and why no focus or others 
  
## 2.check device crash or not ,maybe mutex issue ,Kaios not support double crash
*  adb shell debuggerd -b $PID
  
## 3.check top info 
*  adb shell top -t 
*  and try to find who is block CPU 

## 4.others 
*  adb shell df
*  adb shell strace -p $PID 
