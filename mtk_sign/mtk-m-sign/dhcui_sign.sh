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


#######################################
# Check arguments
#######################################
if [ "$1" == "" ]; then
	MTK_BASE_PROJECT="kaios31_jpv"
	OUT_DIR="in"
	PRODUCT_OUT="/home/dhcui/dahui-share/mtk-m-sign/sign_in"
	MTK_PLATFORM="MT6739"
	MTK_PLATFORM_DIR=${MTK_PLATFORM,,}
	echo " 1 "${MTK_BASE_PROJECT}" 2 "${OUT_DIR}" 3 "${PRODUCT_OUT}" 4 "${MTK_PLATFORM}" 5 "${MTK_PLATFORM_DIR}""
else
	MTK_BASE_PROJECT=$1
fi

v2_file="mt6739/security/cert_config/img_list.txt"

# sign-image-nodeps
if [ -f "$v2_file" ]; then
	echo "v2 sign flow begin"
	echo python sign-image_v2/sign_flow.py -env_cfg sign-image_v2/env.cfg "${MTK_PLATFORM_DIR}" "${MTK_BASE_PROJECT}"

	PYTHONDONTWRITEBYTECODE=True BOARD_AVB_ENABLE= python sign-image_v2/sign_flow.py -env_cfg sign-image_v2/env.cfg "${MTK_PLATFORM_DIR}" "${MTK_BASE_PROJECT}"
	echo "v2 sign flow done"
else
	echo "v1 sign flow but not support"
	#MTK_PROJECT_NAME=$(get_build_var MTK_PROJECT_NAME)
	#MTK_PATH_CUSTOM=$(get_build_var MTK_PATH_CUSTOM)
	#MTK_SEC_SECRO_AC_SUPPORT=$(get_build_var MTK_SEC_SECRO_AC_SUPPORT)
	#MTK_NAND_PAGE_SIZE=$(get_build_var MTK_NAND_PAGE_SIZE)
	#echo perl vendor/mediatek/proprietary/scripts/sign-image/SignTool.pl "${MTK_BASE_PROJECT}" "${MTK_PROJECT_NAME}" "${MTK_PATH_CUSTOM}" "${MTK_SEC_SECRO_AC_SUPPORT}" "${MTK_NAND_PAGE_SIZE}" "${PRODUCT_OUT}" "${OUT_DIR}"
	#perl vendor/mediatek/proprietary/scripts/sign-image/SignTool.pl "${MTK_BASE_PROJECT}" "${MTK_PROJECT_NAME}" "${MTK_PATH_CUSTOM}" "${MTK_SEC_SECRO_AC_SUPPORT}" "${MTK_NAND_PAGE_SIZE}" "${PRODUCT_OUT}" "${OUT_DIR}"
fi
