## 1. adb shell getevent -lt

## 2. get b2g info 

* adb shell dmesg > $OUTPUT_DIR/dmesg.log
* adb shell b2g-info > $OUTPUT_DIR/b2g-info
* adb shell b2g-ps > $OUTPUT_DIR/b2g-ps
* adb shell top -m 15 -d 1 -t -n 30 > $OUTPUT_DIR/top.log
* adb shell debuggerd -b $B2GID > $OUTPUT_DIR/b2g-bt.tx


## 3. maybe we need all thread backtrace use GDB tool also

```
$ ./run-gdb.sh B2G_PID

(gdb) set logging file backtrace_dump
(gdb) set logging on
(gdb) set pagination off
(gdb) thread apply all bt
(gdb) set logging off

```

## 4. how to get mini dump files

Pull raw file of minidump, dumpfile (xxx.dmp) and 
extra file will save under “/data/b2g/mozilla/Crash Reports/pending/” 
if you didn't send them to server

## 5. get prop

adb shell getprop

## 6. get partition 

dev/block/platform/soc.0/7824900.sdhci (qualcomm)

## 7. dev/graphics

## 8. apps 
```
data/local/webapps
system/b2g/webapps

adb pull system/b2g/webapps/launcher.gaiamobile.org
adb pull system/b2g/webapps/system.gaiamobile.org
```
## 9. idb 

adb pull data/local/storage/permanent/chrome/idb

#10. lcd parameter

sys/class/graphics/fb0
vendor/mediatek/proprietary/hardware/liblights/lights.c
adb shell "echo 100 > /sys/class/leds/lcd-backlight/brightness"
adb shell lookat -s 0x0000007e 0x400388f0 (register set on SPRD)


## 11. hal log
```
#/bash
echo 'begin!'
adb root 
adb shell setenforce 0
adb remount 
adb shell setprop kaios.log.enable 1 
#nsSocketTransport for socket thread 
#nsRequestObserverProxy for OnStopRequest
#nsStreamCopier for nsAsyncStreamCopier.cpp
#adb shell setprop kaios.log.filter hal:5,TCPSocket:5,TCPSocketc:5,TCPSocketp:5,nsStreamCopier:5
adb shell setprop kaios.log.filter Camera:5
#adb shell setprop kaios.log.filter nsSocketTransport:5,nsRequestObserverProxy:5,nsStreamCopier:5
#adb shell setprop kaios.log.filter Layers:5,hal:5,fontlist:5,fontinit:5,textrun:5,gfx2d:5,textrunui:5,cmapdata:5,textperf:5,userfonts:5
#adb shell setprop kaios.log.filter Layers:5,hal:5,fontlist:5,fontinit:5,textrun:5,gfx2d:5,userfonts:5,frame:5
adb shell stop b2g 
adb shell start b2g
echo 'Done!'
```
#12 android logs

##13 ftrace 
```
FOR 4.9 Kernel

PROCEDURE for Static/idle screen usecase: 

adb root
adb remount
adb shell 
su

echo 51200 > /d/tracing/buffer_size_kb && echo "" > /d/tracing/set_event
cat /d/tracing/buffer_size_kb  ----> make sure it shows above value.  If NOT set it again and check it.

echo "" > /d/tracing/trace && echo "sched:* power:* msm_bus:* kgsl:* msm_low_power:* cpufreq_interactive:* timer:* irq:* workqueue:* clk:*" > /d/tracing/set_event
echo irq:* >> /d/tracing/set_event 
echo clk:* >> /d/tracing/set_event 
cat /d/tracing/set_event

Start usecase and run below command and remove usb

sleep 10 && echo 0 > /d/tracing/tracing_on && echo 1 > /d/tracing/tracing_on && sleep 10 && echo 0 > /d/tracing/tracing_on &

After 1min, 
adb pull /sys/kernel/debug/tracing/trace trace_log.txt
```

```
For 3.10 kernel

Static idle usecase
=================== 

adb root
adb remount
adb shell
su

start usecase and run below command and remove USB

sleep 10 && echo 51200 > /d/tracing/buffer_size_kb && echo "" > /d/tracing/set_event && echo "" > /d/tracing/trace && echo "sched:* power:* msm_bus:* kgsl:* msm_low_power:* cpufreq_interactive:* timer:* irq:* workqueue:* clk:* " > /d/tracing/set_event && echo 0 > /d/tracing/tracing_on && echo 1 > /d/tracing/tracing_on && sleep 10 && echo 0 > /d/tracing/tracing_on & 

After 1min, 
adb pull /sys/kernel/debug/tracing/trace trace_log.txt
```

##14 power 

```
adb root
adb remount
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_gpubusy/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_pwr_request_state/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_pwr_set_state/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_pwrstats/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_buslevel/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_pwrlevel/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_clk/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_bus/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_rail/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/adreno_cmdbatch_queued/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/adreno_cmdbatch_submitted/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/adreno_cmdbatch_retired/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_user_pwrlevel_constraint/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_constraint/enable"

adb shell "echo 1 > /sys/kernel/debug/tracing/events/msm_bus/bus_update_request/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/msm_bus/bus_agg_bw/enable"

adb shell "echo 1 > /sys/kernel/debug/tracing/tracing_on"

adb shell cat /sys/kernel/debug/tracing/trace_pipe > traces_kgsl.txt
```

