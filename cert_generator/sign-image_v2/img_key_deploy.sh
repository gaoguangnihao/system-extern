#!/bin/bash

#######################################
# Initialize variables
#######################################

#PLATFORM=mt6739 python ./sign-image_v2/img_key_deploy.py mt6739 kaios31_jpv cert1_key_path=/local/keys-mtk/kaios_jpv/root_prvk.pem cert2_key_path=/local/keys-mtk/kaios_jpv/img_prvk.pem root_key_padding=pss | tee img_key_deploy.log

function usage() {

	#######################################
	# Dump usage howto
	#######################################

	echo "sign image ..."
	echo "first, and select correct project"
	echo "Command: ./sign-image_v2/img_key_deploy.py $1 $2"
	echo "$1 cert1 path"
	echo "$2 cert2_key path"

}

if [ $# -lt 2 ];then
	echo "############WORNG PARG ###########"
	usage
	exit
else 
        echo "Begin to deploy"
fi

echo $1
echo $2 

PLATFORM=mt6739 python ./sign-image_v2/img_key_deploy.py mt6739 kaios31_jpv cert1_key_path=$1/root_prvk.pem cert2_key_path=$2/img_prvk.pem root_key_padding=pss | tee img_key_deploy.log

