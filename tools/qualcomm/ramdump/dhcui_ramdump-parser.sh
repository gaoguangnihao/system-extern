#! /bin/bash
echo ""
echo "Start ramdump parser.."
 
local_path=$PWD
ramdump=$local_path/
vmlinux=$local_path/vmlinux
out=$local_path/out
 
gdb=/local/code/quoin-mt/KaiOS/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-gdb
nm=/local/code/quoin-mt/KaiOS/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-nm
objdump=/local/code/quoin-mt/KaiOS/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin//arm-linux-androideabi-objdump
 
# git clone git://codeaurora.org/quic/la/platform/vendor/qcom-opensource/tools
ramparse_dir=/home/dhcui/dahui-share/qualcomm_crash/tools/linux-ramdump-parser-v2
########################################################################################
 
echo "cd $ramparse_dir"
cd $ramparse_dir
echo ""
 
echo -e "python ramparse.py -v $vmlinux -g $gdb  -n $nm  -j $objdump -a $ramdump -o $out -x"
#echo -e "python ramparse.py -v $vmlinux  -n $nm  -j $objdump -a $ramdump -o $out -x"
echo ""
 
# python 2.7.5
#python ramparse.py -v $vmlinux -g $gdb  -n $nm  -j $objdump -a $ramdump -o $out -x 
python ramparse.py --32-bit --v $vmlinux -g $gdb  -n $nm  -j $objdump -a $ramdump -o $out -x --force-hardware 8909
#python ramparse.py -v $vmlinux  -n $nm  -j $objdump -a $ramdump -o $out -x
 
cd $local_path
echo "out: $out"
echo ""
exit 0
