##########init valiable ###################
#-e 判断$a是否存在
#-d 判断$a是否存在，并且为目录
#-f 判断$a是否存在，并且为常规文件
#-L 判断$a是否存在，并且为符号链接
#-h 判断$a是否存在，并且为软链接
#-s 判断$a是否存在，并且长度不为0
#-r 判断$a是否存在，并且可读
#-w 判断$a是否存在，并且可写
#-x 判断$a是否存在，并且可执行
#-O 判断$a是否存在，并且属于当前用户
#-G 判断$a是否存在，并且属于当前用户组
#-nt 判断file1是否比file2新  [ "/usr/local/src/file1" -nt "/usr/local/src/file2" ]
#-ot 判断file1是否比file2旧  [ "/usr/local/src/file1" -ot "/usr/local/src/file2" ]
#########################################

pd_Tools="../der_extractor/pem_to_der.py"
de_Tools="../der_extractor/der_extractor"
D_CURR="pwd"

if [ ! -n "$1" ] ;then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "You have not input PRODUCT_NAME!"
    echo "Try ./kaios_key_generator.sh Kaios31_jpv"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit
else
    echo "the args you input is $1"

fi


PRODUCT_NAME=$1

if [ ! -d "$PRODUCT_NAME" ];then
       mkdir $PRODUCT_NAME
       echo "$PRODUCT_NAME Creat done"
else 
   
  	echo $PRODUCT_NAME
	exit
fi

# generator root key 
echo '******generator keys and der begin******'

cd $PRODUCT_NAME

openssl genrsa -out root_prvk.pem 2048
#
python $pd_Tools root_prvk.pem root_prvk.der

#
openssl rsa -in root_prvk.pem -pubout >root_pubk.pem

#
python $pd_Tools root_pubk.pem root_pubk.der

##genator imgkey 

openssl genrsa -out img_prvk.pem 2048
#
python $pd_Tools img_prvk.pem img_prvk.der

#
openssl rsa -in img_prvk.pem -pubout >img_pubk.pem

#
python $pd_Tools img_pubk.pem img_pubk.der

#exit

echo '******generator keys and der done******'


echo 'use root_pubk.der generator oemkey.h and copy to matched folder (need release to odm)'

$de_Tools  root_pubk.der oemkey.h ANDROID_SBC

#copy oemkey.h to [DA] $DA_Kit/Raphael-da/custom/$PLATFORM/oemkey.h
#copy oemkey.h to [PL] $PL/custom/$PORJECT/inc/oemkey.h
#/local/code/mtk-m/KaiOS/vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/kaios31_jpv/inc
#copy oemkey.h to [LK] $LK/target/$PROJECT/inc/oemkey.h
#/local/code/mtk-m/KaiOS/vendor/mediatek/proprietary/bootable/bootloader/lk/target/kaios31_jpv/inc

echo 'use root_pubk.der generator dakey.h this include DA_PL public key to verify preloader DA_PL.bin'
#when sign DA_PL.bin use matched prvk.pem to sign

$de_Tools root_pubk.der dakey.h ANDROID_SBC

#copy dakey.h to [PL]$PL/custom/$PROJECT/inc/dakey.h
#generator by /local/tools/system-faq/system-extern/secure_chip_tools/keys/pbp/root_prvk.pem 

#NOTE they are same not to root_prvk.pem about the really root 
#/local/code/mtk-m/KaiOS/vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/kaios31_jpv/inc
echo 'please note we need modify the dakey.h and replace keyword 'OEM' to 'DA' '

echo "generator sign key for bootloader when bulid"

#CHIP_TEST_KEY.ini need copy to vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/kaios31_jpv/security/chip_config/s/key
<<<<<<< HEAD
#Note PBP_PY_SUPPORT will be affect the sign process if not exist 

#$de_Tools root_prvk.der CHIP_TEST_KEY.ini SV5_SIGN


echo "generator sign key for DA_PL signing"

#VERIFIED_BOOT_IMG_AUTH_KEY.ini need copy to $DA_Kit/Raphael-da/custom/security_export/usbdl4enduser_dummy/VERIFIED_BOOT_IMG_AUTH_KEY.ini

=======

#$de_Tools root_prvk.der CHIP_TEST_KEY.ini SV5_SIGN

echo "generator sign key for DA_PL signing"

#VERIFIED_BOOT_IMG_AUTH_KEY.ini need copy to $DA_Kit/Raphael-da/custom/security_export/usbdl4enduser_dummy/VERIFIED_BOOT_IMG_AUTH_KEY.ini
>>>>>>> 8567c1ab873cf83a932d1e280e84a93d91a90ab8
#$de_Tools root_prvk.der VERIFIED_BOOT_IMG_AUTH_KEY.ini ANDROID_SIGN

cd ..

#lock or unlock 
#/vendor/mediatek/proprietary/custom/common/secro/SECRO_GMP.ini
#https://online.mediatek.com/FAQ#/SW/FAQ17984

#DM-Verity
#https://online.mediatek.com/FAQ#/SW/FAQ20647
## should be backup to server for 
## contenct to server and copy to special folder temp to /local/keys-mtk

DEST_FOLDER=/local/keys-mtk/

cp -Rvdp $PRODUCT_NAME $DEST_FOLDER


<<<<<<< HEAD
### generator cert1 and cert2 keys 


=======
>>>>>>> 8567c1ab873cf83a932d1e280e84a93d91a90ab8

### replace to pl/lk/da

echo 'will be replace pl/lk/da'

### secure boot enable 

echo 'secure boot enable'

###config lk 

echo 'config lk'

### config kernel 

echo 'config kernel'


### preloader sign

echo 'sign preloader'
#need copy root_prvk.pem and img_prvk.pem to preloader key path 
echo '/local/code/mtk-m/KaiOS/vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/kaios31_jpv/security/chip_config/s/key'

echo 'config pl_key.ini /plcontent.ini /pl_gfh_config_cert_chain.ini'

###

### epp_prvk.pem == > img_prvk.pem
### da_prvk.pem ==>   new one  ? why maybe wrong 
### but dakey.h use   secure_chip_tools/keys/pbp/root_prvk.pem ,why not security/chip_config/s/key?
### oemkey.h ===>     img_pubk.der
### da sign 

echo 'config da_prvk.pem and epp_prvk.pem'

###
#



