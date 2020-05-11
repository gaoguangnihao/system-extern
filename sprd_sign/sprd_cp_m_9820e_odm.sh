#used to cp img to release folder
#SPRD base use ResearchDownload to download

#!/bin/bash
##########init valiable ###################
# return value 127 means that files not exist
# return value 128 means that parm NO. wrong
# return value 129 means that exec prom wrong

#########################################
function usage() {

	#######################################
	# Dump usage howto
	#######################################

	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
	    echo "1 $1 is root project path"
	    echo "3 $2 is dest image path"
	    echo "4 $3 is build type user or userdebug"
	    echo "./sprd_cp_m_98203_odm.sh /local/code/pier2_m_sfp_jio/KaiOS/ "
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 3 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
fi

echo "==============================================="
echo "======== copy img files begin=========="
echo "==============================================="

ROOT_DIR=$1
DST_DIR=$2
VARIANT=$3
PRODUCT_NAME=sp9820e_2c10aov
#define some variable for copy 


IMG_DIR=${ROOT_DIR}/out/target/product/${PRODUCT_NAME}
Modem_PATH=vendor/sprd/release/IDH/Script
Modem_SHARKLE_PATH=${ROOT_DIR}/vendor/sprd/release/IDH/Modem/FM_BASE_19A_W*_9820e_K_CUSTOMER/sharkle_pubcp_Feature_Phone_builddir
SHARKLE_PATH=$ROOT_DIR${Modem_PATH}/../${PRODUCT_NAME}_k_native-${VARIANT}-native/SHARKLE_*


Modem_NV=${Modem_SHARKLE_PATH}/../sharkle_pubcp_Feature_Phone_L278_DVT2_builddir/sharkle_pubcp_Feature_Phone_L278_DVT2_deltanv.bin
Modem_DELTANV=${Modem_SHARKLE_PATH}/../sharkle_pubcp_Feature_Phone_L278_DVT2_builddir/sharkle_pubcp_Feature_Phone_L278_DVT2_nvitem.bin

if [ ! -d $Modem_SHARKLE_PATH ]; then
	Modem_SHARKLE_PATH=${ROOT_DIR}/vendor/sprd/release/IDH/Modem/FM_BASE_17B_*_9820e_K_CUSTOMER/sharkle_pubcp_Feature_Phone_builddir
fi
	  
if [ -d $DST_DIR ]; then
   echo "Begin to copy to "$DST_DIR
else
   echo "Creat floder about image copy"
   mkdir -p $DST_DIR || echo "Creat floder error" $DST_DIR
fi

# define image and file list to copy 

  img_files=(
   ${IMG_DIR}/boot.img
   ${IMG_DIR}/cache.img
   ${IMG_DIR}/fdl1.bin
   ${IMG_DIR}/fdl2.bin
   ${IMG_DIR}/prodnv.img
   ${IMG_DIR}/recovery.img
   ${IMG_DIR}/sml.bin
   ${IMG_DIR}/tos.bin
   ${IMG_DIR}/u-boot.bin
   ${IMG_DIR}/u-boot-spl-16k.bin
   ${IMG_DIR}/usbmsc.img
   ${IMG_DIR}/userdata.img
   ${IMG_DIR}/system_raw.img
   ${IMG_DIR}/sp9820e_2c10aov.xml

 )

## modem image list from pac.sh define
echo "sharkle image files path is "${SHARKLE_PATH}
echo "modem sharkle image files path is "${Modem_SHARKLE_PATH}

  modem_img_files=(
   ${SHARKLE_PATH}/PM_sharkle_cm4*
   ${SHARKLE_PATH}/gnssmodem.bin
   ${SHARKLE_PATH}/gnssbdmodem.bin
   ${SHARKLE_PATH}/sprd_240320*
   ${Modem_SHARKLE_PATH}/SC9600_sharkle_pubcp_Feature_Phone_modem.dat
   ${Modem_SHARKLE_PATH}/SharkLE_LTEA_DSP_evs_off.bin
   ${Modem_SHARKLE_PATH}/SHARKLE1_DM_DSP.bin
   ${Modem_SHARKLE_PATH}/../sharkle_cm4_builddir/sharkle_cm4.bin
   ${Modem_SHARKLE_PATH}/../sharkle_pubcp_Feature_Phone_L278_DVT2_builddir/sharkle_pubcp_Feature_Phone_L278_DVT2_deltanv.bin
   ${Modem_SHARKLE_PATH}/../sharkle_pubcp_Feature_Phone_L278_DVT2_builddir/sharkle_pubcp_Feature_Phone_L278_DVT2_nvitem.bin
   

 )
 
if [ -f ${IMG_DIR}/*fota_meta.zip ];then
    cp -f ${IMG_DIR}/*fota_meta.zip  $DST_DIR/
fi


COPY_IMG_ERR=0

for img_file in ${img_files[@]};do
	
	cp -f ${img_file}  ${DST_DIR}/	
	if [ "$?" != "0" ];then
	  echo 
		echo "**** copy fail: ${img_file} ****"
		echo 
		COPY_IMG_ERR=1
		exit 127
	fi
done

for modem_img_file in ${modem_img_files[@]};do
	
	cp -f ${modem_img_file}  ${DST_DIR}/
	
	if [ "$?" != "0" ];then
	  echo 
		echo "**** copy fail: ${modm_img_files} ****"
		echo 
		COPY_IMG_ERR=1
		exit 127
	fi
done


echo "==============================================="
if [ $COPY_IMG_ERR != 0 ];then
	echo "===========  copy error ============="
  exit 128
else
	echo "======== copy img files OK =========="
fi
echo "==============================================="
echo


#tar -zcvf $DST_DIR.tar.gz $DST_DIR/

echo 
