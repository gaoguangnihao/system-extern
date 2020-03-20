##########init valiable ###################
#########################################
function usage() {

	#######################################
	# Dump usage howto
	#######################################

	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
	    echo "1 $1 is root key path"
	    echo "2 $2 is imgae key path"
	    echo "3 $3 is pre sign image path"
	    echo "4 $4 is signed imgae path"
	    echo "5 $5 is a flag ,wiil be sign preloader or not"
	    echo "6 $6 is a flag , will be sign da or not"
	    echo "Try ./kaios_key_sign.sh /home/kai-user/keys_odm/MTK_Kaios31_jpv_jio /home/kai-user/keys_odm/MTK_Kaios31_jpv_jio /home/kai-user/mtk_m_jpv /home/dhcui/mtk_m_jpv_out null null"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 6 ];then
	echo "############WORNG PARG ###########"
	usage
	exit
else
        echo "Begin to deploy sign"
fi



CERT1_PATH=$1
CERT2_KEY_PATH=$2
INPUT_IMG_PATH=$3
OUTPUT_IMG_PATH=$4
PRELOADER=$5
SIGN_DA=$6

#temp path will be change
DA_BIN_PATH=/home/dhcui/dahui-share/da_sign

##beging to deploy sign certs and sign the image use img_prvk.pem 

bash cert_generator/kaios_deploy_sign.sh $CERT1_PATH $CERT2_KEY_PATH $INPUT_IMG_PATH $OUTPUT_IMG_PATH

##sign common image done!!!

##beging to sign NO-GFH preloader image
echo $OUTPUT_IMG_PATH

if [[ $PRELOADER = "preloader" ]]; then
  bash secure_chip_tools/kaios_sign_preloader.sh $OUTPUT_IMG_PATH
else
  echo "!!! preloader not signed"
fi

if [[ $SIGN_DA = "signda" ]]; then
bash secure_chip_tools/kaios_sign_da.sh $DA_BIN_PATH

##we really to generator auth_sv5 files like da just need check tools 
## DAA/SLA/ROOT/IMG keys
python secure_chip_tools/toolauth.py -i secure_chip_tools/settings/toolauth/toolauth_key.ini -g secure_chip_tools/settings/toolauth/toolauth_gfh_config_pss.ini secure_chip_tools/out/toolauth/auth_sv5.auth

cp secure_chip_tools/out/toolauth/auth_sv5.auth $DA_BIN_PATH

##we will be generator scert file alsoe 
echo "to be done about this files "
else
 echo "!!! da-br.da-pl not signed"
fi


