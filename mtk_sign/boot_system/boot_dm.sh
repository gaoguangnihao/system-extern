#!/bin/bash

# generator prvk keys use openssl

PRJ_DIR=$1
CURDIR="`pwd`"/"`dirname $0`"
#CURDIR="`pwd`"
echo $CURDIR

function usage() {

	#######################################
	# Dump usage howto
	#######################################

	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
	    echo "1 $1 is boot path "
	    echo "Try ./boot_dm.sh /home/dhcui/mtk_m_jpv"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 1 ];then
	echo "############WORNG PARG ###########"
	usage
	exit
else
        echo "Begin to generator boot dm files"
fi
echo "BEGIN GENERATOR BOOT AND SYSTEM DM CERT"

# Test if out/ exists already and delete it if yes.
if [ -d "$CURDIR/out" ] ; then
  echo "out folder exists. So remove it."
  rm -rf $CURDIR/out
fi
mkdir $CURDIR/out

if [ -d "$CURDIR/system" ] ; then
  echo "system folder exists. So remove it."
  rm -rf $CURDIR/system
fi
mkdir $CURDIR/system

if [ -f $PRJ_DIR/boot.img ];then

   cp $PRJ_DIR/boot.img $CURDIR/in/boot.img
  
else

   echo "no boot imgae exist"
   exit
fi

if [ -f $PRJ_DIR/system-kaios.img ];then 

   cp $PRJ_DIR/system-kaios.img $CURDIR/system/system.img
   
else

   echo "no system imgae exist"
   exit
fi

if [ -f $CURDIR/system_image_info.txt ];then
   rm $CURDIR/system_image_info.txt
   cp $PRJ_DIR/system_image_info.txt $CURDIR/system_image_info.txt
else 
   echo "no right config files"
   exit
fi



LD_LIBRARY_PATH=$CURDIR/lib $CURDIR/bin/boot_signer /boot $CURDIR/in/boot.img $CURDIR/mt6731_jpv_jio/verity.pk8  $CURDIR/mt6731_jpv_jio/verity.x509.pem $CURDIR/out/boot-dm.img

python $CURDIR/sign_system.py $CURDIR/system/system.img $CURDIR/system_image_info.txt $CURDIR/out/system-dm.img


#after generator success need replace to PRJ_DIR files

cp $CURDIR/out/boot-dm.img $PRJ_DIR/boot.img
cp $CURDIR/out/system-dm.img $PRJ_DIR/system.img

echo "DONE GENERATOR BOOT AND SYSTEM DM CERT"
