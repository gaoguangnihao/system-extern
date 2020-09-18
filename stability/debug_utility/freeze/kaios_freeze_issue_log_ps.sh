#used to cp img to release folder
#mtk base use flashtool to download

#!/bin/bash

## we should double check if key drive or focus issue?
##  1.1 adb log check focus and gecko key status 
##  1.2 adb shell getevent -l to check kernel 
##  1.3 use webide check system app and others variables ,as document.activeElement
##  1.4 check system keyevent process 
##  1.5 check windows/app status (adb shell b2g-info) find who is front app 
##     and why no focus or others 
  
## 2.check device crash or not ,maybe mutex issue ,Kaios not support double crash
##  adb shell debuggerd -b $PID
  
## 3.check top info 
##  adb shell top -t -d 3 -m 10 -n 5
##   and try to find who is block CPU 

## 4.others 
##  adb shell df
##  adb shell strace -p $PID 
##  bugreport files
## try to  get b2g-ps and b2g-info about freeze issue
## check DB errors


CURDIR="`dirname $0`"
CURRDATE="`date +%Y-%m-%d-%H-%M-%S`"


#adb remount 

echo "step 1 : begin to get b2g* info and basic log info"


adb shell toolbox ps | (
  IFS= read header

  while read user pid ppid vsize rss wchan ps status name; do
    pids="${pids} ${pid}"
    pid_user[${pid}]="${user}"
    pid_ppid[${pid}]="${ppid}"
    pid_rest[${pid}]="${rest}"
    pid_user[${pid}]="${vsize}"
    pid_ppid[${pid}]="${rss}"
    pid_rest[${pid}]="${wchan}"
	pid_rest[${pid}]="${ps}"
	pid_rest[${pid}]="${status}"
	pid_rest[${pid}]="${name}"
    echo ${name}
  done

)

