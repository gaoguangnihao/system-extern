#!/bin/bash

# generator prvk keys use openssl
# return value 127 means that files not exist
# return value 128 means that parm NO. wrong
# return value 129 means that exec prom wrong

PRJ_DIR=$1
KEY_PATH=$2
CURDIR="`pwd`"/"`dirname $0`"
KEY_SUFF="/verity"
KEY_TOOLS="boot_system/bin/verity_signer"
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

LD_LIBRARY_PATH=$CURDIR/lib $CURDIR/bin/boot_signer /boot $CURDIR/in/boot.img $KEY_PATH/verity.pk8  $KEY_PATH/verity.x509.pem $CURDIR/out/boot-dm.img
if [ $? != 0 ];then
   echo "error!! sign dm boot image"
   exit 129
fi
echo "success !!! boot_signer dm boot.img"
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
cp $CURDIR/out/system-dm.img $PRJ_DIR/system.img
if [ $? != 0 ];then
   echo "error!! copy system dm image"
   exit 129
fi
echo "******************************************"
echo "******end to generator boot dm files******"
echo "******************************************"
