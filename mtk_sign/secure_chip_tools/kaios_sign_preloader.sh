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

CURDIR="`pwd`"/"`dirname $0`"

echo $CURDIR
echo $path_preloader
#if [ -f "$path_preloader/preloader_NO_GFH.bin" ]; then
if [ -f "$path_preloader/preloader.bin" ]; then 
   	cp $path_preloader/preloader.bin $CURDIR/prebuilt/pbp/preloader.bin
else
	usage
	exit
fi


#CURDIR="`pwd`"/"`dirname $0`"

echo "preloader sign begin"

#cat settings/pbp/pl_key.ini
#[KEY]
#sw_ver = "1"
#rootkey = "keys/pbp/root_prvk.pem"
#imgkey = "keys/pbp/img_prvk.pem"
#ac_key = "0x112233445566778899aabbccddeeff"

## below commond need root_prvk.pem to generator key_cert.bin 
## and sign the preloader

python $CURDIR/pbp.py -i $CURDIR/settings/pbp/pl_key.ini -k $CURDIR/out/pbp/key_cert.bin -g $CURDIR/settings/pbp/pl_gfh_config_cert_chain.ini -c $CURDIR/settings/pbp/pl_content.ini -func sign -o $CURDIR/out/pbp/preloader-signed.bin $CURDIR/prebuilt/pbp/preloader.bin

echo "use key_cert.bin to sign"

python $CURDIR/pbp.py -k $CURDIR/out/pbp/key_cert.bin -g $CURDIR/settings/pbp/pl_gfh_config_cert_chain.ini  -c $CURDIR/settings/pbp/pl_content.ini -func sign -o $CURDIR/out/pbp/preloader-signed.bin $CURDIR/prebuilt/pbp/preloader.bin

#python resign_da.py prebuilt/resignda/MTK_AllInOne_DA.bin MT6739 settings/resignda/bbchips_pss.ini all out/resignda/MTK_AllInOne_DA.bin

echo "preloader sign done"

echo '============================================='
echo '==copy sign preloader to the path_preloader=='
echo '============================================='

echo $path_preloader
cp $CURDIR/out/pbp/preloader-signed.bin $path_preloader/preloader_kaios31_jpv.bin

echo success done 

