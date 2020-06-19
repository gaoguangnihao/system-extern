#!/bin/sh 

# generator prvk keys use openssl
# return value 127 means that files not exist
# return value 128 means that parm NO. wrong
# return value 129 means that exec prom wrong
PRJ_DIR="/local/code/mtk-m/KaiOS"
PATCH_PATH="/local/tools/system-faq/system-extern/porting_mtk_df_project"
CURDIR="`pwd`"/"`dirname $0`"

#CURDIR="`pwd`"

cd $PRJ_DIR
cp $PATCH_PATH/verity_key $PRJ_DIR/build/target/product/security/

cp $PATCH_PATH/mtk_porting_build.diff $PRJ_DIR/build

#KaiOS/build
#modified:   core/main.mk
#modified:   target/product/security/verity_key
#modified:   tools/releasetools/build_image.py

echo "KaiOS/build"

#device/mediatek/kaios31_jpv/full_kaios31_jpv.mk //nothing need to modify

echo "device/mediatek"


#kernel project kernel-4.4/  //add logs at kernel

echo "kernel-4.4/"

#system/core/ 
 
echo "system/core"

#vendor/mediatek/proprietary/bootable/bootloader/lk/

echo "lk public key"


#vendor/mediatek/proprietary/bootable/bootloader/preloader/
echo "preloader public key"

#at last please copy oem.da to windows build the DA file
echo " build da"
