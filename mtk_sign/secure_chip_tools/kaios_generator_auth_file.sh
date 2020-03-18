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
	echo "Command: ./kaios_sign_da.sh" /home/dhcui/share_all_da_sign
	echo '*****************************************'
}
#echo 'copy da to /prebuilt/resignda'

path_da=$1


echo $path_da
if [ -f "$path_da/MTK_AllInOne_DA.bin" ]; then 
   	cp $path_da/MTK_AllInOne_DA.bin prebuilt/resignda
else
	usage
	exit
fi

if [ -f "$path_da/da_pl.bin" ]; then 
   	cp $path_da/da_pl.bin prebuilt/resignda
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


python resign_da.py prebuilt/resignda/MTK_AllInOne_DA.bin MT6739 settings/resignda/bbchips_pss.ini all out/resignda/MTK_AllInOne_DA.bin-sign



python resign_da.py prebuilt/resignda/da_pl.bin MT6739 settings/resignda/bbchips_pss.ini all out/resignda/DA_PL.bin-sign

echo "DA-BR DA-PL sign down"

echo '============================================='
echo '==copy sign da to the $path_da=='
echo '============================================='

cp out/resignda/MTK_AllInOne_DA.bin-sign $path_da/MTK_AllInOne_DA.bin-sign.bin
cp out/resignda/DA_PL.bin-sign $path_da/DA_PL.bin-sign.bin

echo "below is for test code for my pc"
cp out/resignda/MTK_AllInOne_DA.bin-sign /local/tools/mtk-download/MTK_AllInOne_DA.bin-mt6739sign.bin
cp out/resignda/DA_PL.bin-sign /local/tools/mtk-download/DA_PL.bin-mt6739sign.bin


echo success done 

