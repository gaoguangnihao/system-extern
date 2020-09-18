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

function usage() {

	#######################################
	# Dump usage howto
	#######################################
	echo "please select correct parameter"
	echo "1 $1 Folder logs name"
	echo "2 $2 Log Saved Absolute Path"
	echo " example :: /kaios_freeze_issue_log.sh MTK_Kaios31_jpv_jio"
	echo "            /home/kai-user/"
}

if [ $# -lt 2 ];then
	echo "************WORNG PARG ***********"
	usage
	echo "************WORNG PARG ***********"
	exit
fi

NAME=$1
LOG_PATH=$2

#for arg in "$@"
# do
#    case "$arg" in
#     "--oom")
#      report_oom=1
#        ;;lsge
#      *)
#        args="${args} ${arg}"
#        ;;
#    esac
#  done
echo "***************************************"
echo "****************KaiOS******************"
echo "***************************************"
echo 
if [ -d $LOG_PATH$NAME ];then
   echo "Clean old logs ...."
   echo
   rm -fr "$LOG_PATH$NAME"
   mkdir -p "$LOG_PATH$NAME"
else
   echo "!! WARN !!  image output folder" $LOG_PATH$NAME "not exist"
   echo "Create $LOG_PATH$NAME folder"
   mkdir -p "$LOG_PATH$NAME"
fi
echo "!! WARN !!  Please don't plug out USB cable"
echo "            until see success info"
echo 

adb wait-for-device root
#adb remount 

echo "step 1 : begin to get b2g* info and basic log info"

adb shell b2g-info >$LOG_PATH$NAME/$CURRDATE-b2g-info.txt
adb shell b2g-ps >$LOG_PATH$NAME/$CURRDATE-b2g-ps.txt
adb shell ps >$LOG_PATH$NAME/$CURRDATE-ps.txt
adb shell ps -t >$LOG_PATH$NAME/$CURRDATE-ps-t.txt
adb logcat -v threadtime -d >$LOG_PATH$NAME/$CURRDATE-logcat.txt
adb shell dmesg >$LOG_PATH$NAME/$CURRDATE-kernel.txt

echo "step 2 : begin to get debuggerd* info"

#below code from b2g-ps to get pid 
adb shell toolbox ps | (
  IFS= read header
  new_hdr="APPLICATION    SEC"
  if [ "${report_oom}" == "1" ]; then
    new_hdr="${new_hdr}  OOM_ADJ  OOM_SCORE  OOM_SCORE_ADJ "
  fi

  while read user pid ppid rest; do
    pids="${pids} ${pid}"
    pid_user[${pid}]="${user}"
    pid_ppid[${pid}]="${ppid}"
    pid_rest[${pid}]="${rest}"
    if [ "${rest/*b2g*/b2g}" = "b2g" ]; then
        b2g[${pid}]=1
    fi
  done

  for pid in ${pids}; do
    ppid="${pid_ppid[${pid}]}"
    # If this thread/process is b2g or its parent is b2g then we output
    # it (using the -t option will cause toolbox ps to show all of threads)
    if [ "${b2g[${pid}]}" == "1" -o "${b2g[${ppid}]}" == "1" ]; then
    
    for i in `seq 0 4`
    do
    # define one second per times
    echo "try to get $pid info $i "
    adb shell debuggerd -b $pid > $LOG_PATH$NAME/$CURRDATE-$pid-$i-kaios.txt;sleep 1
    done
    fi
  done
)

## define 2 seconds and 10 times
echo "step 3:  begin to get top info"
adb shell top -t -d 2 -m 10 -n 10 >$LOG_PATH$NAME/$CURRDATE-top.txt

echo "step 4:  begin to get df info"
adb shell df >$LOG_PATH$NAME/$CURRDATE-df.txt


echo "step 5:  begin to bugreport logs ,it need long time"
adb shell bugreport >$LOG_PATH$NAME/$CURRDATE-bugreport.txt
echo 

echo "step 6:  begin pull DB files"
adb pull data/local/storage/permanent/chrome $LOG_PATH$NAME/$CURRDATE-chrome
echo "Done success logs"

echo "***************************************"
echo "****************KaiOS******************"
echo "***************************************"
