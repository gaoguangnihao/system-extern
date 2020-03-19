#!/bin/bash

#######################################
# Initialize variables
#######################################


#######################################
# Specify temporarily folder path
#######################################

function usage() {

	#######################################
	# Dump usage howto
	#######################################

	echo "First, and select correct project"
	echo "Command: ./kaios_deploy)sign.sh $1 $2 $3 $4"
	echo "$1 cert1 path"
	echo "$2 cert2_key path"
	echo "$3 image orign path"
	echo "$4 image dest path"
	echo " example :: /kaios_deploy_sign.sh /home/kai-user/keys_odm/MTK_Kaios31_jpv_jio /home/kai-user/keys_odm/MTK_Kaios31_jpv_jio /home/kai-user/mtk_m_jpv /home/dhcui/mtk_m_jpv_out"
}

##generator certs for image 

if [ $# -lt 4 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit
else 
        echo "Begin to deploy"
fi

CP_tools=mtk_cp_m_6731.sh
#IMG_SRC=/local/code/mtk-m/KaiOS/out/target/product/kaios31_jpv
#IMG_DST=/home/dhcui/mtk_m_jpv

CURDIR="`pwd`"/"`dirname $0`"

IMG_SRC=$3
IMG_DST=$4

if [ -d $3 ];then
   echo "path is ok $3"
else
   echo "\033[31m ERROR $3 WRONG FOLDER !!! \033[0m"
   exit
fi
	
if [ -d $4 ];then
   echo "path is ok $4"
else
   echo "\033[31m ERROR $4 WRONG FOLDER !!! \033[0m"
   exit
fi

v2_file="mt6739/security/cert_config/img_list.txt"


echo '**********KAIOS-key-deploy Begin**************'
echo $CURDIR

bash $CURDIR/sign-image_v2/img_key_deploy.sh $1 $2

Rva=$?

if [ $Rva -ne 0 ] ;then
	echo -e "\033[31m ERROR $Rva exit !!! \033[0m"	
	exit
fi

#PLATFORM=mt6739 python ./sign-image_v2/img_key_deploy.py mt6739 kaios31_jpv cert1_key_path=/local/keys-mtk/kaios_orign/root_prvk.pem cert2_key_path=/local/keys-mtk/kaios_orign/img_prvk.pem root_key_padding=pss | tee img_key_deploy.log

echo '***********KAIOS-key-deploy End*************'

echo '**********KAIOS-CP-IMG Begin***********'

# copy image to the in folder 
rm -fr $IMG_DST/*

if [ -f $CURDIR/$CP_tools ]; then

	bash  $CURDIR/$CP_tools  $IMG_SRC $IMG_DST
else
        echo "copy tools not found"
	exit
fi
echo 'delete the orign verified image'

P_dir='pwd'

rm -fr $IMG_DST/*-verified*

echo '**********KAIOS-CP-IMG End***********'

echo 
echo 
echo

echo '**********KAIOS-SIGN-Begin***********'
#######################################
# Check arguments
#######################################
if [ "$5" == "" ]; then
	MTK_BASE_PROJECT="kaios31_jpv"
	OUT_DIR="out"
	PRODUCT_OUT="out"
	MTK_PLATFORM="MT6739"
	MTK_PLATFORM_DIR=${MTK_PLATFORM,,}
	echo " 1 "${MTK_BASE_PROJECT}" 2 "${OUT_DIR}" 3 "${PRODUCT_OUT}" 4 "${MTK_PLATFORM}" 5 "${MTK_PLATFORM_DIR}""
else
	MTK_BASE_PROJECT=$5
fi


# sign-image-nodeps
if [ -f "$CURDIR/$v2_file" ]; then
	echo "v2 sign flow begin"
	echo python $CURDIR/sign-image_v2/sign_flow.py -env_cfg $CURDIR/sign-image_v2/env.cfg "${MTK_PLATFORM_DIR}" "${MTK_BASE_PROJECT}"

	PYTHONDONTWRITEBYTECODE=True BOARD_AVB_ENABLE= python $CURDIR/sign-image_v2/sign_flow.py -env_cfg $CURDIR/sign-image_v2/env.cfg "${MTK_PLATFORM_DIR}" "${MTK_BASE_PROJECT}" |tee sign_flow.log
	echo "v2 sign flow done"
	echo "v2_file ($CURDIR/$v2_file)"
else
	echo "v1 sign flow but not support"
	echo "v2_file ($v2_file)"
	#MTK_PROJECT_NAME=$(get_build_var MTK_PROJECT_NAME)
	#MTK_PATH_CUSTOM=$(get_build_var MTK_PATH_CUSTOM)
	#MTK_SEC_SECRO_AC_SUPPORT=$(get_build_var MTK_SEC_SECRO_AC_SUPPORT)
	#MTK_NAND_PAGE_SIZE=$(get_build_var MTK_NAND_PAGE_SIZE)
	#echo perl vendor/mediatek/proprietary/scripts/sign-image/SignTool.pl "${MTK_BASE_PROJECT}" "${MTK_PROJECT_NAME}" "${MTK_PATH_CUSTOM}" "${MTK_SEC_SECRO_AC_SUPPORT}" "${MTK_NAND_PAGE_SIZE}" "${PRODUCT_OUT}" "${OUT_DIR}"
	#perl vendor/mediatek/proprietary/scripts/sign-image/SignTool.pl "${MTK_BASE_PROJECT}" "${MTK_PROJECT_NAME}" "${MTK_PATH_CUSTOM}" "${MTK_SEC_SECRO_AC_SUPPORT}" "${MTK_NAND_PAGE_SIZE}" "${PRODUCT_OUT}" "${OUT_DIR}"
fi

echo '**********KAIOS-SIGN-End***********'
