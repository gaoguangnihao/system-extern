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
	    echo "1 $1 is project name"
	    echo "Try ./generator_dm_keys.sh mt6731_jpv_jio"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 1 ];then
	echo "############WORNG PARG ###########"
	usage
	exit
else
        echo "Begin to generator sign"
fi

# Test if tmp/ exists already and delete it if yes.
if [ -d "$1" ] ; then
  echo "folder exists. key already created"
  exit
fi

mkdir $PRJ_DIR

echo "generator RSA key pair"
openssl genrsa -out $CURDIR/$PRJ_DIR/dm_prvk.pem 2048

echo "generator verity.pk8"

openssl pkcs8 -topk8 -inform PEM -outform DER -in $CURDIR/$PRJ_DIR/dm_prvk.pem -out $CURDIR/$PRJ_DIR/verity.pk8 -nocrypt

echo "generator verity.x509.pem"
openssl req -new -x509 -key $CURDIR/$PRJ_DIR/prvk.pem -out $CURDIR/$PRJ_DIR/verity.x509.pem -sha256 -subj '/C=US/ST=ShangHai/L=Mountain View/O=KAIOS/OU=KAIOS/CN=KAIOS/emailAddress=kaios@kaiostech.com'


echo "generator verity_key"
LD_LIBRARY_PATH=$CURDIR/lib $CURDIR/bin/generate_verity_key -convert $CURDIR/$PRJ_DIR/verity.x509.pem $CURDIR/$PRJ_DIR/verity_key

echo "rename verity_key"

mv $CURDIR/$PRJ_DIR/verity_key.pub $CURDIR/$PRJ_DIR/verity_key






