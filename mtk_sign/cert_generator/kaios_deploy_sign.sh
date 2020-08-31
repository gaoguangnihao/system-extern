#!/bin/bash

#######################################
# Initialize variables
#######################################
# return value 127 means that files not exist
# return value 128 means that parm NO. wrong
# return value 129 means that exec prom wrong

#######################################
# Specify temporarily folder path
#######################################

function usage() {

	#######################################
	# Dump usage howto
	#######################################

	echo "First, and select correct project"
	echo "Command: ./kaios_deploy_sign.sh $1 $2 $3 $4 $5"
	echo "$1 cert1 path"
	echo "$2 cert2_key path"
	echo "$3 image orign path"
	echo "$4 image dest path"
	echo "$5 sw version fot anti rollback" 
	echo " example :: /kaios_deploy_sign.sh /home/kai-user/keys_odm/MTK_Kaios31_jpv_jio /home/kai-user/keys_odm/MTK_Kaios31_jpv_jio /home/kai-user/mtk_m_jpv /home/dhcui/mtk_m_jpv_out 1"
}

##generator certs for image 

if [ $# -lt 5 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 127
fi

#FIXED-ME for copy script
CP_tools=mtk_cp_m_6731.sh

CURDIR="`pwd`"/"`dirname $0`"

CERT1_PATH=$1
CERT2_KEY_PATH=$2
IMG_SRC=$3
IMG_DST=$4
SW_VER=$5

if [ -d $IMG_SRC ];then
   echo 
else
   echo "error !! images source" $IMG_SRC "not exist"
   exit 127
fi
	
if [ -d $IMG_DST ];then
   echo
else
   echo "WARN !!  image output folder" $IMG_DST "not exist"
   mkdir -p $IMG_DST
fi

#FIXED-ME this need redefine for platform as img_key_deploy.sh
v2_file="mt6739/security/cert_config/img_list.txt"
ver_file="mt6739/security/cert_config/img_ver.txt"

#re-config image versio for anti rollback
sed -i "s#^img_ver =.*#img_ver = $SW_VER#" $CURDIR/$ver_file


echo "******************************************"
echo '**********KAIOS key deploy begin**********'
echo "******************************************"
sleep 3
bash $CURDIR/sign-image_v2/img_key_deploy.sh $CERT1_PATH $CERT2_KEY_PATH $IMG_DST

if [ $? -ne 0 ] ;then
	echo "error !! img_key_deploy.sh"
	exit 129
fi

#PLATFORM=mt6739 python ./sign-image_v2/img_key_deploy.py mt6739 kaios31_jpv cert1_key_path=/local/keys-mtk/kaios_orign/root_prvk.pem cert2_key_path=/local/keys-mtk/kaios_orign/img_prvk.pem root_key_padding=pss | tee img_key_deploy.log
echo "******************************************"
echo '**********KAIOS key deploy end************'
echo "******************************************"
echo "......"
sleep 3
echo 
echo "******************************************"
echo "**********KAIOS copy image begin**********"
echo "******************************************"
echo "......"
sleep 3
# copy image to the in folder 
rm -fr $IMG_DST/*
if [ -f $CURDIR/$CP_tools ]; then
	bash  $CURDIR/$CP_tools  $IMG_SRC $IMG_DST
else
    echo "copy tools not found"
	exit 127
fi

rm -fr $IMG_DST/*-verified*

echo "******************************************"
echo '**********KAIOS copy image end************'
echo "******************************************"
echo "......"
sleep 3
echo "......"
echo "******************************************"
echo '*********KAIOS sign image Begin***********'
echo "******************************************"
sleep 3

#######################################
# Check arguments
#######################################
if [ "$6" == "" ]; then
	MTK_BASE_PROJECT="kaios31_jpv"
	OUT_DIR="out"
	PRODUCT_OUT="out"
	MTK_PLATFORM="MT6739"
	MTK_PLATFORM_DIR=${MTK_PLATFORM,,}
	echo " 1 "${MTK_BASE_PROJECT}" 2 "${OUT_DIR}" 3 "${PRODUCT_OUT}" 4 "${MTK_PLATFORM}" 5 "${MTK_PLATFORM_DIR}""
else
	MTK_BASE_PROJECT=$6
fi

CURRDATE="`date +%Y-%m-%d-%H:%M:%S`"

# sign-image-nodeps
if [ -f "$CURDIR/$v2_file" ]; then
	PYTHONDONTWRITEBYTECODE=True BOARD_AVB_ENABLE= python $CURDIR/sign-image_v2/sign_flow.py -env_cfg $CURDIR/sign-image_v2/env.cfg "${MTK_PLATFORM_DIR}" "${MTK_BASE_PROJECT}" |tee $CURDIR/sign_flow_$CURRDATE.log
	if [ $? -ne 0 ] ;then
	echo -e "error !!! sign image"	
	exit 129
	fi
	echo "v2 sign flow done"
	echo "v2_file ($CURDIR/$v2_file)"
else
	echo "v1 sign flow but not support"
	echo "v2_file ($v2_file)"
	exit 129
	#MTK_PROJECT_NAME=$(get_build_var MTK_PROJECT_NAME)
	#MTK_PATH_CUSTOM=$(get_build_var MTK_PATH_CUSTOM)
	#MTK_SEC_SECRO_AC_SUPPORT=$(get_build_var MTK_SEC_SECRO_AC_SUPPORT)
	#MTK_NAND_PAGE_SIZE=$(get_build_var MTK_NAND_PAGE_SIZE)
	#echo perl vendor/mediatek/proprietary/scripts/sign-image/SignTool.pl "${MTK_BASE_PROJECT}" "${MTK_PROJECT_NAME}" "${MTK_PATH_CUSTOM}" "${MTK_SEC_SECRO_AC_SUPPORT}" "${MTK_NAND_PAGE_SIZE}" "${PRODUCT_OUT}" "${OUT_DIR}"
	#perl vendor/mediatek/proprietary/scripts/sign-image/SignTool.pl "${MTK_BASE_PROJECT}" "${MTK_PROJECT_NAME}" "${MTK_PATH_CUSTOM}" "${MTK_SEC_SECRO_AC_SUPPORT}" "${MTK_NAND_PAGE_SIZE}" "${PRODUCT_OUT}" "${OUT_DIR}"
fi

echo "******************************************"
echo '*********KAIOS sign image End**********'
echo "******************************************"
