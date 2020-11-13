## we should double check if key drive or focus issue?
*  1.1 adb log check focus and gecko key status 
*  1.2 adb shell getevent -l to check kernel 
*  1.3 use webide check system app and others variables ,as document.activeElement
*  1.4 check system keyevent process 
*  1.5 check windows/app status (adb shell b2g-info) find who is front app and why no focus or others 

## 2.check device crash or not ,maybe mutex issue ,Kaios not support double crash

*  adb shell debuggerd -b $PID
  
## 3.check top info 
*  adb shell top -t -d 3 -m 10 -n 5
*  and try to find who is block CPU 

## 4.log files cehck 
*  4.1 adb shell df
*  4.2 adb shell strace -p $PID 
*  4.3 bugreport files
*  4.4 try to  get b2g-ps and b2g-info about freeze issue
*  4.5 check DB errors

## Disk sleep process status

*  5.1 echo w > /proc/sysrq-trigger
*  5.2 check kernel message

## wiki info

*https://wiki.kaiostech.com/index.php/Debugging_info#freeze