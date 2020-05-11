#!/bin/bash
# Author: bill.ji@unisoc.com
# secureboot avb2.0: sign modem bins
#
# Command usage:
#${BUILD_DIR}/avb_sign_modem.sh -c $IMG_DIR/out/target/product/***/***.xml -m ${MODEM_MODEM} -l ${MODEM_DSP} -g ${MODEM_G_DSP} -a ${MODEM_DSP_AG} -d ${MODEM_DFS}

# ********* #
# functions #
# ********* #

echo_title(){
    echo -e "\033[42;34m$1 \033[0m"
}

echo_exit(){
    echo -e "\033[41;37m$1 \033[0m"
}

echo_green(){
    echo -e "\033[32m$1 \033[0m"
}

echo_yellow(){
    echo -e "\033[33m$1 \033[0m"
}

function echo_eval(){
    local eg=$1
    eval eval_name="\${$eg[@]}"
    
    if [ -n "$eg" ] && [[ `echo ${eval_name} | wc -L` -ge "1" ]];then
        echo "[$eg: ${eval_name}]"
    else
        echo_exit "[$eg: ${eval_name} error!]"
        exit 1
    fi
}

function system_return(){
    return_number=$1
    return_id=$2
    
    if [[ "$#" -ne "2" ]];then
        echo_exit "[$return_id][system return ${return_number} error!]$#"
        exit 1
    fi
    
    if [[ "$return_number" -ne "0" ]];then
        echo_exit "[$return_id][system return ${return_number} error!]"
        exit 1
    else
        echo_green "[$return_id][system return ${return_number} success!]"
    fi
}

getImageName(){
    local imagename=$1
    echo ${imagename##*/}
}

getImageSize(){
    echo_title "enter getImageSize $1"
    
    case $CPBASE in
    shark|whale)
        cp_arr=(pm_sys l_modem l_ldsp l_gdsp l_agdsp l_cdsp)
        cpname_arr=($DFS $MODEM_LTE $DSP_LTE_LDSP $DSP_LTE_TG $DSP_LTE_AG $DSP_LTE_CD);;
    pike2)
        cp_arr=(pm_sys w_modem w_gdsp)
        cpname_arr=($DFS $MODEM_LTE $DSP_LTE_LDSP);;
    *)
        echo "not support for $CPBASE"
        exit;;
    esac
    
    length=${#cpname_arr[@]}
    for (( i=0; i<=$length; i++ ))
    do
        value=${cpname_arr[i]}
        if [ $value = $1 ]; then
            echo "${cpname_arr[i]} matched: ${cp_arr[i]}"
            size=`awk '/Partition id="'${cp_arr[i]}'"/{print $3}' $PAC_CONFILE | cut -d\" -f2`
            echo "size = $size"
            cur_partion=${cp_arr[i]}
            break;
        fi
    done
}

doAvbSignImage(){
    echo "enter doAvbSignImage:[$@]"
    
    for loop in $@;do
        getImageSize $loop
        if [ $size -gt 0 ];then
            sizeInByte=$(expr $size \* $MB)
        else
            echo "size($size) is wrong"
            sizeInByte=0
            continue
        fi
        echo "sizeInByte = $sizeInByte"

        echo "check dat cp"
        $SPLIT_TOOL $loop
        
        echo "start sign"
        divname=$loop.div
        if [ -f "$divname" ]; then
            echo "found dat cp, will joint sign"
            $AVB_TOOL add_hash_footer --image $divname \
                                      --partition_size $sizeInByte \
                                      --partition_name $cur_partion \
                                      --algorithm SHA256_RSA4096 \
                                      --key $MODEM_KEY \
                                      --rollback_index $rollback_index \
                                      --output_vbmeta_image $DAT_VBMETA \
                                      --do_not_append_vbmeta_image
            system_return $? add_hash_footer
    
            if [ $? -ne 0 ]; then
                echo_exit "Sign $loop failed!"
                rm $loop
                rm $divname
                continue
            fi
            echo "found div file, append vbmeta"
            $AVB_TOOL append_vbmeta_image --image $loop \
                                          --partition_size $sizeInByte \
                                          --vbmeta_image $DAT_VBMETA
            system_return $? append_vbmeta_image
            if [ $? -ne 0 ]; then
                echo_exit "Sign $loop failed!"
                rm $loop
                rm $divname
                continue
            else
                echo_green "Sign $loop succeed"
                echo "Sign $(getImageName $loop) succeed" > $Script_path/../$Project/$modem_config/Sign_Check/$(getImageName $loop).check
            fi
            rm $divname
        else
            echo "normal bin, direct sign"
            $AVB_TOOL add_hash_footer --image $loop \
                                      --partition_size $sizeInByte \
                                      --partition_name $cur_partion \
                                      --algorithm SHA256_RSA4096 \
                                      --key $MODEM_KEY \
                                      --rollback_index $rollback_index
            
            if [ $? -ne 0 ]; then
                echo_exit "Sign $loop failed!"
                rm $loop
                continue
            else
                echo_green "Sign $loop succeed"
                echo "Sign $(getImageName $loop) succeed" > $Script_path/../$Project/$modem_config/Sign_Check/$(getImageName $loop).check
            fi
        fi
    done
}

getRawSignImageName(){
    local temp1=$1
    local left=${temp1%.*}
    local temp2=$1
    local right=${temp2##*.}
    local signname=${left}"-sign."${right}
    echo $signname
}

getLogName(){
    local temp=$(getImageName $1)
    local left=${temp%.*}
    local name=$SANSA_OUTPUT_PATH/${left}".log"
    echo $name
}

doModemSignImage(){
    echo_title "enter doModemSignImage"
    rollback_index=0
    if [ ! -f "$VER_CONFIG" ]; then
        echo "version config file not found!"
    else 
        rollback_index=`sed -n '/avb_version_modem/p'  $VER_CONFIG | sed -n 's/avb_version_modem=//gp'`
    fi
    echo "rollback_index = $rollback_index"
    
    doAvbSignImage $@
}

makeModemCntCert(){
    echo "makeModemCntCert: $1"

    local CNTCFG=${SANSA_CONFIG_PATH}/certcnt_3.cfg
    local SW_TBL=${SANSA_CONFIG_PATH}/SW.tbl

    sed -i "s#.* .* .*#$1 0xFFFFFFFFFFFFFFFF 0x200#" $SW_TBL

    if [ -f $1 ] ; then
        cd $IMG_DIR/..
        echo "switch to: `pwd`"
        echo "sign......"
        python3 $SANSA_PYPATH/bin/cert_sb_content_util.py $CNTCFG $(getLogName $1)
        echo "back to:"
        cd -
        echo
    else
        echo "#### no $1,please check ####"
    fi
}

doSprdModemSignImage(){    
    if [ ! -f "$STOOL_PATH/imgheaderinsert" ]; then
        echo_exit "[== $STOOL_PATH/imgheaderinsert not found! exit ==]"
        exit
    fi
    
    if [ ! -f "$STOOL_PATH/sprd_sign" ]; then
        echo_exit "[== $STOOL_PATH/sprd_sign not found! exit ==]"
        exit
    fi
    
    if [ ! -d "$SPRD_CONFIG_FILE" ]; then
        echo_exit "[== $SPRD_CONFIG_FILE not found! exit ==]"
        exit
    fi
    
    for loop in $@;do
        if [ -f $loop ] ; then
            echo_title "doSprdModemSignImage:$loop"
            $STOOL_PATH/imgheaderinsert $loop 0
            system_return $? imgheaderinsert
            
            $STOOL_PATH/sprd_sign $(getRawSignImageName $loop) $SPRD_CONFIG_FILE
            #system_return $? sprd_sign
            echo "Sign $(getImageName $loop) succeed" > $Script_path/../$Project/$modem_config/Sign_Check/$(getImageName $loop).check
        else
            echo_exit "[== no $loop,please check ==]"
        fi
    done
}

doSansaModemSignImage(){
    if [ ! -f "$STOOL_PATH/imgheaderinsert" ]; then
        echo_exit "[== $STOOL_PATH/imgheaderinsert not found! exit ==]"
        exit
    fi
    
    if [ ! -f "$STOOL_PATH/splitimg" ]; then
        echo_exit "[== $STOOL_PATH/splitimg not found! exit ==]"
        exit
    fi
    
    if [ ! -f "$STOOL_PATH/signimage" ]; then
        echo_exit "[== $STOOL_PATH/signimage not found! exit ==]"
        exit
    fi
    
    for loop in $@;do
        if [ -f $loop ]; then
            echo "call splitimg"
            $STOOL_PATH/imgheaderinsert $loop 0
            system_return $? imgheaderinsert
            
            $STOOL_PATH/splitimg $loop
            system_return $? splitimg
            
            makeModemCntCert $loop
            
            $STOOL_PATH/signimage $SANSA_OUTPUT_PATH $(getRawSignImageName $loop) 1 0
            system_return $? signimage
            echo "Sign $(getImageName $loop) succeed" > $Script_path/../$Project/$modem_config/Sign_Check/$(getImageName $loop).check
        else
            echo_exit "[== no $loop,please check ==]"
        fi
    done
}

doInit_v1(){
    echo_title "entry doInit_v1"
    
    ChipType=`strings $MODEM_MODEM | grep "Project Version:" |awk '{print $NF}'|awk -F "_"  '{print$1}'`
    echo_eval ChipType
	
    case $ChipType in
    sharkl2|sharkl3|sharkle|sl8541e)
        echo "shark series"
        CPBASE=shark
        DFS=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DFS)
        MODEM_LTE=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_MODEM)
        DSP_LTE_LDSP=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DSP)
        DSP_LTE_TG=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_G_DSP)
            
        cp $MODEM_DFS   ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DFS
        cp $MODEM_MODEM ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_MODEM
        cp $MODEM_DSP   ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DSP
        cp $MODEM_G_DSP ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_G_DSP
        
        images="$DFS $MODEM_LTE $DSP_LTE_LDSP $DSP_LTE_TG"
    ;;
    sharkl5)
        echo "whale series"
        CPBASE=whale
        DFS=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DFS)
        MODEM_LTE=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_MODEM)
        DSP_LTE_LDSP=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DSP)
        DSP_LTE_TG=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_G_DSP)
        DSP_LTE_AG=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DSP_AG)
        
        cp $MODEM_DFS    ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DFS
        cp $MODEM_MODEM  ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_MODEM
        cp $MODEM_DSP    ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DSP
        cp $MODEM_G_DSP  ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_G_DSP
        cp $MODEM_DSP_AG ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DSP_AG
        
        images="$DFS $MODEM_LTE $DSP_LTE_LDSP $DSP_LTE_TG $DSP_LTE_AG"
    ;;
    pike2)
        echo "pike2 series"
        CPBASE=pike2
        DFS=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DFS)
        MODEM_LTE=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_MODEM)
        DSP_LTE_LDSP=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_G_DSP)
        
        cp $MODEM_DFS   ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DFS
        cp $MODEM_MODEM ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_MODEM
        cp $MODEM_G_DSP   ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_G_DSP
        
        images="$DFS $MODEM_LTE $DSP_LTE_LDSP"
    ;;
    *)
        echo_exit "[== not support for $ChipType ==]"
        exit;;
    esac
    
    if [ -f "$SPRD_SECURE_FILE" ];then
        echo "found sprd_secure_file"
        doSprdModemSignImage $images
    elif (echo $SchemeName | grep "dxsec") 1>/dev/null 2>&1 ; then
        echo "found dxsec"
        doSansaModemSignImage $images
    else
        echo_exit "[== not secureboot proj, no need to sign! ==]"
        exit
    fi
    
    echo_yellow "${IMG_DIR}/${PROJ}:ls -l"
    ls -l ${IMG_DIR}/${PROJ}
}

doInit_v2(){
    echo_title "entry doInit_v2"
    
    if [ ! -f "$SPRD_SECURE_FILE" ]; then
        echo_exit "[== not secureboot proj, no need to sign! ==]"
        exit
    fi
    
    if [ ! -f "$AVB_TOOL" ]; then
        echo_exit "[== avbtool not found! exit ==]"
        exit
    fi
    
    if [ ! -f "$SPLIT_TOOL" ]; then
        echo_exit "[== splitimg not found! exit ==]"
        exit
    fi
    
    ChipType=`strings $MODEM_MODEM | grep "Project Version:" |awk '{print $NF}'|awk -F "_"  '{print$1}'`
    echo_eval ChipType
    
    case $ChipType in
    sharkl2|sharkl3|sharkle|sl8541e)
        echo "shark series"
        CPBASE=shark
        DFS=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DFS)
        MODEM_LTE=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_MODEM)
        DSP_LTE_LDSP=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DSP)
        DSP_LTE_TG=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_G_DSP)
            
        cp $MODEM_DFS   ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DFS
        cp $MODEM_MODEM ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_MODEM
        cp $MODEM_DSP   ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DSP
        cp $MODEM_G_DSP ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_G_DSP
        
        doModemSignImage $DFS $MODEM_LTE $DSP_LTE_LDSP $DSP_LTE_TG
    ;;
    sharkl5|sharkl5pro)
        echo "whale series"
        CPBASE=whale
        DFS=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DFS)
        MODEM_LTE=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_MODEM)
        DSP_LTE_LDSP=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DSP)
        DSP_LTE_TG=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_G_DSP)
        DSP_LTE_AG=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DSP_AG)
        DSP_LTE_CD=${IMG_DIR}/${PROJ}/$(getImageName $DSP_LTE_CDMA)
        
        cp $MODEM_DFS    ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DFS
        cp $MODEM_MODEM  ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_MODEM
        cp $MODEM_DSP    ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DSP
        cp $MODEM_G_DSP  ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_G_DSP
        cp $MODEM_DSP_AG ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DSP_AG
        cp $DSP_LTE_CDMA ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $DSP_LTE_CDMA
        
        doModemSignImage $DFS $MODEM_LTE $DSP_LTE_LDSP $DSP_LTE_TG $DSP_LTE_AG $DSP_LTE_CD
    ;;
    pike2)
        echo "pike2 series"
        CPBASE=pike2
        DFS=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_DFS)
        MODEM_LTE=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_MODEM)
        DSP_LTE_LDSP=${IMG_DIR}/${PROJ}/$(getImageName $MODEM_G_DSP)
        
        cp $MODEM_DFS   ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_DFS
        cp $MODEM_MODEM ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_MODEM
        cp $MODEM_G_DSP   ${IMG_DIR}/${PROJ}/ -rfv
        system_return $? $MODEM_G_DSP
        
        doModemSignImage $DFS $MODEM_LTE $DSP_LTE_LDSP
    ;;
    *)
        echo_exit "[== not support for $ChipType ==]"
        exit;;
    esac
    
    [ -f "$DAT_VBMETA" ] && rm $DAT_VBMETA
    
    echo_yellow "${IMG_DIR}/${PROJ}:ls -l"
    ls -l ${IMG_DIR}/${PROJ}
}

sign_modem_dir(){
    if [ -d $IMG_DIR/$PROJ ] && [ -d $IMG_DIR/out ];then
        rm -rf $IMG_DIR/$PROJ/
    fi
    mkdir -p $IMG_DIR/$PROJ
}

# **************** #
# input parameters #
# **************** #
echo_title "#### Sign modem script, ver 2.0 ####"

while getopts ":c:m:d:g:l:a:x:" opt;do
    case $opt in
        c)
            export PAC_CONFILE=$OPTARG
            echo_yellow "\n-c PAC_CONFILE"
            echo_eval PAC_CONFILE
            
            export IMG_DIR=${PAC_CONFILE%out*}
            echo_eval IMG_DIR
            
            export SPRD_SECURE_FILE=${PAC_CONFILE%/*}/PRODUCT_SECURE_BOOT_SPRD
            echo_eval SPRD_SECURE_FILE
            
            export DAT_VBMETA=${PAC_CONFILE%/*}/dat_vbmeta.img
            echo_eval DAT_VBMETA
            
            export PROJ=sign_modem
            echo_eval PROJ
            
            export SchemeName=`grep  "<SchemeName>" $PAC_CONFILE |awk -F "<" '{print$2}'|awk -F ">" '{print$NF}'`
            echo_eval SchemeName
            
        ;;
        m)
            export MODEM_MODEM=$OPTARG
            echo_yellow "\n-m MODEM_MODEM"
            echo_eval MODEM_MODEM
        ;;
        d)
            export MODEM_DFS=$OPTARG
            echo_yellow "\n-d MODEM_DFS"
            echo_eval MODEM_DFS
        ;;
        g)
            export MODEM_G_DSP=$OPTARG
            echo_yellow "\n-g MODEM_G_DSP"
            echo_eval MODEM_G_DSP
        ;;
        l)
            export MODEM_DSP=$OPTARG
            echo_yellow "\n-l MODEM_DSP"
            echo_eval MODEM_DSP
        ;;
        x)
            export DSP_LTE_CDMA=$OPTARG
            echo_yellow "\n-x DSP_LTE_CDMA"
            echo_eval DSP_LTE_CDMA
        ;;
        a)
            export MODEM_DSP_AG=$OPTARG
            echo_yellow "\n-a MODEM_DSP_AG"
            echo_eval MODEM_DSP_AG
        ;;
        \?)
            echo -e "\n[parameters error!]\n"
            exit 1
        ;;
    esac
done

# ************* #
# main function #
# ************* #

PLATFORM_VERSION=$(grep "PLATFORM_VERSION :="  $IMG_DIR/build/core/version_defaults.mk | awk -F "= " '{print $NF}')
PLATFORM_VERSION_QP1A=$(grep "PLATFORM_VERSION.QP1A :="  $IMG_DIR/build/core/version_defaults.mk | awk -F "= " '{print $NF}')

case $PLATFORM_VERSION in
    '4.4.4'|'6.0'|'7.0')
        export STOOL_PATH=$IMG_DIR/out/host/linux-x86/bin
        export SPRD_CONFIG_FILE=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sprd/config
        export SANSA_CONFIG_PATH=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sansa/config
        export SANSA_OUTPUT_PATH=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sansa/output
        export SANSA_PYPATH=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sansa/python
        
        echo_eval PLATFORM_VERSION
        echo_eval STOOL_PATH
        echo_eval SPRD_CONFIG_FILE
        echo_eval SANSA_CONFIG_PATH
        echo_eval SANSA_OUTPUT_PATH
        echo_eval SANSA_PYPATH
        
        sign_modem_dir
        doInit_v1 $@
    ;;
    *)
        if [[ $PLATFORM_VERSION_QP1A == "10" ]];then
            PLATFORM_VERSION_QP1A=$(grep "PLATFORM_VERSION.QP1A :="  $IMG_DIR/build/core/version_defaults.mk | awk -F "= " '{print $NF}')
            export AVB_TOOL=$IMG_DIR/out/host/linux-x86/bin/avbtool
            export SPLIT_TOOL=$IMG_DIR/out/host/linux-x86/bin/splitimg
            export MODEM_KEY=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sprd/config/rsa4096_modem.pem
            export VER_CONFIG=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sprd/config/version.cfg
            export MB=1048576

            echo_eval PLATFORM_VERSION_QP1A
            echo_eval AVB_TOOL
            echo_eval SPLIT_TOOL
            echo_eval MODEM_KEY
            echo_eval VER_CONFIG
            echo_eval MB

            sign_modem_dir
            doInit_v2 $@
        else
            PLATFORM_VERSION=$(grep "PLATFORM_VERSION.[a-Z][a-Z][a-Z][0-9] :="  $IMG_DIR/build/core/version_defaults.mk |awk -F "= " '{print $NF}')
            export AVB_TOOL=$IMG_DIR/out/host/linux-x86/bin/avbtool
            if [ ! -e $AVB_TOOL ] && [[ "$PLATFORM_VERSION" = "8.1.0" ]];then
                export STOOL_PATH=$IMG_DIR/out/host/linux-x86/bin
                export SPRD_CONFIG_FILE=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sprd/config
                export SANSA_CONFIG_PATH=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sansa/config
                export SANSA_OUTPUT_PATH=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sansa/output
                export SANSA_PYPATH=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sansa/python

                echo_eval PLATFORM_VERSION
                echo_eval STOOL_PATH
                echo_eval SPRD_CONFIG_FILE
                echo_eval SANSA_CONFIG_PATH
                echo_eval SANSA_OUTPUT_PATH
                echo_eval SANSA_PYPATH

                sign_modem_dir
                doInit_v1 $@
            else
                export SPLIT_TOOL=$IMG_DIR/out/host/linux-x86/bin/splitimg
                export MODEM_KEY=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sprd/config/rsa4096_modem.pem
                export VER_CONFIG=$IMG_DIR/vendor/sprd/proprietories-source/packimage_scripts/signimage/sprd/config/version.cfg
                export MB=1048576

                echo_eval PLATFORM_VERSION
                echo_eval AVB_TOOL
                echo_eval SPLIT_TOOL
                echo_eval MODEM_KEY
                echo_eval VER_CONFIG
                echo_eval MB

                sign_modem_dir
                doInit_v2 $@
            fi
        fi
;;
esac
