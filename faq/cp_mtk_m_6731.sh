#used to cp img to release folder
#mtk base use flashtool to download

#!/bin/bash


img_dir=/local/code/mtk-m/KaiOS/out/target/product/kaios31_emmc_jio
dst_dir=/home/dhcui/dahui-share/mtk6731-m

  img_files=(
   $img_dir/system*.img
   $img_dir/boot.img
   $img_dir/cache*img
   $img_dir/userdata*img
   $img_dir/system/*u*.*
   $img_dir/MT673*_Android_scatter.txt
   $img_dir/preloader_kaios31*.bin
   $img_dir/lk-verified.bin
   $img_dir/loader_ext-verified.img
   $img_dir/loader_ext.img
   $img_dir/boot-verified.img
   $img_dir/recovery*.img
   $img_dir/secro.img
   $img_dir/spmfw*.bin
   $img_dir/mcupmfw-verified.img
   $img_dir/trustzone*.bin
   $img_dir/logo-verified.bin
   $img_dir/lk.bin
   $img_dir/logo.bin
   $img_dir/recovery.img
   $img_dir/*fota_meta.zip
   $img_dir/preloader_kaios*.bin
   $img_dir/md1rom*.img
   $img_dir/md1dsp*.img
   $img_dir/mcupmfw*.img
   $img_dir/md1arm7*.img
   $img_dir/md3rom*.img
   $img_dir/ramdisk*.img
 )


COPY_IMG_ERR=0

for img_file in ${img_files[@]};do
	
	cp -vf ${img_file}  ${dst_dir}/
	
	if [ "$?" != "0" ];then
	  echo 
		echo "**** copy fail: ${img_file} ****"
		echo 
		COPY_IMG_ERR=1
	fi
done

echo =====================================
if [ $COPY_IMG_ERR != 0 ];then
	echo "===========  copy error ============="
else
	echo "============= copy img files OK ==============="
fi
echo =====================================
echo  

echo 
