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

echo '============================================='
echo '=========generator DFP keys by KAIOS========='
echo '============================================='
echo 

#CURDIR="`pwd`"/"`dirname $0`"
TOOLSDIR="`dirname $0`"
echo "The tools path is "$TOOLSDIR

pd_Tools="/der_extractor/pem_to_der.py"
de_Tools="/der_extractor/der_extractor"

if [ ! -n "$1" ] ;then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "You have not input PRODUCT_NAME!"
    echo "Try ./kaios_key_generator.sh Kaios31_jpv path_of_save"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 127
else
    echo "The first args you input is $1"

fi

if [ $# -lt 2 ];then
	echo "############WORNG PARG ###########"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "You have not input PRODUCT_NAME!"
	echo "try ./kaios_key_generator.sh Kaios31_jpv path_of_save"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
	exit 127
fi
#DEST_FOLDER=/local/keys-mtk/ should be dynamic
PRODUCT_NAME=/tmp/$1
DEST_FOLDER=$2

clean()
{
       echo "!!!!clean begin!!!!"
       echo $PRODUCT_NAME
       rm -fr $PRODUCT_NAME
       echo "!!!!clean end!!!!"
}

if [ ! -d "$PRODUCT_NAME" ];then
       mkdir $PRODUCT_NAME
       mkdir $PRODUCT_NAME/PUBLIC_KEYS
       echo "Should be creat $PRODUCT_NAME for keys generator"
else 
        echo "!!the project already exist!!"
  	echo $PRODUCT_NAME
	exit 128
fi

if [ ! -d $DEST_FOLDER ];then
  echo "!!!!!please creat path of save keys first!!!!"
  clean
  exit 129
fi

# generator root key 
echo '******generator keys and der begin******'

cd $PRODUCT_NAME

openssl genrsa -out root_prvk.pem 2048

if [ $? != 0 ];then
   echo "error !! generator root_prvk.pem"
   clean
   exit 129
fi
#
python $TOOLSDIR$pd_Tools root_prvk.pem root_prvk.der

if [ $? != 0 ];then
   echo "error !! generator root_prvk.der"
   clean
   exit 129
fi
#
openssl rsa -in root_prvk.pem -pubout >root_pubk.pem

if [ $? != 0 ];then
   echo "error !! generator root_pubk.pem"
   clean
   exit 129
fi
#
python $TOOLSDIR$pd_Tools root_pubk.pem root_pubk.der

if [ $? != 0 ];then
   echo "error !! generator root_pubk.der"
   clean
   exit 129
fi
##genator imgkey 

openssl genrsa -out img_prvk.pem 2048
#

if [ $? != 0 ];then
   echo "error !! generator img_prvk.pem"
   clean
   exit 129
fi

python $TOOLSDIR$pd_Tools img_prvk.pem img_prvk.der

if [ $? != 0 ];then
   echo "error !! generator img_prvk.der"
   clean
   exit 129
fi
#
openssl rsa -in img_prvk.pem -pubout >img_pubk.pem

if [ $? != 0 ];then
   echo "error !! generator img_pubk.pem"
   clean
   exit 129
fi
#
python $TOOLSDIR$pd_Tools img_pubk.pem img_pubk.der

if [ $? != 0 ];then
   echo "error !! generator img_pubk.der"
   clean
   exit 129
fi
#exit

echo '******generator keys and der done******'


echo 'use root_pubk.der generator oemkey.h and copy to matched folder (need release to odm)'

$TOOLSDIR$de_Tools  root_pubk.der oemkey.h ANDROID_SBC

if [ $? != 0 ];then
   echo "error !! generator oemkey.h"
   clean
   exit 129
fi

#copy oemkey.h to [DA] $DA_Kit/Raphael-da/custom/$PLATFORM/oemkey.h
#copy oemkey.h to [PL] $PL/custom/$PORJECT/inc/oemkey.h
#/local/code/mtk-m/KaiOS/vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/kaios31_jpv/inc
#copy oemkey.h to [LK] $LK/target/$PROJECT/inc/oemkey.h
#/local/code/mtk-m/KaiOS/vendor/mediatek/proprietary/bootable/bootloader/lk/target/kaios31_jpv/inc

echo 'use root_pubk.der generator dakey.h this include DA_PL public key to verify preloader DA_PL.bin'
#when sign DA_PL.bin use matched prvk.pem to sign

$TOOLSDIR$de_Tools root_pubk.der dakey.h ANDROID_SBC

if [ $? != 0 ];then
   echo "error !! generator dakey.h"
   clean
   exit 129
fi

#copy dakey.h to [PL]$PL/custom/$PROJECT/inc/dakey.h
#generator by /local/tools/system-faq/system-extern/secure_chip_tools/keys/pbp/root_prvk.pem 

#NOTE they are same not to root_prvk.pem about the really root 
#/local/code/mtk-m/KaiOS/vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/kaios31_jpv/inc
echo 'please note we need modify the dakey.h and replace keyword 'OEM' to 'DA' '

echo "generator sign key for bootloader when bulid"

#CHIP_TEST_KEY.ini need copy to vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/kaios31_jpv/security/chip_config/s/key
#Note PBP_PY_SUPPORT will be affect the sign process if not exist 

#$de_Tools root_prvk.der CHIP_TEST_KEY.ini SV5_SIGN


echo "generator sign key for DA_PL signing"

#VERIFIED_BOOT_IMG_AUTH_KEY.ini need copy to $DA_Kit/Raphael-da/custom/security_export/usbdl4enduser_dummy/VERIFIED_BOOT_IMG_AUTH_KEY.ini


#$de_Tools root_prvk.der CHIP_TEST_KEY.ini SV5_SIGN

echo "generator sign key for DA_PL signing"

#VERIFIED_BOOT_IMG_AUTH_KEY.ini need copy to $DA_Kit/Raphael-da/custom/security_export/usbdl4enduser_dummy/VERIFIED_BOOT_IMG_AUTH_KEY.ini
#$de_Tools root_prvk.der VERIFIED_BOOT_IMG_AUTH_KEY.ini ANDROID_SIGN

#beging to generator dm-key for system device verity

echo "generator RSA key pair"
openssl genrsa -out dm_prvk.pem 2048

if [ $? != 0 ];then
   echo "error !! generator dm_prvk.pem"
   clean
   exit 129
fi

echo "generator verity.pk8"

openssl pkcs8 -topk8 -inform PEM -outform DER -in dm_prvk.pem -out verity.pk8 -nocrypt

if [ $? != 0 ];then
   echo "error !! generator verity.pk8"
   clean
   exit 129
fi

echo "generator verity.x509.pem"
openssl req -new -x509 -key dm_prvk.pem -out verity.x509.pem -sha256 -subj '/C=US/ST=ShangHai/L=Mountain View/O=KAIOS/OU=KAIOS/CN=KAIOS/emailAddress=kaios@kaiostech.com'

if [ $? != 0 ];then
   echo "error !! generator verity.x509.pem"
   clean
   exit 129
fi

echo "generator verity_key"
LD_LIBRARY_PATH=$TOOLSDIR/lib $TOOLSDIR/bin/generate_verity_key -convert verity.x509.pem verity_key

if [ $? != 0 ];then
   echo "error !! generator verity_key"
   clean
   exit 129
fi

echo "rename verity_key"

mv verity_key.pub verity_key

#da_prvk use same root key 
cp root_prvk.pem da_prvk.pem
#epp_prvk use same img key
cp img_prvk.pem epp_prvk.pem

#use img prvk key about debug
#please note scert root key must same as preloader root prvk 
#now config preloader prvk root key same as root key
cp img_prvk.pem secondary_dbg_prvk.pem
cp img_prvk.pem primary_dbg_prvk.pem

#use new prvk key about SLA
openssl genrsa -out sla_prvk.pem 2048

#move public keys to PUBLIC_KEYS

#cp dakey.h $PRODUCT_NAME/PUBLIC_KEYS || echo "copy dakey error " && exit 127
#cp oemkey.h $PRODUCT_NAME/PUBLIC_KEYS || echo "copy oemkey error " && exit 127
#cp verity_key $PRODUCT_NAME/PUBLIC_KEYS || echo "copy verity_key error " && exit 127

cp dakey.h $PRODUCT_NAME/PUBLIC_KEYS||echo "copy dakey error"
cp oemkey.h $PRODUCT_NAME/PUBLIC_KEYS||echo "copy dakey error"
cp verity_key $PRODUCT_NAME/PUBLIC_KEYS||echo "copy dakey error"

cd ..

#lock or unlock 
#/vendor/mediatek/proprietary/custom/common/secro/SECRO_GMP.ini
#https://online.mediatek.com/FAQ#/SW/FAQ17984

#DM-Verity
#https://online.mediatek.com/FAQ#/SW/FAQ20647
## should be backup to server for 
## contenct to server and copy to special folder temp to /local/keys-mtk

#FIXED-ME
#DEST_FOLDER=/local/keys-mtk/
echo "copy key files to dest path"

if [ -d $DEST_FOLDER/$1 ];then
  echo "!!!! error for $1 already generator"
  clean
  exit 129
fi  

cp -Rvdp $PRODUCT_NAME $DEST_FOLDER

echo "clean tmp key files"
rm -fr $PRODUCT_NAME
### generator cert1 and cert2 keys 



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
###openssl rsa -in root_prvk.pem -text
echo 'config da_prvk.pem and epp_prvk.pem'
echo 
echo '============================================='
echo '=========generator DFP keys by KAIOS========='
echo '============================================='
###
#



