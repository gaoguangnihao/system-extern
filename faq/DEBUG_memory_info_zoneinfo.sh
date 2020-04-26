#!/bin/bash  

# MTK6731-M JPV -DFP
# adb shell b2g-info
# adb shell top 
# adb shell b2g-ps
# adb shell showmap $PID
# adb shell procrank
# adb shell procmem $pid
# adb shell "cat /proc/meminfo"
# adb shell "cat /proc/$pid/maps"
# /proc/mtk_memcfg/memory_layout
# Virtual kernel memory layout
# Phy Layout
# mtk availMem = mMemInfoReader.getFreeSize() + mMemInfoReader.getCachedSize()
#                - SECONDARY_SERVER_MEM
# search "available” in UART logs you will see 

#[    0.000000] <0>-(0)[0:swapper]Memory: 373628K/507136K available (11792K kernel code, 1004K rwdata, 4592K rodata, 1024K init, 2989K bss, #133508K reserved, 0K cma-reserved, 0K highmem)
#[    0.000000] <0>-(0)[0:swapper]Virtual kernel memory layout:
#[    0.000000] <0>    vector  : 0xffff0000 - 0xffff1000   (   4 kB)
#[    0.000000] <0>    fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
#[    0.000000] <0>    vmalloc : 0xe0800000 - 0xff800000   ( 496 MB)
#[    0.000000] <0>    lowmem  : 0xc0000000 - 0xe0000000   ( 512 MB)
#[    0.000000] <0>    pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
#[    0.000000] <0>    modules : 0xbf000000 - 0xbfe00000   (  14 MB)
#[    0.000000] <0>      .text : 0xc0008000 - 0xc1100000   (17376 kB)
#[    0.000000] <0>      .init : 0xc1200000 - 0xc1300000   (1024 kB)
#[    0.000000] <0>      .data : 0xc1300000 - 0xc13fb118   (1005 kB)
#[    0.000000] <0>       .bss : 0xc13fd000 - 0xc16e8404   (2990 kB)

#[    0.259605] <0>.(0)[1:swapper/0][PHY layout]tee_reserved_mem   :   0x5fe00000 - 0x5fe3ffff (0x40000)
#[    0.260781] <0>.(0)[1:swapper/0][debug]available DRAM size = 0x20000000
#[    0.260781] <0>[PHY layout]FB (dt) :  0x5fe60000 - 0x5ff7ffff  (0x120000)

#[    0.000000] <0>-(0)[0:swapper][PHY layout]kernel   :   0x40000000 - 0x445fffff (0x04600000)
#[    0.000000] <0>-(0)[0:swapper][PHP layout]kernel   :   0x44640000 - 0x55ffffff (0x119c0000)
#[    0.000000] <0>-(0)[0:swapper][PHY layout]kernel   :   0x56c00000 - 0x5dffffff (0x07400000)
#[    0.000000] <0>-(0)[0:swapper][PHY layout]kernel   :   0x5e100000 - 0x5fbffFff   x01b00000)
#[    0.000000] <0>-(0)[0:swapper][PHY layout]kernel   :   0x5ff80000 - 0x5fffffff (0x00080000)

# memory avaliable = total ram size - (modem size + framebuffer size + reserved)

for((i=1;i<=100;i++));  
do
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
echo @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 adb shell cat /proc/zoneinfo 
done
