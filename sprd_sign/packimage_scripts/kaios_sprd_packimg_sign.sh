#!/bin/bash

##########init valiable ###################
# return value 127 means that files not exist
# return value 128 means that parm NO. wrong
# return value 129 means that exec prom wrong

#########################################
function usage() {

	#######################################
	# Dump usage howto
	#######################################

	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
	    echo "1 $1 is root key path"
	    echo "2 $2 is source image path"
        echo "3 $3 is production name"
	    echo "./packimage.sh /local/keys_sprd /home/dhcui/sprd_2020_0515 sp9820e_2c10aov"
	    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
}

if [ $# -lt 3 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
fi

KEY_PATH=$1
PRODUCT_OUT=$2
TARGETPRODUCT=$3

#if [ "" = $PRODUCT_NAME ];then
#echo "NOT SUPPORT"
#exit 129
#fi

if [ -d $KEY_PATH ];then
   echo "Begin to sign"
else
   echo "!!! error !!! key path not exist "
   exit 127
fi


CURDIR="`dirname $0`"

#FIXED-ME 
SECURE_BOOT="SPRD"
SECURE_BOOT_KCE="NONE"
HOST_OUT="/../bin"
HOST_OUT_LIB="/../lib"
TARGETBOARD="sp9820e"

CURPATH=$(pwd)

#this path for dosprdcopy
DESTDIR=$CURDIR/signimage/sprd/mkdbimg/bin

#FIXED-ME key config path
CFGPATH=$CURDIR/signimage/sprd/config

#this for modem sign process
cp $CFGPATH/version.cfg $KEY_PATH || { echo "can not copy version config"; exit 127 ; }

KCE_TYPE="NONE"
if [ "128" = "$KCE_TYPE" ]; then
        AESKEY=$CFGPATH/aeskey_128
    else
        AESKEY=$CFGPATH/aeskey
fi

SPL=$PRODUCT_OUT/u-boot-spl-16k.bin
SPLSIGN=$PRODUCT_OUT/u-boot-spl-16k-sign.bin
SML=$PRODUCT_OUT/sml.bin
SMLSIGN=$PRODUCT_OUT/sml-sign.bin
TOS=$PRODUCT_OUT/tos.bin
TOSSIGN=$PRODUCT_OUT/tos-sign.bin
SECVM=$PRODUCT_OUT/secvm.bin
SECVMSIGN=$PRODUCT_OUT/secvm-sign.bin
MVCFG=$PRODUCT_OUT/mvconfig.bin
MVCFGSIGN=$PRODUCT_OUT/mvconfig-sign.bin
MOB=$PRODUCT_OUT/mobilevisor.bin
MOBSIGN=$PRODUCT_OUT/mobilevisor-sign.bin
UBOOTDT=$PRODUCT_OUT/u-boot-dtb.bin
UBOOTDTSIGN=$PRODUCT_OUT/u-boot-dtb-sign.bin
UBOOT=$PRODUCT_OUT/u-boot.bin
UBOOTSIGN=$PRODUCT_OUT/u-boot-sign.bin
FDL1=$PRODUCT_OUT/fdl1.bin
FDL1SIGN=$PRODUCT_OUT/fdl1-sign.bin
FDL2=$PRODUCT_OUT/fdl2.bin
FDL2SIGN=$PRODUCT_OUT/fdl2-sign.bin
BOOT=$PRODUCT_OUT/boot.img
BOOTSIGN=$PRODUCT_OUT/boot-sign.img
#UBOOTAUTO=$PRODUCT_OUT/u-boot_autopoweron.bin
#UBOOTAUTOSIGN=$PRODUCT_OUT/u-boot_autopoweron-sign.bin
RECOVERY=$PRODUCT_OUT/recovery.img
RECOVERYSIGN=$PRODUCT_OUT/recovery-sign.img

#This switch controls whether the sansa debug certificate is added to the tail of spl
#0: disable
#1: enable
debug_cert=0

checkEnv()
{
    PYTHON_VERSION=$(python3 -V 2>&1|grep '^Python 3\.[0-9]\.[0-9]')
    if [[ -z $PYTHON_VERSION ]]
    then
        echo "No python3 found! Install by execute \"sudo apt-get install python3\"[ERROR]"
        return
    fi
    #echo check python3 version $PYTHON_VERSION [OK]
}

getModuleName()
{
    local is_find=1
    local name="allmodules"
    local param="MODULES-IN-"   #---mma

    if [ $# -gt 0 ]; then
        for loop in $@
        do
            case $loop in
            "chipram")
            name="chipram"
            break
            ;;
            "bootloader")
            name="bootloader"
            break
            ;;
            "bootimage")
            name="bootimage"
            break
            ;;
            "systemimage")
            name="systemimage"
            break
            ;;
            "userdataimage")
            name="userdataimage"
            break
            ;;
            "recoveryimage")
            name="recoveryimage"
            break
            ;;
            "trusty")
            name="trusty"
            break
            ;;
            "clean")
            name="clean"
            break
            ;;
            *)
	    is_find=0
            ;;
            esac
        done
    #else
	#name="dummy"    #still packall
    fi

    if [ $is_find -eq 0 ]; then
        for loop in $@
	do
	    if [ ${loop:0:11} == $param ]; then
                name="dummy"
	        break
	    fi
	done
    fi

    echo $name
}

getCertLevel()
{
    local level
    case $1 in
        $SPLSIGN)
            level=3
            ;;
        $FDL1SIGN)
            level=3
            ;;
        $UBOOTSIGN)
            level=2
            ;;
        $FDL2SIGN)
            level=2
            ;;
        *)
            level=1
            ;;
    esac
    echo $level
}

doImgHeaderInsert()
{
    local NO_SECURE_BOOT

    if [ "NONE" = $SECURE_BOOT ]; then
        NO_SECURE_BOOT=1
    else
        NO_SECURE_BOOT=0
    fi

    for loop in $@
    do
        if [ -f $loop ] ; then
            echo "begin to imgheaderinsert about" $loop
            LD_LIBRARY_PATH=$CURDIR$HOST_OUT_LIB $CURDIR$HOST_OUT/imgheaderinsert $loop $NO_SECURE_BOOT
        else
            echo "#### HeaderInsert $loop, check ####"
        fi
    done
}
dorename()
{
    for filename in $PRODUCT_OUT/*-cipher*
    do
        mv $filename ${filename/-cipher/}
    done
}
doAESencrypt()
{
    if [ "NONE" = $SECURE_BOOT ]; then
        return
    fi
    if [ "DISABLE" = $SECURE_BOOT_KCE ]; then
        return
    fi
	for image in $@
	do
		if [ -f $image ]; then
			LD_LIBRARY_PATH=$CURDIR$HOST_OUT_LIB $CURDIR$HOST_OUT/sprd_encrypt $AESKEY   $image
		else
			echo -e "\033[31m ####  no $image or aeskey file, pls check #### \033[0m"
		fi
	done
    dorename
}
dosprdcopy()
{
    if [ -f $SPLSIGN ];then
        cp $SPLSIGN $DESTDIR ||{ echo "can not copy dosprdcopy" $SPLSIGN; exit 127;}
        #echo -e "\033[33m copy spl-sign.bin finish!\033[0m"
    fi

    if [ -f $FDL1SIGN ]; then
        cp $FDL1SIGN $DESTDIR ||{ echo "can not copy dosprdcopy" $FDL1SIGN; exit 127;}
        #echo -e "\033[33m copy fdl1-sign.bin finish!\033[0m"
    fi
}

doSignImage()
{
    if [ "NONE" = $SECURE_BOOT ]; then
        return
    fi
    #/*add sprd sign*/
    if [ "SPRD" = $SECURE_BOOT ]; then
        for image in $@
        do
            if [ -f $image ]; then
               echo "********************************"
               echo "begin to sprd sign about " $image 
               echo LD_LIBRARY_PATH=$CURDIR$HOST_OUT_LIB $CURDIR$HOST_OUT/sprd_sign  $image  $KEY_PATH
               LD_LIBRARY_PATH=$CURDIR$HOST_OUT_LIB $CURDIR$HOST_OUT/sprd_sign  $image  $KEY_PATH
               echo "********************************"
               echo "end to sprd sign about " $image 
            else
                echo -e "\033[31m ####  SignImage $image, check #### \033[0m"
            fi
        done
        #call this function do copy fdl1&spl to mkdbimg/bin document
        dosprdcopy
    fi

#    if [ "SANSA" = $SECURE_BOOT ]; then
#        for image in $@
#        do
#            if [ -f $image ] ; then
#                LD_LIBRARY_PATH=$CURDIR$HOST_OUT_LIB $CURDIR$HOST_OUT/sansa_sign.sh $image $SECURE_BOOT_KCE
#                if [ $? -eq 0 ]; then
#                    LD_LIBRARY_PATH=$CURDIR$HOST_OUT_LIB $CURDIR$HOST_OUT/signimage $CERTPATH $image $(getCertLevel $image) $debug_cert
#                else
#                    echo "sansa_sign result failed"
#                fi
#            else
#                echo "#### no $image,please check ####"
#            fi
#        done
#    fi
}

doPackImage()
{
    if [ "SANSA" = $SECURE_BOOT ]; then
        checkEnv
    fi
    case $(getModuleName "$@") in
        "chipram")
            if (echo $TARGETBOARD | grep -E 'whale|sp9001|sp9850s|sp9860g|sp9833|sp9850ka|sc9850j|9850kh|sp9820e') 1>/dev/null 2>&1 ; then
                doImgHeaderInsert $SPL $SML $TOS $FDL1
                doSignImage $SPLSIGN $SMLSIGN $TOSSIGN $FDL1SIGN
             elif (echo $TARGETPRODUCT | grep -E 'iwhale2|sp9861e|sp9853i') 1>/dev/null 2>&1; then
                doImgHeaderInsert $SPL $FDL1 $SECVM $MVCFG $MOB
                doAESencrypt $SECVMSIGN $MVCFGSIGN $MOBSIGN $SPLSIGN
                doSignImage $SPLSIGN $FDL1SIGN $SECVMSIGN $MVCFGSIGN $MOBSIGN
            else
                doImgHeaderInsert $SPL $FDL1
                doSignImage $SPLSIGN $FDL1SIGN
            fi
            rm $SPL $FDL1
            ;;
        "bootloader")
            if (echo $TARGETPRODUCT | grep -E 'iwhale2|sp9861e|sp9853i') 1>/dev/null 2>&1; then
                 doImgHeaderInsert  $FDL2 $UBOOT $UBOOTAUTO
                 doAESencrypt $UBOOTSIGN
                 doSignImage  $FDL2SIGN $UBOOTSIGN $UBOOTAUTOSIGN
             else
            doImgHeaderInsert $UBOOT $FDL2 $UBOOTAUTO
            doSignImage $UBOOTSIGN $FDL2SIGN $UBOOTAUTOSIGN
            fi
            rm $UBOOT $FDL2 $UBOOTAUTO
            ;;
        "bootimage")
            if [ "NONE" = $SECURE_BOOT ]; then
                echo "secure boot not enabled, skip!"
            else
                doImgHeaderInsert $BOOT
                doSignImage $BOOTSIGN
            fi
            ;;
        "recoveryimage")
            if [ "NONE" = $SECURE_BOOT ]; then
                echo "secure boot not enabled, skip!"
            else
                doImgHeaderInsert $RECOVERY
                doSignImage $RECOVERYSIGN
            fi
            ;;
        "trusty")
                doImgHeaderInsert $TOS
                doSignImage $TOSSIGN
            ;;
        "dummy")
		#do nothing
            ;;
        "allmodules")
            if [ "NONE" = $SECURE_BOOT ]; then
                if (echo $TARGETBOARD | grep -E 'whale|sp9001|sp9850s|sp9860g|sp9833|sp9850ka|sc9850j|9850kh|sp9820e') 1>/dev/null 2>&1 ; then
                    doImgHeaderInsert $SPL $UBOOT $FDL1 $FDL2 $SML $TOS $UBOOTAUTO
                elif (echo $TARGETPRODUCT | grep -E 'iwhale2|sp9861e|sp9853i') 1>/dev/null 2>&1 ; then
                    doImgHeaderInsert $SPL $FDL1 $SECVM $MVCFG $MOB  $FDL2  $UBOOT $UBOOTAUTO
                else
                    doImgHeaderInsert $SPL $UBOOT $FDL1 $FDL2 $UBOOTAUTO
                fi
                rm -f $SPL $FDL1 $UBOOT $FDL2 $UBOOTAUTO
            else
                if (echo $TARGETBOARD | grep -E 'whale|sp9001|sp9850s|sp9860g|sp9833|sp9850ka|sc9850j|9850kh|sp9820e'); then
                    doImgHeaderInsert $SPL $SML $TOS $UBOOT $FDL1 $FDL2 $BOOT $RECOVERY $UBOOTAUTO
                    sleep 3
                    doSignImage $SPLSIGN $SMLSIGN $TOSSIGN $UBOOTSIGN $FDL1SIGN $FDL2SIGN $BOOTSIGN $RECOVERYSIGN $UBOOTAUTOSIGN
                fi
                #FIXED-ME temp disable remove 
                #rm -f $SPL $FDL1 $UBOOT $FDL2 $BOOT $RECOVERY $UBOOTAUTO
            fi
            ;;
        "clean")
            #do nothing
            ;;
        *)
            ;;
    esac
}

if [ -d $PRODUCT_OUT ];then
    echo "enter packimage.sh  do ls start"
    ls $PRODUCT_OUT
    echo "enter packimage.sh  do ls end"
fi

echo "==============================================="
echo "======== sign img begin=========="
echo "==============================================="
sleep 3
echo "INFO: input param: $@"
doPackImage "$@"

echo "==============================================="
echo "======== sign img end=========="
echo "==============================================="
echo 
echo 
echo 