#!/bin/bash  
  
for((i=1;i<=100;i++));  
do
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 adb shell cat /proc/zoneinfo 
done
