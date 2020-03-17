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
	echo "sign preloader ..."
	echo "PLease given path of the preloader.bin"
	echo '*****************************************'
	echo "Command: ./sign_preloader.sh out/target/product/kaios31_jpv"
	echo '*****************************************'
}
#echo 'copy preloader to /prebuilt/pbp'

path_preloader=$1

echo $path_preloader
if [ -f "$path_preloader/preloader.bin" ]; then 
   	cp $path_preloader/preloader.bin prebuilt/pbp/preloader.bin
else
	usage
	exit
fi

echo "preloader sign begin"

#cat settings/pbp/pl_key.ini
#[KEY]
#sw_ver = "1"
#rootkey = "keys/pbp/root_prvk.pem"
#imgkey = "keys/pbp/img_prvk.pem"
#ac_key = "0x112233445566778899aabbccddeeff"

## below commond need root_prvk.pem to generator key_cert.bin 
## and sign the preloader

python pbp.py -i settings/pbp/pl_key.ini -k out/pbp/key_cert.bin -g settings/pbp/pl_gfh_config_cert_chain.ini -c settings/pbp/pl_content.ini -func sign -o out/pbp/preloader-signed.bin prebuilt/pbp/preloader.bin

#python pbp.py -k prebuilt/pbp/key_cert.bin -g settings/pbp/pl_gfh_config_cert_chain.ini  -c settings/pbp/pl_content.ini -func sign -o out/pbp/preloader-signed.bin prebuilt/pbp/preloader.bin

#python resign_da.py prebuilt/resignda/MTK_AllInOne_DA.bin MT6739 settings/resignda/bbchips_pss.ini all out/resignda/MTK_AllInOne_DA.bin

echo "preloader sign down"

echo '============================================='
echo '==copy sign preloader to the path_preloader=='
echo '============================================='

cp out/pbp/preloader-signed.bin $path_preloader/preloader_kaios31_jpv.bin

echo success done 

