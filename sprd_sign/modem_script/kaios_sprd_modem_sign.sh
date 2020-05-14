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
	    echo "1 $1 is root key path"
	    echo "2 $2 is source image path"
	    echo "3 $3 is tools root paths"
	    echo "4 $4 build type user or userdebug"
		echo "5 $5 production name"
		echo "6 $6 target name"
	    echo "./packimage.sh /local/tools/system-faq/system-extern/sprd_sign/packimage_scripts/signimage/sprd/config
 /home/dhcui/test_sprd_pier2m/source /local/tools/system-faq/system-extern/sprd_sign userdebug sp9820e_2c10aov sp9820e"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 6 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
fi

echo "==============================================="
echo "======== sign modem img begin=========="
echo "==============================================="
sleep 3

KEY_PATH=$1
PRODUCT_OUT=$2
ROOT_PATH=$3
VARIANT=$4
PRODUCT_NAME=$5
TARGET_NAME=$6

CURDIR="`dirname $0`"

#FIXED-ME should be dynamic parmerter for project name

#define some variable for copy 

if [[ "$TARGET_NAME" == "sp9820e"* ]]; then

#define modem image name 

Modem_nv=${PRODUCT_OUT}/sharkle_pubcp_Feature_Phone_L278_DVT2_nvitem.bin
Modem_dat=${PRODUCT_OUT}/SC9600_sharkle_pubcp_Feature_Phone_modem-sign.dat
Modem_ldsp=${PRODUCT_OUT}/SharkLE_LTEA_DSP_evs_off-sign.bin
Modem_gdsp=${PRODUCT_OUT}/SHARKLE1_DM_DSP-sign.bin
Modem_cm=${PRODUCT_OUT}/sharkle_cm4-sign.bin
DELTANV=${PRODUCT_OUT}/sharkle_pubcp_Feature_Phone_L278_DVT2_deltanv.bin

Modem_NV=${PRODUCT_OUT}/sharkle_pubcp_Feature_Phone_L278_DVT2_deltanv.bin
Modem_DELTANV=${PRODUCT_OUT}/sharkle_pubcp_Feature_Phone_L278_DVT2_nvitem.bin

Modem_unsign_dat=${PRODUCT_OUT}/SC9600_sharkle_pubcp_Feature_Phone_modem.dat
Modem_unsign_ldsp=${PRODUCT_OUT}/SharkLE_LTEA_DSP_evs_off.bin
Modem_unsign_gdsp=${PRODUCT_OUT}/SHARKLE1_DM_DSP.bin
Modem_unsign_cm=${PRODUCT_OUT}/sharkle_cm4.bin
    
#begin to sign modem image 

bash $CURDIR/avb_sign_modem_v3.sh -c ${PRODUCT_OUT}/${PRODUCT_NAME}.xml -m ${Modem_unsign_dat} -g ${Modem_unsign_gdsp} -l ${Modem_unsign_ldsp} -d ${Modem_unsign_cm} -t ${ROOT_PATH}  -k $KEY_PATH

if [ $? != 0 ];then
   echo "!!! error !!! avb_sign_modem_v3"
   exit 129
fi

#copy signed image to out folder
cp ${PRODUCT_OUT}/sign_modem/SC9600_sharkle_pubcp_Feature_Phone_modem-sign.dat ${PRODUCT_OUT} ||{ echo "can not copy sign_modem"; exit 127;}
cp ${PRODUCT_OUT}/sign_modem/SharkLE_LTEA_DSP_evs_off-sign.bin ${PRODUCT_OUT} ||{ echo "can not copy sign_modem"; exit 127;}
cp ${PRODUCT_OUT}/sign_modem/SHARKLE1_DM_DSP-sign.bin ${PRODUCT_OUT} ||{ echo "can not copy sign_modem"; exit 127;}
cp ${PRODUCT_OUT}/sign_modem/sharkle_cm4-sign.bin ${PRODUCT_OUT} ||{ echo "can not copy sign_modem"; exit 127;}

#clean signed modem image 
rm -fr ${PRODUCT_OUT}/sign_modem ||{ echo "can not delete sign_modem"; exit 127;}

#begin to make pac 
echo ${PRODUCT_NAME}-${VARIANT}-native 

#get the modem config name for pacage name
MODEM_CONFIG=KAIOS
for pac_dir in `cd $PRODUCT_OUT && find -maxdepth 2 -name SHARKLE_9820E*`;do
MODEM_CONFIG=${pac_dir##*/}
done

bash $CURDIR/kaios_build_pac.sh -a ${PRODUCT_NAME}_k_native-${VARIANT}-native -b PAC -p ${PRODUCT_OUT} -t ${ROOT_PATH} -m ${MODEM_CONFIG}

if [ $? != 0 ];then
   echo "!!! error !!! kaios_build_pac"
   exit 129
fi

#FIXED-ME why rename that's modem bin files 
exit

cd ${root_dir}

cp $Modem_nv ./out/target/product/${TARGET_NAME}/ltenvitem.bin
cp $Modem_dat ./out/target/product/${TARGET_NAME}/ltemodem.bin
cp $Modem_ldsp ./out/target/product/${TARGET_NAME}/ltedsp.bin
cp $Modem_gdsp ./out/target/product/${TARGET_NAME}/ltegdsp.bin
cp $Modem_cm   ./out/target/product/${TARGET_NAME}/pmsys.bin
cp $DELTANV ./out/target/product/${TARGET_NAME}/ltedeltanv.bin
cp ${PRODUCT_OUT}/PM_sharkle_cm4.bin ./out/target/product/${TARGET_NAME}/wcnmodem.bin
cp ${PRODUCT_OUT}/gnssmodem.bin ./out/target/product/${TARGET_NAME}/
cp ${PRODUCT_OUT}/gnssbdmodem.bin ./out/target/product/${TARGET_NAME}/

fi

echo "==============================================="
echo "======== sign modem img end=========="
echo "==============================================="
