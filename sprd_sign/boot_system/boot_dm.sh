#!/bin/bash

# generator prvk keys use openssl
# return value 127 means that files not exist
# return value 128 means that parm NO. wrong
# return value 129 means that exec prom wrong

PRJ_DIR=$1
KEY_PATH=$2
#CURDIR="`pwd`"/"`dirname $0`"
CURDIR="`dirname $0`"
KEY_SUFF="/verity"
KEY_TOOLS="./bin/verity_signer"
#CURDIR="`pwd`"

function usage() {

	#######################################
	# Dump usage howto
	#######################################

	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
	    echo "1 $1 is boot and system image path "
	    echo "2 DM key path"
	    echo "./boot_dm.sh /home/dhcui/image_path /home/dhcui/dmkey_path"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 2 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
else
   echo "******************************************"
   echo "******Begin to generator boot dm files******"
   echo "******************************************"
fi

# Test if out/ exists already and delete it if yes.
if [ -d "$CURDIR/out" ] ; then
  echo "boot_system out folder exists. So remove it."
  rm -rf $CURDIR/out
fi
mkdir $CURDIR/out

# Test if out/ exists already and delete it if yes.
if [ -d "$CURDIR/in" ] ; then
  echo "boot_system in folder exists. So remove it."
  rm -rf $CURDIR/in
fi
mkdir $CURDIR/in

if [ -d "$CURDIR/system" ] ; then
  echo "boot_system system folder exists. So remove it."
  rm -rf $CURDIR/system
fi
mkdir $CURDIR/system

if [ -f $PRJ_DIR/boot.img ];then
   cp $PRJ_DIR/boot.img $CURDIR/in/boot.img
else
   echo "error!! No boot.img exist"
   exit 127
fi

#we need sign recovery image with dm key also
if [ -f $PRJ_DIR/recovery.img ];then
   cp $PRJ_DIR/recovery.img $CURDIR/in/recovery.img
else
   echo "error!! No recovery.img exist"
   exit 127
fi

#Note system-kaios.img is defined by KAI FIXED-ME
if [ -f $PRJ_DIR/system-kaios.img ];then 
   cp $PRJ_DIR/system-kaios.img $CURDIR/in/system.img 
else
   echo "error!! No system-kaios.img exist"
   exit 127
fi

#Note system_image_info.txt is defined by MTK FIXED-ME
if [ -f $CURDIR/system_image_info.txt ];then
   rm $CURDIR/system_image_info.txt
   cp $PRJ_DIR/system_image_info.txt $CURDIR/system_image_info.txt
else 
   echo "error!! No boot_system system_image_info.txt config files"
   exit 127
fi

#we need modify config files for special system
#p1 file
#p2 the key path with suffix verity $KEY_PATH$KEY_SUFF
#p3 sign tools path

PATH_KEY=$KEY_PATH$KEY_SUFF

if [ -d $KEY_PATH ];then
   echo "keys path is" $PATH_KEY
else 
   echo "error!! NO DM KEY exit"
   exit 127
fi


python $CURDIR/reconfig_config_ini.py $CURDIR/system_image_info.txt $PATH_KEY $KEY_TOOLS

if [ $? != 0 ];then
   echo "error!! parse system config file reconfig_config_ini"
   exit 129
fi

echo "success !!! parse system config file"

LD_LIBRARY_PATH=$CURDIR/../lib $CURDIR/../bin/boot_signer /boot $CURDIR/in/boot.img $KEY_PATH/verity.pk8  $KEY_PATH/verity.x509.pem $CURDIR/out/boot-dm.img
if [ $? != 0 ];then
   echo "error!! sign dm boot image"
   exit 129
fi
echo "success !!! boot_signer dm boot.img"

#we need sign recovery image with dm key also
LD_LIBRARY_PATH=$CURDIR/../lib $CURDIR/../bin/boot_signer /recovery $CURDIR/in/recovery.img $KEY_PATH/verity.pk8  $KEY_PATH/verity.x509.pem $CURDIR/out/recovery-dm.img
if [ $? != 0 ];then
   echo "error!! sign dm recovery image"
   exit 129
fi
echo "success !!! boot_signer dm recovery.img"

python $CURDIR/sign_system.py $CURDIR/in/system.img $CURDIR/system_image_info.txt $CURDIR/out/system-dm.img
if [ $? != 0 ];then
   echo "error!! sign dm system image"
   exit 129
fi
echo "success !!! sign dm system image"

#after generator success need copy to PRJ_DIR files
cp $CURDIR/out/boot-dm.img $PRJ_DIR/boot.img
if [ $? != 0 ];then
   echo "error!! copy boot dm image"
   exit 129
fi
#we need sign recovery image with dm key also
cp $CURDIR/out/recovery-dm.img $PRJ_DIR/recovery.img
if [ $? != 0 ];then
   echo "error!! copy recovery dm image"
   exit 129
fi

#before copy to project folder we need check sparse or not 
INSTALLED_SYSTEMIMAGE=$CURDIR/out/system-dm.img
PRODUCT_OUT=$CURDIR/out
SIMG2IMG="/../bin/simg2img"

echo INSTALLED_SYSTEMIMAGE=${INSTALLED_SYSTEMIMAGE}
echo PRODUCT_OUT=${PRODUCT_OUT}
echo SIMG2IMG=${SIMG2IMG}

dd if=${INSTALLED_SYSTEMIMAGE} of=${PRODUCT_OUT}/system_header.img bs=1 skip=0 count=4
echo -e -n "\x3a\xff\x26\xed" > ${PRODUCT_OUT}/sparse_magic.img
cmp -s ${PRODUCT_OUT}/system_header.img ${PRODUCT_OUT}/sparse_magic.img
if [ $? -eq 0 ] ; then
   echo "transfer sparse system img to unsparse img"
   LD_LIBRARY_PATH=$CURDIR/../lib $CURDIR${SIMG2IMG} ${INSTALLED_SYSTEMIMAGE} ${PRODUCT_OUT}/system_raw.img
#   ${SIMG2IMG} ${INSTALLED_SYSTEMIMAGE} ${PRODUCT_OUT}/unsparse_system.img
#   rm ${INSTALLED_SYSTEMIMAGE}
#   mv ${PRODUCT_OUT}/unsparse_system.img ${INSTALLED_SYSTEMIMAGE}
fi

rm ${PRODUCT_OUT}/sparse_magic.img
rm ${PRODUCT_OUT}/system_header.img
#end transfer

cp $CURDIR/out/system_raw.img $PRJ_DIR/system_raw.img
if [ $? != 0 ];then
   echo "error!! copy system dm image"
   exit 129
fi

#clean temp folder after done 
# Test if out/ exists already and delete it if yes.
if [ -d "$CURDIR/out" ] ; then
  echo "boot_system out  So remove it."
  rm -rf $CURDIR/out
fi

# Test if out/ exists already and delete it if yes.
if [ -d "$CURDIR/in" ] ; then
  echo "boot_system in . So remove it."
  rm -rf $CURDIR/in
fi

echo "******************************************"
echo "******end to generator boot dm files******"
echo "******************************************"
