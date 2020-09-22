#!/bin/bash
if [ $# -ne 1 ]; then
    echo "getmem.sh <device_id>"
    adb devices
    exit 1
fi


device=$1

function getMemInfo() {
    adb -s $device wait-for-device shell uptime > uptime.txt
    adb -s $device shell cat /sys/kernel/debug/memblock/reserved > memblock_reserved.txt
    adb -s $device shell procrank    > procrank.txt
    adb -s $device shell procrank -c > procrank_c.txt
    adb -s $device shell procrank -C > procrank_cap.txt

    adb -s $device shell df      > df.txt

    adb -s $device shell dumpsys                > dumpsys_full.txt
    adb -s $device shell dumpsys meminfo        > dumpsys_meminfo.txt
    adb -s $device shell dumpsys meminfo --oom  > dumpsys_meminfo_oom.txt
    adb -s $device shell dumpsys meminfo -a     > dumpsys_meminfo_a.txt
    adb -s $device shell dumpsys SurfaceFlinger > dumpsys-surface_flinger.txt

    adb -s $device shell dmesg > dmesg.txt
    adb -s $device shell getprop | grep dalvik       > GC.txt
    adb -s $device shell lsmod                       > lsmod.txt
    #adb -s $device logcat -d -v threadtime           > logcat.txt
    #adb -s $device logcat -d -v threadtime -b events > logcat-events.txt

    adb -s $device shell cat /proc/cpuinfo           > cpuinfo.txt
    adb -s $device shell cat /proc/iomem             > iomem.txt
    adb -s $device shell cat /proc/meminfo           > meminfo.txt
    adb -s $device shell cat /proc/modules           > modules.txt
    adb -s $device shell cat /proc/pagetypeinfo      > pagetypeinfo.txt
    adb -s $device shell cat /proc/slabinfo          > slabinfo.txt
    adb -s $device shell cat /sys/kernel/debug/slab/alloc_trace > slab_alloc_trace.txt
    adb -s $device shell cat /proc/swaps             > swaps.txt
    adb -s $device shell cat /proc/sys/vm/swappiness > swappiness.txt
    adb -s $device shell cat /proc/vmallocinfo       > vmalloc.txt
    adb -s $device shell cat /proc/vmstat            > vmstat.txt
    adb -s $device shell cat /proc/zoneinfo          > zoneinfo.txt

    adb -s $device shell cat /sys/block/zram0/*              > zram0.txt
    adb -s $device shell cat /sys/block/zram0/mm_stat        > zram-mm_stat.txt

	adb -s $device shell 'grep . /sys/class/kgsl/kgsl/proc/*/*' > kgsl_proc.txt
    adb -s $device shell cat /sys/class/kgsl/kgsl/mapped     > kgsl_mapped.txt
    adb -s $device shell cat /sys/class/kgsl/kgsl/vmalloc    > kgsl_vmalloc.txt
    adb -s $device shell cat /sys/class/kgsl/kgsl/page_alloc > kgsl_pg_alloc.txt
    adb -s $device shell ls  /sys/class/kgsl/kgsl/proc       > kgsl_procs.txt
    adb -s $device pull /sys/class/kgsl/kgsl/proc  kgsl_procs

	adb -s $device shell 'grep . /sys/kernel/debug/cma/*/used' > cma_used.txt
    adb -s $device shell cat /sys/kernel/debug/dma_buf/dmaprocs > ion_dmaprocs.txt
    adb -s $device shell cat /sys/kernel/debug/dma_buf/bufinfo  > ION_bufinfo.txt
    adb -s $device shell cat /sys/kernel/debug/ion/heaps/system > ion_consumption.txt
    adb -s $device shell cat /sys/kernel/debug/ion/iommu        > ion_mmu.txt
    adb -s $device shell cat /sys/kernel/mm/ksm/pages_sharing   > ksm-sharing.txt
    adb -s $device shell cat /sys/kernel/mm/ksm/pages_shared    > ksm-shared.txt
    adb -s $device shell \"ls /sys/kernel/mm/ksm/\"             > ksm_params.txt
    adb -s $device shell \"ls /sys/kernel/mm/ksm/*\"           >> ksm_params.txt
    adb -s $device shell \"ls /sys/block/zram0/\"               > zram_params.txt
    adb -s $device shell \"ls /sys/block/zram0/*\"             >> zram_params.txt

    adb -s $device shell cat /sys/module/lowmemorykiller/parameters/adj     > adj.txt
    adb -s $device shell cat /sys/module/lowmemorykiller/parameters/minfree > lmk.txt

    adb -s $device pull /sys/kernel/debug/ion/ ion

    adb -s $device shell ps > process.txt
    adb -s $device shell ps -t > threads.txt

    adb -s $device shell uname -a             > Kernel_version.txt
    adb -s $device shell getprop              > buildProp.txt
    adb -s $device shell zcat /proc/config.gz > config.txt
    adb -s $device shell cat /firmware/verinfo/ver_info.txt > ver_info.txt

    #KaiOS
    adb -s $device shell b2g-info > b2g-info.txt
    adb -s $device shell b2g-procrank > b2g-procrank.txt
    adb -s $device shell b2g-procrank -C > b2g-procrank-C.txt
    for PID in `adb -s $device shell ps | grep b2g | awk '{print $2}'`; do echo $PID; adb -s $device shell showmap $PID >> showmap_$PID.txt; done
}

echo "wait-for-device $device"
adb -s $device wait-for-device
#echo "push procrank to /system/xbin/"
#adb -s $device push procrank /system/xbin/
path=$(adb -s $device shell date | tr -d '\r\n' | sed 's/[: ]/_/g')
mkdir "memlog-$path"
cd "memlog-$path"
let iter=1
while [ 1 ]; do
    echo "start get iteration ${iter}"
    mkdir $iter
    cd $iter
    getMemInfo
    cd ..
    let iter=iter+1
    echo "sleep 300"
    sleep 300
done
