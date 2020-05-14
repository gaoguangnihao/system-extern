##########init valiable ###################
# return value 127 means that files not exist
# return value 128 means that parm NO. wrong
# return value 129 means that exec prom wrong

#########################################

CURDIR="`dirname $0`"
INPUT_IMG_PATH="/home/dhcui/test_sprd_pier2m/20200513"
CERTS_PATH="/local/keys-mtk/kaios_jpv"
#cd $CURDIR

#prepare boot and system image with new dm key
#Note boot_system/mt6731_jpv_jio/ should be re-define FIXED-ME
bash $CURDIR/boot_system/boot_dm.sh $INPUT_IMG_PATH $CERTS_PATH

exit
#if [ $? != 0 ];then
#   echo "error !! about DM sign boot and system images"
#   exit 129
#fi
#sleep 3
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
