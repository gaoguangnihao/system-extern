#!/bin/bash

#######################################
# Initialize variables
#######################################

#######################################
# Specify 
#######################################

function usage() {
	#######################################
	# Dump usage howto
	#######################################
	echo '*****************************************'
	echo "sign DA-BR and DA-PL ..."
	echo '*****************************************'
	echo "Command: ./kaios_sign_da.sh /home/dhcui/share_all_da_sign key_path da_name out_path"
	echo '*****************************************'
}
#echo 'copy da to /prebuilt/resignda'

path_da=$1
keypath=$2
da_name=$3
da_out_path=$4
CURDIR="`pwd`"/"`dirname $0`"

echo $path_da
echo $CURDIR
echo $da_name

if [ $# -lt 4 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
fi

if [ -f "$path_da/MTK_AllInOne_DA.bin" ]; then 
   	cp $path_da/MTK_AllInOne_DA.bin $CURDIR/prebuilt/resignda
else
	usage
	echo "WWWWW maybe you need copy MTK_AllInOne_DA.bin to the $path_da"
	exit 128
fi

if [ -f "$path_da/da_pl.bin" ]; then 
   	cp $path_da/da_pl.bin $CURDIR/prebuilt/resignda
else
	usage
	echo "WWWWW maybe you need copy pl bin to the $path_da"
fi

echo "da sign begin"

#cat cat bbchips_pss.ini

#[MT6739]
#hw_code = 0x6739
#hw_sub_code = 0x8a00
#hw_ver = 0xca00
#sw_ver = 0x0
#load_region0_sigtype = epp
#load_region0_sigpad = pss
#load_region0_key = keys/resignda/epp_prvk.pem
#load_region1_sigtype = da
#load_region1_sigpad = pss
#load_region1_key = keys/pbp/root_prvk.pem
#load_region2_sigtype = da
#load_region2_sigpad = pss
#load_region2_key = keys/pbp/root_prvk.pem

#parpre config files fot generator da
 
img_key="/img_prvk.pem"
root_key="/root_prvk.pem"

#config bbchips_pss.ini
sed -i "s#^load_region0_key =.*#load_region0_key = $keypath$img_key#" $CURDIR/settings/resignda/bbchips_pss.ini
sed -i "s#^load_region1_key =.*#load_region1_key = $keypath$root_key#" $CURDIR/settings/resignda/bbchips_pss.ini
sed -i "s#^load_region2_key =.*#load_region2_key = $keypath$root_key#" $CURDIR/settings/resignda/bbchips_pss.ini

python $CURDIR/resign_da.py $CURDIR/prebuilt/resignda/MTK_AllInOne_DA.bin MT6739 $CURDIR/settings/resignda/bbchips_pss.ini all $CURDIR/out/resignda/MTK_AllInOne_DA.bin-sign

if [ $? != 0 ];then
	echo "error!! resign_da for all in one"
	exit 129
fi


python $CURDIR/resign_da.py $CURDIR/prebuilt/resignda/da_pl.bin MT6739 $CURDIR/settings/resignda/bbchips_pss.ini all $CURDIR/out/resignda/DA_PL.bin-sign

if [ $? != 0 ];then
	echo "error!! resign_da for da_pl"
	exit 129
fi

echo '============================================='
echo '==copy sign da to the $path_da=='
echo '============================================='

cp $CURDIR/out/resignda/MTK_AllInOne_DA.bin-sign $path_da/MTK_AllInOne_DA_$da_name-kaios-sign.bin
cp $CURDIR/out/resignda/DA_PL.bin-sign $path_da/DA_PL_$da_name-kaios-sign.bin

echo "below is fot server package to odm"

echo "below is for test code for my pc"
if [ -d $da_out_path ]; then
cp $CURDIR/out/resignda/MTK_AllInOne_DA.bin-sign $da_out_path/MTK_AllInOne_DA_$da_name-kaios-sign.bin
cp $CURDIR/out/resignda/DA_PL.bin-sign $da_out_path/DA_PL_$da_name-kaios-sign.bin
fi

if [ -d "/local/tools/mtk-download" ]; then
	cp $CURDIR/out/resignda/MTK_AllInOne_DA.bin-sign /local/tools/mtk-download/MTK_AllInOne_DA_$da_name-kaios-sign.bin
	cp $CURDIR/out/resignda/DA_PL.bin-sign /local/tools/mtk-download/DA_PL_$da_name-kaios-sign.bin
fi


echo success done 

