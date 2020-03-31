#!/bin/bash

# generator prvk keys use openssl

PRJ_DIR=$1
#CURDIR="`pwd`"/"`dirname $0`"
CURDIR="`pwd`"
echo $CURDIR

function usage() {

	#######################################
	# Dump usage howto
	#######################################

	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
	    echo "1 $1 is no signed system path "
	    echo "Try ./system_dm.sh /home/dhcui/mtk_m_jpv"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 1 ];then
	echo "############WORNG PARG ###########"
	usage
	exit
else
        echo "Begin to generator system dm files"
fi

if [ -f $1/system-org.img ];then 

   cp $1/system-org.img $CURDIR/in/system-org.img
   
else

   echo "no system imgae exist"
   exit
fi

# Test if out/ exists already and delete it if yes.
if [ -d "$CURDIR/out" ] ; then
  echo "out folder exists. So remove it."
  rm -rf $CURDIR/out
fi
mkdir $CURDIR/out


LD_LIBRARY_PATH=$CURDIR/lib $CURDIR/bin/boot_signer /boot $CURDIR/in/boot-verified.img $CURDIR/mt6731_jpv_jio/verity.pk8  $CURDIR/mt6731_jpv_jio/verity.x509.pem $CURDIR/out/boot-dm.img
