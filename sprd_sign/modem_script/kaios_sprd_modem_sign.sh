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
	    echo "./packimage.sh /local/keys_sprd /home/dhcui/sprd_2020_0515"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 2 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
fi

echo "==============================================="
echo "======== sign modem img begin=========="
echo "==============================================="

KEY_PATH=$1
PRODUCT_OUT=$2

CURDIR="`dirname $0`"


#FIXED-ME should be dynamic parmerter for project name
PRODUCT_NAME=sp9820e_2c10aov
TARGET_NAME=sp9820e
#define some variable for copy 

if [[ "$TARGET_NAME" == "sp9820e"* ]]; then

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

    echo  $CURDIR/avb_sign_modem_v3.sh -c ${PRODUCT_OUT}/${PRODUCT_NAME}.xml -m ${Modem_unsign_dat} -g ${Modem_unsign_gdsp} -l ${Modem_unsign_ldsp} -d ${Modem_unsign_cm}
    
    
   bash $CURDIR/avb_sign_modem_v3.sh -c ${PRODUCT_OUT}/${PRODUCT_NAME}.xml -m ${Modem_unsign_dat} -g ${Modem_unsign_gdsp} -l ${Modem_unsign_ldsp} -d ${Modem_unsign_cm}
    
    
    exit 
    
    
    cd ${root_dir}
    cp sign_modem/SC9600_sharkle_pubcp_Feature_Phone_modem-sign.dat ${PRODUCT_OUT}
    cp sign_modem/SharkLE_LTEA_DSP_evs_off-sign.bin ${PRODUCT_OUT}
    cp sign_modem/SHARKLE1_DM_DSP-sign.bin ${PRODUCT_OUT}
    cp sign_modem/sharkle_cm4-sign.bin ${PRODUCT_OUT}
    cp ${Modem_NV} ${PRODUCT_OUT}
    cp ${Modem_DELTANV} ${PRODUCT_OUT}

    cd ${Modem_PATH}
    
    echo "End to modem sign" ${Modem_PATH} "root path " ${root_dir}
    
    ./build_pac.sh -a ${PRODUCT_NAME}-${VARIANT}-native -b PAC
    cd ${root_dir}
    cp ${PRODUCT_OUT}/${PRODUCT_NAME}-${VARIANT}-native_*.pac ./out/target/product/${TARGET_NAME}/

    cp $Modem_nv ./out/target/product/${TARGET_NAME}/ltenvitem.bin
    cp $Modem_dat ./out/target/product/${TARGET_NAME}/ltemodem.bin
    cp $Modem_ldsp ./out/target/product/${TARGET_NAME}/ltedsp.bin
    cp $Modem_gdsp ./out/target/product/${TARGET_NAME}/ltegdsp.bin
    cp $Modem_cm   ./out/target/product/${TARGET_NAME}/pmsys.bin
    cp $DELTANV ./out/target/product/${TARGET_NAME}/ltedeltanv.bin
    cp ${PRODUCT_OUT}/PM_sharkle_cm4.bin ./out/target/product/${TARGET_NAME}/wcnmodem.bin
    cp ${PRODUCT_OUT}/gnssmodem.bin ./out/target/product/${TARGET_NAME}/
    cp ${PRODUCT_OUT}/gnssbdmodem.bin ./out/target/product/${TARGET_NAME}/
    echo "dhcui-debug 2"
    exit 1

fi

echo "==============================================="
echo "======== sign modem img end=========="
echo "==============================================="
