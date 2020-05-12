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
	    echo "1 $1 is keys path"
	    echo "2 $2 is pre imgae path"
	    echo "3 $3 is sprd tools path"
	    echo "4 $4 is product name"
	    echo "5 $5 build type user or userdebug"
	    echo "./kaios_key_sign_sprd.sh /home/dhcui/key_path /home/dhcui/test_sprd_pier2m/source /local/tools/system-faq/system-extern/sprd_sign$ sp9820e_2c10aov userdebug"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 5 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
fi

CERTS_PATH=$1
INPUT_IMG_PATH=$2
TOOLS_PATH=$3
PRODUCT_NAME=$4
VARIANT=$5

if [ $PRODUCT_NAME != "sp9820e_2c10aov" ];then
echo 
echo 
echo "!!! error !!!" $PRODUCT_NAME "!!! NOT SUPPORT !!!"
exit 128
fi

#check pac files exist or not 
if [ -f $INPUT_IMG_PATH/$PRODUCT_NAME*.pac ];then
echo "clean pac files"
rm -f  $INPUT_IMG_PATH/$PRODUCT_NAME*.pac
fi

#check if sec boot enable 
if [ -f $INPUT_IMG_PATH/PRODUCT_SECURE_BOOT_SPRD ];then
echo "secure boot production"
else
echo "!!! this not secure boot production version"
exit 129
fi

CURDIR="`dirname $0`"

#cd $CURDIR

#prepare boot and system image with new dm key
#Note boot_system/mt6731_jpv_jio/ should be re-define FIXED-ME
#bash boot_system/boot_dm.sh $INPUT_IMG_PATH $CERTS_PATH

#if [ $? != 0 ];then
#   echo "error !! about DM sign boot and system images"
#   exit 129
#fi
#sleep 3
#echo "......"
#echo "......"
#echo "success !!! DM sign "

#sign package image files
bash $CURDIR/packimage_scripts/kaios_sprd_packimg_sign.sh $CERTS_PATH $INPUT_IMG_PATH

if [ $? != 0 ];then
   echo "error !! sign package image files"
   exit 129
fi

#sign modem image and make package

bash $CURDIR/modem_script/kaios_sprd_modem_sign.sh $CERTS_PATH $INPUT_IMG_PATH $TOOLS_PATH $VARIANT

if [ $? != 0 ];then
   echo "error !! sign modem image"
   exit 129
fi
