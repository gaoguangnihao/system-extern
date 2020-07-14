#used to cp img to release folder
#mtk base use flashtool to download

#!/bin/bash

# $1 is a absolte path  /local/code/quoin-master/KaiOS
# $2 is a dest path of save symbols 

#/local/code/quoin-master/KaiOS/out/target/product/msm8909_512/symbols replace 
#/local/code/quoin-master/KaiOS/objdir-gecko/toolkit/library/libxul.so
#0xb0cb1210  0xb0cc20e4  Yes         /local/code/quoin-master/KaiOS/objdir-gecko/mozglue/build/libmozglue.so
#0xae9b9ba0  0xb02c9698  Yes         /local/code/quoin-master/KaiOS/objdir-gecko/toolkit/library/libxul.so
#0xae15fcd8  0xae16e998  Yes         /local/code/quoin-master/KaiOS/objdir-gecko/security/sandbox/linux/libmozsandbox.so
#0xae031268  0xae1170bc  Yes         /local/code/quoin-master/KaiOS/objdir-gecko/config/external/nss/libnss3.so
#0xae012010  0xae013a74  Yes         /local/code/quoin-master/KaiOS/objdir-gecko/config/external/lgpllibs/liblgpllibs.so
#/system/b2g/distribution/bundles/libframework/libframework.so
#/system/b2g/distribution/bundles/location/location.so
#/system/b2g/distribution/bundles/settings/settings.so
#/system/b2g/distribution/bundles/telephony/telephony.so
#libmemalloc.so
#libqdMetaData.so
#libqdutils.so
#libGLESv1_CM.so
#libqservice.so



CODE_PATH=$1
OBJGECKO_B2G_DIR="$1/objdir-gecko/dist/bin/"
OBJGECKO_SYMBOL_DIR="$1/objdir-gecko/dist/crashreporter-symbols/"
DST_DIR=$2

B2G_COPY_PATH="$2/objdir-gecko/dist/bin/"
CRASH_SYMBOLS_PATH="$2/objdir-gecko/dist/crashreporter-symbols"

if [ -d $DST_DIR ]; then
   echo "begin to copy"
else
   echo "creat floder about dst"
   mkdir -p $DST_DIR
fi

mkdir -p $B2G_COPY_PATH
mkdir -p $CRASH_SYMBOLS_PATH

# define image and file list to copy 

  img_files=(
   $OBJGECKO_B2G_DIR/b2g
 )

cp $OBJGECKO_B2G_DIR/b2g $B2G_COPY_PATH

echo "copy b2g binary done"
cp -Rvdp $OBJGECKO_SYMBOL_DIR/* $CRASH_SYMBOLS_PATH


#cp -rvdp $OBJGECKO_SYMBOL_DIR ${DST_DIR}

#for img_file in ${img_files[@]};do
	
#	cp -vf ${img_file}  ${DST_DIR}/
	
#	if [ "$?" != "0" ];then
#	  echo 
#		echo "**** copy fail: ${img_file} ****"
#		echo 
#		COPY_IMG_ERR=1
#	fi
#done


#tar -zcvf $DST_DIR.tar.gz $DST_DIR/

echo 
