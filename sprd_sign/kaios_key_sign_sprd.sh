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
	    echo "3 $3 is signed imgae path"
	    echo "4 $4 is sprd tools path"
	    echo "5 $5 is product name"
	    echo "6 $6 build type user or userdebug"
	    echo "./kaios_key_sign_sprd.sh /home/dhcui/key_path /home/dhcui/test_sprd_pier2m/source /home/dhcui/test_sprd_pier2m/dest /local/tools/system-faq/system-extern/sprd_sign$ sp9820e_2c10aov userdebug"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 6 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
fi

CERTS_PATH=$1
INPUT_IMG_PATH=$2
SIGNED_IMG_PATH=$3
TOOLS_PATH=$4
PRODUCT_NAME=$5
VARIANT=$6
TARGET_NAME="sp9820e"

#FIXED-ME if match the "sp9820e" project
if [[ $PRODUCT_NAME == $TARGET_NAME ]];then
echo 
echo 
echo "!!! error !!!" $PRODUCT_NAME "!!! NOT SUPPORT !!!"
echo "only support 9820e production"
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

if [ -d $SIGNED_IMG_PATH ];then
echo "!!! will be clean signed folder !!!"
rm -fr $SIGNED_IMG_PATH ||{ echo "can not delete dst floder"; exit 127;}
mkdir -p $SIGNED_IMG_PATH ||{ echo "can not creat floder"; exit 127;}
else
echo "!!! will be creat signed folder !!!"
mkdir -p $SIGNED_IMG_PATH ||{ echo "can not creat floder"; exit 127;}
fi

CURDIR="`dirname $0`"

## FIXED-ME should be get the right dir
cd $CURDIR
#prepare boot and system image with new dm key
#Note boot_system/mt6731_jpv_jio/ should be re-define FIXED-ME
bash $CURDIR/boot_system/boot_dm.sh $INPUT_IMG_PATH $CERTS_PATH

if [ $? != 0 ];then
   echo "error !! about DM sign boot and system images"
   exit 129
fi
sleep 3

#echo "......"
#echo "......"
#echo "success !!! DM sign "

#copy the imgs to signed folder prepare sign process 

cp $INPUT_IMG_PATH/* $SIGNED_IMG_PATH ||{ echo "can not copy floder"; exit 127;}
echo "scuccess copy file list to dest folder"
#sign package image files
bash $CURDIR/packimage_scripts/kaios_sprd_packimg_sign.sh $CERTS_PATH $SIGNED_IMG_PATH $PRODUCT_NAME

if [ $? != 0 ];then
   echo "error !! sign package image files"
   exit 129
fi

#sign modem image and make package

bash $CURDIR/modem_script/kaios_sprd_modem_sign.sh $CERTS_PATH $SIGNED_IMG_PATH $TOOLS_PATH $VARIANT $PRODUCT_NAME $TARGET_NAME

if [ $? != 0 ];then
   echo "error !! sign modem image"
   exit 129
fi
