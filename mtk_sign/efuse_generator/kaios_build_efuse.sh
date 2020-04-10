#!/bin/bash

KEY_FILE=$1
IMG_OUT=$2

#openssl rsa -pubin -in $keypath -text
#openssl rsa -RSAPublicKey_in -in $filename -pubout

#EFUSE_PY_DEF            = efuse_definition.xml
#EFUSE_INPUT_FILE        = input.xml

function usage() {
	#######################################
	# Dump usage howto
	#######################################
	echo "*************************************"
	echo "!!!!!!!!!!#1 is keys_path!!!!!!!!!!!"
	echo "try ./kaios_build_efuse.sh keys_path image_out"
	echo "*************************************"
}

if [ $# -lt 2 ];then
	usage
	exit 128
else
        echo "*************************************"
        echo "*****Begin to generator efuse.img****"
        echo "*************************************"
fi

MTK_PROJECT=kaios31_jpv
TARGET=kaios31_jpv
CURRDIR="`pwd`"/"`dirname $0`"
#CURRDIR=`pwd`
PRELOADER_OUT=$CURRDIR/out
PRELOADER_DIR=preloader
MTK_PLATFORM=MT6739

EFUSE_PY_FILE=$CURRDIR/$PRELOADER_DIR/tools/efuse/efuse_bingen_v2.py
PBP_TOOL=$CURRDIR/$PRELOADER_DIR/tools/pbp/pbp.py
BIN_TO_TXT_TOOL=$CURRDIR/$PRELOADER_DIR/tools/pbp/bin2txt.py

EFUSE_PY_DEF=$CURRDIR/efuse_definition.xml
EFUSE_INPUT_FILE=$CURRDIR/input.xml
EFUSE_IMAGE_NAME=efuse_$MTK_PROJECT.img
OUTPUT_DIR=$CURRDIR/out
CURRDATE="`date +%Y-%m-%d-%H:%M:%S`"

echo $OUTPUT_DIR
echo $EFUSE_IMAGE_NAME

#clean env of out folder
if [ -d $OUTPUT_DIR ];then
 rm -fr $OUTPUT_DIR
fi

mkdir $OUTPUT_DIR

python $PBP_TOOL -j $KEY_FILE -func keyhash_pss -o $OUTPUT_DIR/keyhash.bin

if [ $? != 0 ];then
   echo "error !! generator keyhash.bin"
   exit 129
fi
python $BIN_TO_TXT_TOOL $OUTPUT_DIR/keyhash.bin $OUTPUT_DIR/keyhash.txt

if [ $? != 0 ];then
   echo "error !! generator keyhash.txt "
   exit 129
fi
#$(PBP_TOOL) -func keyhash -i $(CHIP_KEY) -o $(OUTPUT_DIR)/keyhash.txt
python $EFUSE_PY_FILE -f $EFUSE_INPUT_FILE -d $EFUSE_PY_DEF -k $OUTPUT_DIR/keyhash.txt -o $OUTPUT_DIR/$EFUSE_IMAGE_NAME -l efuse_bingen_$CURRDATE.log

if [ $? != 0 ];then
   echo "error !! generator efuse.img"
   exit 129
fi

cp -v $OUTPUT_DIR/$EFUSE_IMAGE_NAME $IMG_OUT/efuse.img

if [ $? != 0 ];then
   echo "error !! copy efuse.img to" $IMG_OUT
   exit 129
fi

echo "*************************************"
echo "*****End to generator efuse.img****"
echo "*************************************"
