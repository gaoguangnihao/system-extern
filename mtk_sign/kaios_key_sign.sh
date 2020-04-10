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
	    echo "2 $2 is imgae key path"
	    echo "3 $3 is pre sign image path"
	    echo "4 $4 is signed imgae path"
	    echo "5 $5 is a flag ,wiil be sign preloader or not"
	    echo "6 $6 is a flag , will be sign da or not"
	    echo "7 $7 is da image path for will be signed"
	    echo "8 $8 is efuse to generator"
	    echo "./kaios_key_sign.sh /home/kai-user/key_path /home/kai-user/key_path /home/kai-user/image_path /home/dhcui/image_out preloader signda /home/dhcui/da_path efuse"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 8 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
fi

CERT1_PATH=$1
CERT2_KEY_PATH=$2
INPUT_IMG_PATH=$3
OUTPUT_IMG_PATH=$4
PRELOADER=$5
SIGN_DA=$6
DA_BIN_PATH=$7
EFUSE=$8

#prepare boot and system image with new dm key
#Note boot_system/mt6731_jpv_jio/ should be re-define FIXED-ME
bash boot_system/boot_dm.sh $INPUT_IMG_PATH boot_system/mt6731_jpv_jio/

if [ $? != 0 ];then
   echo "error !! about DM sign boot and system images"
   exit 129
fi
sleep 3
echo "......"
echo "......"
echo "success !!! DM sign "
#done
if [ -d "secure_chip_tools/out" ] ; then
   echo "secure_chip_tools out folder exists. So remove it."
   rm -rf secure_chip_tools/out
fi
mkdir secure_chip_tools/out
##beging to deploy sign certs and sign the image use img_prvk.pem 
bash cert_generator/kaios_deploy_sign.sh $CERT1_PATH $CERT2_KEY_PATH $INPUT_IMG_PATH $OUTPUT_IMG_PATH
if [ $? != 0 ];then
   echo "error !! deploy sign certs and sign the image "
   exit 129
fi

echo "success !! kaios_deploy_sign"
sleep 3
##sign common image done!!!

##beging to sign NO-GFH preloader image
if [[ $PRELOADER = "preloader" ]]; then
   bash secure_chip_tools/kaios_sign_preloader.sh $OUTPUT_IMG_PATH
   if [ $? != 0 ];then
   echo "error !! preloader sign error "
   exit 129
   fi
else
   echo "!!!!! preloader not signed"
fi

echo "success !! preloader sign \n"
sleep 3

if [[ $SIGN_DA = "signda" ]]; then
   bash secure_chip_tools/kaios_sign_da.sh $DA_BIN_PATH

   if [ $? != 0 ];then
   echo "error!! preloader sign error "
   exit 129
   fi
   echo "success !! signda "
   sleep 3
##we really to generator auth_sv5 files like da just need check tools 
## DAA/SLA/ROOT/IMG keys

   bash secure_chip_tools/kaios_generator_auth_file.sh $DA_BIN_PATH
   if [ $? != 0 ];then
     echo "error !! auth_sv5 files"
     exit 129
   fi
   echo "success !! auth_sv5 generator "
   sleep 3

   bash secure_chip_tools/kaios_generator_scert_file.sh $DA_BIN_PATH
   if [ $? != 0 ];then
   echo "error !! scert_file"
   exit 129
   fi
   echo "success !! auth_sv5 generator "
   sleep 3
##we will be generator scert file also
else
    echo "!!!!! da-br.da-pl not signed"
fi

##beging to sign NO-GFH preloader image
if [[ $EFUSE = "efuse" ]]; then
   bash efuse_generator/kaios_build_efuse.sh $CERT1_PATH/root_prvk.pem $OUTPUT_IMG_PATH
   
   if [ $? != 0 ];then
   echo "error !! preloader sign error "
   exit 129
   fi
   echo "success !! efuse image generator \n"
else
   echo "!!!! efuse not generator"
fi

