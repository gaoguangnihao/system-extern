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

	echo "sign image ..."
	echo "first, and select correct project"
	echo "Command: ./sign_image.sh <BASE_PROJECT>"
}

##generator certs for image 

CP_tools=/local/tools/system-faq/system-extern/faq/mtk_cp_m_6731.sh
IMG_SRC=/local/code/mtk-m/KaiOS/out/target/product/kaios31_jpv
IMG_DST=/home/dhcui/mtk_m_jpv

v2_file="mt6739/security/cert_config/img_list.txt"


echo '**********KAIOS-key-deploy Begin**************'

bash ./sign-image_v2/img_key_deploy.sh

echo '***********KAIOS-key-deploy End*************'

echo '**********KAIOS-CP-IMG Begin***********'

# copy image to the in folder 
rm -fr $IMG_DST/*

bash  $CP_tools  $IMG_SRC $IMG_DST

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
if [ "$1" == "" ]; then
	MTK_BASE_PROJECT="kaios31_jpv"
	OUT_DIR="out"
	PRODUCT_OUT="out"
	MTK_PLATFORM="MT6739"
	MTK_PLATFORM_DIR=${MTK_PLATFORM,,}
	echo " 1 "${MTK_BASE_PROJECT}" 2 "${OUT_DIR}" 3 "${PRODUCT_OUT}" 4 "${MTK_PLATFORM}" 5 "${MTK_PLATFORM_DIR}""
else
	MTK_BASE_PROJECT=$1
fi


# sign-image-nodeps
if [ -f "$v2_file" ]; then
	echo "v2 sign flow begin"
	echo python sign-image_v2/sign_flow.py -env_cfg sign-image_v2/env.cfg "${MTK_PLATFORM_DIR}" "${MTK_BASE_PROJECT}"

	PYTHONDONTWRITEBYTECODE=True BOARD_AVB_ENABLE= python sign-image_v2/sign_flow.py -env_cfg sign-image_v2/env.cfg "${MTK_PLATFORM_DIR}" "${MTK_BASE_PROJECT}" |tee sign_flow.log
	echo "v2 sign flow done"
	echo "v2_file ($v2_file)"
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
