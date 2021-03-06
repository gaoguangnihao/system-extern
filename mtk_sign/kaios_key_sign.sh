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
        echo "9 $9 is da name"
        echo "10 ${10}is version number for anti rollback"
	    echo "./kaios_key_sign.sh /home/kai-user/key_path /home/kai-user/key_path /home/kai-user/image_path /home/dhcui/image_out preloader signda /home/dhcui/da_path efuse daname version"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 10 ];then
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
DA_NAME=$9
SW_VER=${10}

CURDIR="`dirname $0`"

cd $CURDIR

#prepare boot and system image with new dm key
#Note boot_system/mt6731_jpv_jio/ should be re-define FIXED-ME
bash boot_system/boot_dm.sh $INPUT_IMG_PATH $CERT1_PATH

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
bash cert_generator/kaios_deploy_sign.sh $CERT1_PATH $CERT2_KEY_PATH $INPUT_IMG_PATH $OUTPUT_IMG_PATH $SW_VER
if [ $? != 0 ];then
   echo "error !! deploy sign certs and sign the image "
   exit 129
fi

echo "success !! kaios_deploy_sign"
sleep 3

##should be clean the signed temp files for customer
echo
echo
echo "******************************************"
echo "******Begin to clean temp signed files******"
echo "******************************************"
rm -f $OUTPUT_IMG_PATH/system-kaios.img
echo "clean system image"
rm -fr $OUTPUT_IMG_PATH/resign
echo "clean resign folder"
rm -fr $OUTPUT_IMG_PATH/sig
echo "clean sig folder"
echo "******************************************"
echo "******End to clean temp signed files******"
echo "******************************************"
echo
echo
##sign common image done!!!
sleep 3
##beging to sign NO-GFH preloader image
if [[ $PRELOADER = "preloader" ]]; then
   bash secure_chip_tools/kaios_sign_preloader.sh $OUTPUT_IMG_PATH $CERT1_PATH $SW_VER
   if [ $? != 0 ];then
   echo "error !! preloader sign error "
   exit 129
   fi
else
   echo "!!!!! preloader not signed"
fi

echo "success !! preloader sign \n"
sleep 3

## clean out folder orign image

  img_files=(
   $OUTPUT_IMG_PATH/boot.img
   $OUTPUT_IMG_PATH/lk.bin
   $OUTPUT_IMG_PATH/preloader.bin
   $OUTPUT_IMG_PATH/loader_ext.img
   $OUTPUT_IMG_PATH/spmfw.bin
   $OUTPUT_IMG_PATH/mcupmfw.img
   $OUTPUT_IMG_PATH/trustzone.bin
   $OUTPUT_IMG_PATH/logo.bin
   $OUTPUT_IMG_PATH/md1rom.img
   $OUTPUT_IMG_PATH/md1dsp.img
   $OUTPUT_IMG_PATH/md1arm7.img
   $OUTPUT_IMG_PATH/md3rom.img
   $OUTPUT_IMG_PATH/mcupmfw.img
   $OUTPUT_IMG_PATH/ramdisk.img
   $OUTPUT_IMG_PATH/recovery.img
   $OUTPUT_IMG_PATH/secro.img
 )
for img_file in ${img_files[@]};do

	rm -vf ${img_file}

	if [ "$?" != "0" ];then
	  echo
		echo "**** clean fail: ${img_file} ****"
		echo
	exit 129
	fi
done

if [[ $SIGN_DA = "signda" ]]; then
   bash secure_chip_tools/kaios_sign_da.sh $DA_BIN_PATH $CERT1_PATH $DA_NAME $OUTPUT_IMG_PATH

   if [ $? != 0 ];then
   echo "error!! preloader sign error "
   exit 129
   fi
   echo "success !! signda "
   sleep 3
##we really to generator auth_sv5 files like da just need check tools 
## DAA/SLA/ROOT/IMG keys

   bash secure_chip_tools/kaios_generator_auth_file.sh $DA_BIN_PATH $CERT1_PATH $DA_NAME
   if [ $? != 0 ];then
     echo "error !! auth_sv5 files"
     exit 129
   fi
   echo "success !! auth_sv5 generator "
   sleep 3

   bash secure_chip_tools/kaios_generator_scert_file.sh $DA_BIN_PATH $CERT1_PATH $DA_NAME
   if [ $? != 0 ];then
   echo "error !! scert_file"
   exit 129
   fi
   echo "success !! scert_file generator "
   sleep 3
##we will be generator scert file also
else
    echo "!!!! da-br.da-pl not signed"
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

