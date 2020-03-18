# generator root key 
openssl genrsa -out root_prvk.pem 2048
#
python der_extractor/pem_to_der.py root_prvk.pem root_prvk.der

#
openssl rsa -in root_prvk.pem -pubout >root_pubk.pem

#
python der_extractor/pem_to_der.py root_pubk.pem root_pubk.der

##genator imgkey 

openssl genrsa -out img_prvk.pem 2048
#
python der_extractor/pem_to_der.py img_prvk.pem img_prvk.der

#
openssl rsa -in img_prvk.pem -pubout >img_pubk.pem

#
python der_extractor/pem_to_der.py img_pubk.pem img_pubk.der


echo 'use root_pubk.der generator oemkey.h and copy to matched folder (need release to odm)'

#./der_extractor/der_extractor  root_pubk.der oemkey.h ANDROID_SBC

#copy oemkey.h to [DA] $DA_Kit/Raphael-da/custom/$PLATFORM/oemkey.h
#copy oemkey.h to [PL] $PL/custom/$PORJECT/inc/oemkey.h
#copy oemkey.h to [LK] $LK/target/$PROJECT/inc/oemkey.h

echo 'use root_pubk.der generator dakey.h this include DA_PL public key to verify preloader DA_PL.bin'
#when sign DA_PL.bin use matched prvk.pem to sign

#./der_extractor/der_extractor  root_pubk.der dakey.h ANDROID_SBC

#copt dakey.h to [PL]$PL/custom/$PROJECT/inc/dakey.h
#please note we need modify the dakey.h and replace 'OEM' to 'DA'

echo 'will be generator '

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
echo '/local/code/mtk-m/KaiOS/vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/kaios31_jpv/security/chip_config/s/key'

echo 'config pl_key.ini /plcontent.ini /pl_gfh_config_cert_chain.ini'

###




