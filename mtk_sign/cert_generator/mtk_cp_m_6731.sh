#used to cp img to release folder
#mtk base use flashtool to download

#!/bin/bash


IMG_DIR=$1
DST_DIR=$2

if [ -d $DST_DIR ]; then
   echo "begin to copy"
else
   echo "creat floder about dst"
   mkdir -p $DST_DIR
fi

# define image and file list to copy 

  img_files=(
   $IMG_DIR/boot.img
   $IMG_DIR/cache.img
   $IMG_DIR/userdata.img
   $IMG_DIR/MT673*_Android_scatter.txt
   $IMG_DIR/preloader.bin
   $IMG_DIR/lk.bin
   $IMG_DIR/loader_ext.img
   $IMG_DIR/recovery.img
   $IMG_DIR/secro.img
   $IMG_DIR/spmfw.bin
   $IMG_DIR/mcupmfw.img
   $IMG_DIR/trustzone.bin
   $IMG_DIR/logo.bin
   $IMG_DIR/md1rom.img
   $IMG_DIR/md1dsp.img
   $IMG_DIR/mcupmfw.img
   $IMG_DIR/md1arm7.img
   $IMG_DIR/md3rom.img
   $IMG_DIR/ramdisk.img
   $IMG_DIR/system-kaios.img
   $IMG_DIR/system.img
   $IMG_DIR/system_image_info.txt
 )

if [ -f $IMG_DIR/*fota_meta.zip ];then
    cp -vf $IMG_DIR/*fota_meta.zip  $DST_DIR/
fi

COPY_IMG_ERR=0

for img_file in ${img_files[@]};do
	
	cp -vf ${img_file}  ${DST_DIR}/
	
	if [ "$?" != "0" ];then
	  echo 
		echo "**** copy fail: ${img_file} ****"
		echo 
		COPY_IMG_ERR=1
	fi
done

echo "====================================="
if [ $COPY_IMG_ERR != 0 ];then
	echo "===========  copy error ============="
  exit 128
else
	echo "======== copy img files OK =========="
fi
echo "====================================="
echo


#tar -zcvf $DST_DIR.tar.gz $DST_DIR/

echo 
