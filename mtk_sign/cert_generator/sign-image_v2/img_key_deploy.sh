#!/bin/bash

#######################################
# Initialize variables
#######################################

# return value 127 means that files not exist
# return value 128 means that parm NO. wrong
# return value 129 means that exec prom wrong

#PLATFORM=mt6739 python ./sign-image_v2/img_key_deploy.py mt6739 kaios31_jpv cert1_key_path=/local/keys-mtk/kaios_jpv/root_prvk.pem cert2_key_path=/local/keys-mtk/kaios_jpv/img_prvk.pem root_key_padding=pss | tee img_key_deploy.log

#PLATFORM=mt6739  FIXED-ME

function usage() {
	#######################################
	# Dump usage howto
	#######################################
	echo "1 cert1_path"
	echo "2 cert2_key path"
	echo "3 image path"
	echo "Command: python img_key_deploy.py cert1_path cert2_key_path image_path"

}

CERT1_PATH=$1
CERT2_KEY_PATH=$2
IMAGE_PATH=$3

if [ $# -lt 3 ];then
	echo "############WORNG PARG ###########"
	usage
	exit 128
fi
#CURDIR="`pwd`"/"`dirname $0`"
CURDIR="`dirname $0`"

#FIXED-ME should be config the env.cfg

#in_path = /home/dhcui/mtk_m_jpv
#out_path = /home/dhcui/mtk_m_jpv
#cert1_dir = ../${PLATFORM}/security/cert_config/cert1
#cert2_key_dir = ../${PLATFORM}/security/cert_config/cert2_key
#img_list_path = ../${PLATFORM}/security/cert_config/img_list.txt
#img_ver_path = ../${PLATFORM}/security/cert_config/img_ver.txt
#x509_template_path = x509_template/
#mkimage_tool_path = mkimage20/

python $CURDIR/reconfig_env.py $CURDIR/env.cfg $IMAGE_PATH
#FIXED-ME for platform name and project name
if [ -d $CERT1_PATH ];then
	PLATFORM=mt6739 python $CURDIR/img_key_deploy.py mt6739 kaios31_jpv cert1_key_path=$CERT1_PATH/root_prvk.pem cert2_key_path=$CERT2_KEY_PATH/img_prvk.pem root_key_padding=pss | tee $CURDIR/img_key_deploy.log
	if [ $? != 0 ];then
	echo "error!! img_key_deploy"
	exit 129
	fi
else
   	echo "error !!! NOT A FOLDER"
	exit 128
fi

