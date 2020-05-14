#!/bin/bash
#########################################################################################################################
#																														#
#1、脚本需要在 ./vendor/sprd/release/IDH/Script 目录下执行，并加执行权限。													#
#2、脚本执行方式：./build_pac.sh -a "参数-a" -b "参数-b" -c "参数-c"														#
#3、-a & -b 是必填项，-c 可选。-c 参数只对编译有影响，对pac 没有影响。														#
#4、参数-a ./vendor/sprd/release/IDH 目录下面 "sp*" 目录名称Eg：sp9832e_1h10_reliance-user-native							#
#5、参数-b ALL|all:编译和打PAC包;  BUILD|build:只编译；  PAC|pac:只打PAC包;  BOTA|bota:编译和OTA   OTA|ota:只编译OTA	#
#6、参数-c 是编译运营商工程，如果有多个用英文","隔开。																		#
#7、生成的pac 包在"参数-a"目录内除out目录外的子目录下。																	#
#																														#
#########################################################################################################################


function echo_eval(){
	#打印参数值+检查参数不许为空

	local eg=$1
	eval eval_name="\${$eg[@]}"
	if [ -n "$eg" ] && [[ `echo ${eval_name} | wc -L` -ge "1" ]];then
		echo -e "[$eg: ${eval_name}]"
	else
		echo -e "\n[$eg: ${eval_name} error!]\n"
		exit 1
	fi
}

function system_return(){
	#判断上一个程序的系统返回值，如果非0就退出

	local return_number=$1
	local return_id=$2
	
	if [[ "$#" -ne "2" ]];then
		echo -e "\n[system return $# error!]\n"
		echo "${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
		exit 1
	fi
	
	if [[ "$return_number" -ne "0" ]];then
		echo -e "\n[$return_id][system return ${return_number} error!]\n"
		echo "${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
		exit 1
	else
		echo -e "\n[$return_id][system return ${return_number} success!]\n"
	fi	
}

function Project_Split(){
	#拆分 $Project ，获取参数
	
	local ARGV=$1
	#[ ! -d $Script_path/../$ARGV ] && echo -e "\n[Project_Split Check ERROR!]\n" && exit 1

	export Project_name=`echo $ARGV | awk -F "-" '{print $1}'`
	export Project_ver=`echo $ARGV | awk -F "-" '{print $2}'`
	export Project_vlx=`echo $ARGV | awk -F "-" '{print $3}'`
	echo_eval Project_name
	echo_eval Project_ver
	echo_eval Project_vlx
}

function gms_flag(){
	#确认是否需要设置 gms size
	mk_file="BoardConfig.mk"
	
	product_mk_file=$(readlink -f `find $code_path/device/sprd/ -name ${Project_name}.mk`)
	echo_eval product_mk_file
	#Eg:/space/builder/.../device/sprd/sharkle/sp9832e_1h10_go/sp9832e_1h10_go_osea.mk
	
	mk_file_dir=`dirname $product_mk_file`
	echo_eval mk_file_dir
	#Eg:/space/builder/.../device/sprd/sharkle/sp9832e_1h10_go
	
	if [[ "$Project_vlx" == "gms" ]];then
		echo -e "\n[gms_flag check is gms]\n"
		if [ -e $Script_path/../$Project/gms_info ];then
			gms_size=`grep "gms_size=" $Script_path/../$Project/gms_info | awk -F "=" '{print $NF}' | sed 's/"//g'`
			echo_eval gms_size
			
			if [[ "$gms_size" == "AndroidP" ]];then
				echo "AndroidP:9.0"
			else
				if [ -e $mk_file_dir/${mk_file} ] && [ -e $mk_file_dir/${Project_name}.mk ];then
					if [ -e $mk_file_dir/${mk_file}.tmp ] && [ -e $mk_file_dir/${Project_name}.mk.tmp ];then
						cp -rf $mk_file_dir/${mk_file}.tmp $mk_file_dir/${mk_file}
						system_return $? cp_mk_file_temp
						
						cp -rf $mk_file_dir/${Project_name}.mk.tmp $mk_file_dir/${Project_name}.mk
						system_return $? Project_name_mk_temp
					else
						cp -rf $mk_file_dir/${mk_file} $mk_file_dir/${mk_file}.tmp
						system_return $? cp_mk_file
						
						cp -rf $mk_file_dir/${Project_name}.mk $mk_file_dir/${Project_name}.mk.tmp
						system_return $? Project_name_mk
					fi
				else
					echo -e "[\n[$mk_file_dir/(file) don't exist!]\n]"
				fi
				
				sed -i "/^BOARD_SYSTEMIMAGE_PARTITION_SIZE/ c \BOARD_SYSTEMIMAGE_PARTITION_SIZE := $gms_size" $mk_file_dir/$mk_file
				
				gms_infos=$(grep 'ro.com.google.clientidbase=' $product_mk_file)
				if [ -z "$gms_infos" ];then
					cp -rf $Script_path/../$Project/gms_info $Script_path/../$Project/gms_info.tmp
					sed -i '/^gms_size=/'d $Script_path/../$Project/gms_info.tmp
					cat $Script_path/../$Project/gms_info.tmp >>$product_mk_file
				else
					echo  "[current mkfile include gms call]"
				fi
			fi
		else
			echo -e "\n[[$Script_path/../$Project/gms_info]don't exist!]\n"
			exit 1
		fi
	elif [[ "$Project_vlx" == "native" ]];then
		echo -e "\n[gms_flag check is native]\n"
		if [ -e $mk_file_dir/${mk_file}.tmp ];then
			cp -rf $mk_file_dir/${mk_file}.tmp $mk_file_dir/${mk_file}
			system_return $? cp_mk_file_temp
		fi
		if [ -e $mk_file_dir/${Project_name}.mk.tmp ];then
			cp -rf $mk_file_dir/${Project_name}.mk.tmp $mk_file_dir/${Project_name}.mk
			system_return $? Project_name_mk_temp
		fi
	else
		echo -e "\n[gms_flag check Error!]\n"
		exit 1
	fi
}
# sparse to raw 

function transunsparse(){
    set -x
	TARGET_BOARD=`find $code_path/out/target/product -maxdepth 2 -name "*.xml"|tail -n 1|awk -F ".xml" '{print$1}'|awk -F "/" '{print$(NF-1)}'`
	echo_eval TARGET_BOARD
	if [[ "${#TARGET_BOARD[@]}" == "1" ]] && [ -d $code_path/out/target/product/$TARGET_BOARD ];then
		OUT_DIR="$code_path/out/target/product/$TARGET_BOARD"
		echo_eval OUT_DIR
	else
		echo -e "\n[ out dir find fail !]\n"
		exit 1
	fi
	cd $code_path
	if [[ -e $OUT_DIR/system.img ]];then
		./out/host/linux-x86/bin/simg2img $OUT_DIR/system.img $OUT_DIR/unsparse-system.img
		cd $OUT_DIR
		mv unsparse-system.img system.img
	fi
	cd $code_path
	if [[ -e $OUT_DIR/super.img ]];then
		./out/host/linux-x86/bin/simg2img $OUT_DIR/super.img $OUT_DIR/unsparse-super.img
		cd $OUT_DIR
		mv unsparse-super.img super.img
	fi
	cd $code_path
	if [[ -e $OUT_DIR/vendor.img ]];then
		./out/host/linux-x86/bin/simg2img $OUT_DIR/vendor.img $OUT_DIR/unsparse-vendor.img
		cd $OUT_DIR
		mv unsparse-vendor.img vendor.img
	fi
}

function BUILD(){
	#编译

	cd $code_path
	system_return $? cd_code_path
	
	if [ -d $Script_path/../$Project/out ];then
		rm -rf $code_path/out
		cp -rf $Script_path/../$Project/out $code_path
		
		[ -d $Script_path/../$Project/bsp ] && cp -rf $Script_path/../$Project/bsp $code_path
	else
		echo -e "\n[out Check ERROR!]\n"
		echo "[BUILD] ${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
		exit 1
	fi
	
	if [ -d $Script_path/../device ] && [[ `du -s $Script_path/../device | awk -F ' ' '{ print $1}'` -ge "1024" ]];then
		cp -rf $Script_path/../device $code_path
	else
		if [ ! -d $code_path/device/sprd ] || [[ `du -s $code_path/device/sprd | awk -F ' ' '{ print $1}'` -lt "1024" ]];then
			echo -e "\n[device Check ERROR!]\n"
			echo "[BUILD] ${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
			exit 1
		fi
	fi
	
	[ ! -e $code_path/build/core/version_defaults.mk ] && echo -e "\n[[$code_path/build/core/version_defaults.mk]don't exist!]\n" && exit 1

############################################################################################################
#以下 "#" 之间是 unisoc 编译验证自动设置环境变更使用，客户需要依据客户环境来设置环境变更。
	if [ -e $Script_path/Build_Path.sh ];then
		chmod a+x $Script_path/Build_Path.sh
		fromdos $Script_path/Build_Path.sh
		source $Script_path/Build_Path.sh $code_path
	fi
############################################################################################################

	gms_flag
	
	CPU_COUNT=$(cat /proc/cpuinfo | grep -i 'processor' | wc -l)
	
	PLATFORM_SDK_VERSION=$(grep "PLATFORM_SDK_VERSION :="  $code_path/build/core/version_defaults.mk | awk -F "= " '{print $NF}')
	if [ $PLATFORM_SDK_VERSION -gt 27 ];then
		source build/envsetup.sh
		choosecombo 1 $Project_name $Project_ver $Project_vlx
		lunch ${Project_name}-${Project_ver}-${Project_vlx}
		kheader
		make $carrier_param -j$CPU_COUNT
		if [[ "$PLATFORM_SDK_VERSION " == "29" ]];then
            transunsparse
		fi
	else
		source build/envsetup.sh
		lunch ${Project_name}-${Project_ver}
		kheader
		make $carrier_param -j$CPU_COUNT
	fi
}


function PAC(){
	#制作 pac 包
	echo "dhcui-debug 1"
	OUT_DIR=$production_out

	#FIXED_ME product.img mv to copy script 
	#if [ -e "$production_out/.carrier" ];then
	#	. $production_out/.carrier
	#	echo_eval carrier
	#	if [ -e $OUT_DIR/$carrier/product.img ] && [ -e $Script_path/../ImageFiles/product.img ];then
	#		cp -rfv $OUT_DIR/$carrier/product.img $Script_path/../ImageFiles/product.img
	#	else
	#		echo -e "\n[product.img check fail !]\n"
	#		continue
	#	fi
	#fi
	cd $production_out
	
        echo perl mkpac.pl "${Project}_${modem_config}.pac" "flash.cfg" "FlashParam"
	perl $root_path/modem_script/mkpac.pl "${Project}_${modem_config}.pac" "flash.cfg" "FlashParam"

}

function PAC_TMP(){
    #制作 tmp pac 包,内部验证自动签名工具
    . $Script_path/.unisoc
    echo_eval unisoc_release_path
    if [ -d $unisoc_release_path ];then
        TARGET_BOARD=`find $code_path/out/target/product -maxdepth 2 -name "*.xml"|tail -n 1|awk -F ".xml" '{print$1}'|awk -F "/" '{print$(NF-1)}'`
	    echo_eval TARGET_BOARD

	    if [[ "${#TARGET_BOARD[@]}" == "1" ]] && [ -d $code_path/out/target/product/$TARGET_BOARD ];then
		    OUT_DIR="$code_path/out/target/product/$TARGET_BOARD"
		    echo_eval OUT_DIR
	    else
		    echo -e "\n[ out dir find fail !]\n"
		    echo "${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
		    exit 1
	    fi

        for flash_cfg in `cd $Script_path/../$Project && find -maxdepth 2 -name flash.cfg`;do
            pac_dir=${flash_cfg%/*}
            export modem_config=${pac_dir##*/}

            echo_eval flash_cfg
            echo_eval modem_config

            if [ -d $Script_path/../$Project/$modem_config ];then
                #rm -rf $Script_path/../$Project/$modem_config/*.pac

                [ -d $Script_path/../ImageFiles ] && rm -rf $Script_path/../ImageFiles
                mkdir -p $Script_path/../ImageFiles
                Write_Sign
                SIGN
                cd $OUT_DIR
                system_return $? cd_OUT_DIR

                for imgs in `ls`;do
                    if [ -f $imgs ];then
                        cp -rf $imgs $Script_path/../ImageFiles
                    fi
                done

                #获取运营商 product.img
                if [ -e "$Script_path/../$Project/$modem_config/.carrier" ];then
                    . $Script_path/../$Project/$modem_config/.carrier
                    echo_eval carrier
                    if [ -e $OUT_DIR/$carrier/product.img ] && [ -e $Script_path/../ImageFiles/product.img ];then
                        cp -rfv $OUT_DIR/$carrier/product.img $Script_path/../ImageFiles/product.img
                    else
                        echo -e "\n[product.img check fail !]\n"
                        continue
                    fi
                fi
                cd -

                cd $Script_path/../ImageFiles
                system_return $? cd_ImageFiles

                cp -rf $Script_path/../$Project/$modem_config/* ./
                rm -rf ./*.pac*

                chmod a+x $Script_path/*
                perl $Script_path/mkpac.pl "${Project}_${modem_config}_tmp.pac" "flash.cfg" "FlashParam"

                if [ -e $Script_path/../ImageFiles/${Project}_${modem_config}_tmp.pac ];then
                    cp $Script_path/../ImageFiles/${Project}_${modem_config}_tmp.pac $Script_path/../$Project/$modem_config/
                    echo "${Project}_${modem_config}_tmp.pac [PASS]">>$Script_path/../build_pac.log
                    echo -e "\n\n${Project}_${modem_config}_tmp.pac [PASS]\n\n"
                else
                    echo "${Project}_${modem_config}_tmp.pac [FAIL]">>$Script_path/../build_pac.log
                    echo -e "\n\n${Project}_${modem_config}_tmp.pac [FAIL]\n\n"
                fi
            else
                echo "${Project}_${modem_config}_tmp.pac [FAIL]">>$Script_path/../build_pac.log
                echo -e "\n\n[don't $Script_path/../$Project/$modem_config exist!]\n\n"
            fi
        done
    fi
}

function Write_Sign(){
    i=0
    while read line ;do
        modem_name=${line#*@}
        modem_key=${line%%=*}
        echo_eval modem_name
        echo_eval modem_key
        modem_params_key[i]=$modem_key
        modem_params_name[i]=$modem_name
        if [[ "$modem_key" == "DFS" ]];then
            if [[ "$modem_name" =~ "-sign" ]];then
                modem_m_1=${modem_name%-*}
                modem_m_2=${modem_name##*.}
                modem_m=$modem_m_1"."$modem_m_2
            else
                modem_m=$modem_name
            fi
            DFS_URL=(`find $Modem_path -name $modem_m`)
            echo "DFS_URL:${DFS_URL[@]}"
            if [[ "${#DFS_URL[@]}" != "0" ]];then
                modem_params_name[i]=${DFS_URL[0]}
            fi
        fi
        let i++
    done < $Script_path/../$Project/$modem_config/.sign
    
    length=${#modem_params_key[@]}
    for (( i=0; i<=$length; i++ ))
    do
        param_key=${modem_params_key[i]}
        param_name=${modem_params_name[i]}
        echo "$param_name"
        if [[ "$param_name" =~ "-sign" ]];then
            modem_m_1=${param_name%-*}
            modem_m_2=${param_name##*.}
            modem_m=$modem_m_1"."$modem_m_2
        else
            modem_m=$param_name
        fi
        if [[ $param_key = "DSP_GSM" ]] || [[ $param_key = "DSP_LTE_GGE" ]] || [[ $param_key = "DSP_WLTE_GGE" ]] || [[ $param_key = "DSP_TDLTE_TD" ]]; then
            DSP_GMS_URL=(`find $Modem_path -name "*_DM_*.bin"`)
            echo "DSP_GMS_URL:${DSP_GMS_URL[@]}"
            if [[ "${#DSP_GMS_URL[@]}" != "0" ]];then
                DSP_GMS_URL_TMP=${DSP_GMS_URL[0]}
                modem_params_name[i]=$DSP_GMS_URL_TMP
#                export modem_common_url=${DSP_GMS_URL_TMP%/*}
#                echo_eval modem_common_url
            else
                echo "=======not find DSP GSM modem======"
                exit 1
            fi
        fi
    done

#
#    if [ -d $modem_common_url ];then
#        modem_common_url_tmp=${modem_common_url##*/}
#        if [[ "$modem_common_url_tmp" =~ "GSM_DSP" ]];then
#            modem_common_url=${modem_common_url%/*}
#        fi
#    else
#        echo -e "\n##### modem url $modem_common_url not find##########"
#        echo "[Write_Sign]${Project}_${modem_config}_tmp.pac [FAIL]">>$Script_path/../build_pac.log
#        exit 1
#    fi
    for (( i=0; i<=$length; i++ ))
    do
        param_key=${modem_params_key[i]}
        param_name=${modem_params_name[i]}
        echo "$param_name"
        if [[ "$param_name" =~ "-sign" ]];then
            modem_m_1=${param_name%-*}
            modem_m_2=${param_name##*.}
            modem_m=$modem_m_1"."$modem_m_2
        else
            modem_m=$param_name
        fi
        case $param_key in
            'Modem_W'|'Modem_LTE'|'Modem_WLTE'|'Modem_TDLTE')
                MODEM_URL=(`find $Modem_path  -name "*.dat"`)
                echo "MODEM_URL:${MODEM_URL[@]}"
                if [[ "${#MODEM_URL[@]}" != "0" ]];then
                    MODEM_URL=${MODEM_URL[0]}
                    if [[ $modem_m =~ ".dat" ]];then
                        modem_params_name[i]=$MODEM_URL
                    elif [[ $modem_m =~ ".bin" ]];then
                        modem_t_1=${MODEM_URL%.*}
                        modem_params_name[i]=$modem_t_1".bin"
                    fi
                else
                    echo "##########[not find Modem]###########"
                    exit 1
                fi
            ;;
            'DSP_LTE_LTE'|'DSP_WLTE_LTE'|'DSP_TDLTE_LTE')
                DSP_LTE_URL=(`find $Modem_path -name "*LTEA*.bin"`)
                echo "DSP_LTE_URL:${DSP_LTE_URL[@]}"
                if [[ "${#DSP_LTE_URL[@]}" != "0" ]];then
                    DSP_LTE_URL=${DSP_LTE_URL[0]}
                    modem_params_name[i]=$DSP_LTE_URL
                fi
            ;;
            'DSP_LTE_AG')
                DSP_AG_URL=(`find $Modem_path -name "*AGCP*.bin"`)
                echo "DSP_AG_URL:${DSP_AG_URL[@]}"
                if [[ "${#DSP_AG_URL[@]}" != "0" ]];then
                    DSP_AG_URL=${DSP_AG_URL[0]}
                    modem_params_name[i]=$DSP_AG_URL
                fi
            ;;
            'DSP_LTE_CD'|'DSP_LTE_CDMA')
                DSP_DSP_LTE_CDMA_URL=(`find $Modem_path -name "*CDMA*.bin"`)
                echo "DSP_DSP_LTE_CDMA_URL:${DSP_DSP_LTE_CDMA_URL[@]}"
                if [[ "${#DSP_DSP_LTE_CDMA_URL[@]}" != "0" ]];then
                    DSP_DSP_LTE_CDMA_URL=${DSP_DSP_LTE_CDMA_URL[0]}
                    modem_params_name[i]=$DSP_DSP_LTE_CDMA_URL
                fi
            ;;
            *)
            #nv
            
                if [[ $modem_m =~ "deltanv" ]];then
                    DELTANV_URL=(`find $Modem_path -name "*_deltanv*.bin"`)
                    if [[ "${#DELTANV_URL[@]}" != "0" ]];then
                        modem_params_name[i]=${DELTANV_URL[0]}
                    else
                        DELTANV_URL_1=(`find $Modem_path/../  -name "*_deltanv*.bin"`)
                        if [[ "${#DELTANV_URL_1[@]}" != "0" ]];then
                            DELTANV_URL_TMP=${DELTANV_URL_1[0]}
                            echo_eval DELTANV_URL_TMP
                            modem_params_name[i]=$DELTANV_URL_TMP
                        fi
                    fi
                fi
                
                if [[ $modem_m =~ "nvitem" ]];then
                    NV_URL=(`find $Modem_path -name "*_nvitem*.bin"`)
                    if [[ "${#NV_URL[@]}" != "0" ]];then
                        modem_params_name[i]=${NV_URL[0]}
                    else
                         NV_URL_1=(`find $Modem_path/../  -name "*_nvitem*.bin"`)
                        if [[ "${#NV_URL_1[@]}" != "0" ]];then
                            NV_URL_TMP=${NV_URL_1[0]}
                            echo_eval NV_URL_TMP
                            modem_params_name[i]=$NV_URL_TMP
                        fi
                    fi
                fi
        ;;
        esac
    done
    
    echo_eval modem_params_key
    echo_eval modem_params_name
    
    if [ -e $Script_path/../$Project/$modem_config/.sign_tmp ];then
        rm -rf $Script_path/../$Project/$modem_config/.sign_tmp
    fi
    
    for (( i=0; i<$length; i++ ))
    do
        modem_name=${modem_params_name[i]}
        modem_key=${modem_params_key[i]}
        
        echo "$modem_key=$modem_name">>$Script_path/../$Project/$modem_config/.sign_tmp
    done
    
    if [ -e $Script_path/../$Project/$modem_config/.sign ];then
        rm -rf $Script_path/../$Project/$modem_config/.sign
        mv $Script_path/../$Project/$modem_config/.sign_tmp $Script_path/../$Project/$modem_config/.sign
    fi
    
}

function SIGN(){
    ####签名
    if [ -e $Script_path/../$Project/$modem_config/.cfg_check ];then
        rm -rf $Script_path/../$Project/$modem_config/.cfg_check
    fi

    TARGET_BOARD=`find $code_path/out/target/product -maxdepth 2 -name "*.xml"|tail -n 1|awk -F ".xml" '{print$1}'|awk -F "/" '{print$(NF-1)}'`
    echo_eval TARGET_BOARD

    if [[ "${#TARGET_BOARD[@]}" == "1" ]] && [ -d $code_path/out/target/product/$TARGET_BOARD ];then
        OUT_DIR="$code_path/out/target/product/$TARGET_BOARD"
        echo_eval OUT_DIR
    else
        echo -e "\n[ out dir find fail !]\n"
        echo "${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
        exit 1
    fi

    if [ -e $OUT_DIR/${TARGET_BOARD}.xml ];then
        product_xml=$OUT_DIR/${TARGET_BOARD}.xml
        PRODUCT_XML=" -c $product_xml"
        PAC_CONFILE=$product_xml
        echo_eval product_xml
    elif [ -e $OUT_DIR/${TARGET_BOARD%_*}.xml ];then
        product_xml=$OUT_DIR/${TARGET_BOARD%_*}.xml
        PRODUCT_XML=" -c $product_xml"
        PAC_CONFILE=$product_xml
        echo_eval product_xml
    elif [ -e $OUT_DIR/sp9832e_1h10.xml ];then
        product_xml=$OUT_DIR/sp9832e_1h10.xml
        PRODUCT_XML=" -c $product_xml"
        PAC_CONFILE=$product_xml
        echo_eval product_xml
    else
        product_xml_tmp=`find $code_path/out/target/product -maxdepth 2 -name "*.xml"`
        echo_eval product_xml_tmp

        if [[ "${#product_xml_tmp[@]}" == "1" ]] && [ -e $product_xml_tmp ];then
            PRODUCT_XML=" -c $product_xml_tmp"
            PAC_CONFILE=$product_xml_tmp
            echo_eval product_xml_tmp        
        else
            for item in $product_xml_tmp;do
                echo "item:$item"
                if [[ "$item" =~ "verified" ]];then
                    continue
                else
                    PRODUCT_XML=" -c $item"
                    PAC_CONFILE=$item
                    echo_eval item 
                fi
            done

            if [ ! -e $PAC_CONFILE ];then
                echo -e "\n[ out dir .xml find fail !]\n"
                echo "${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
                exit 1
            fi
        fi
    fi

    while read line ;do
        image=${line#*=}
        image_key=${line%%=*}
        echo_eval image_key
        echo_eval image
        case $image_key in
            'Modem_W'|'Modem_LTE'|'Modem_WLTE'|'Modem_TDLTE')
                #-m
                MODEM_MODEM=" -m $image"
                
                MODEM_MODEM_IMAGE=$(getImageName $image)
                echo "$image_key=$MODEM_MODEM_IMAGE">>$Script_path/../$Project/$modem_config/.cfg_check
            ;;
            'DSP_LTE_LTE'|'DSP_WLTE_LTE'|'DSP_TDLTE_LTE')
                #-l
                MODEM_DSP=" -l $image"
                
                MODEM_DSP_IMAGE=$(getImageName $image)
                echo "$image_key=$MODEM_DSP_IMAGE">>$Script_path/../$Project/$modem_config/.cfg_check
            ;;
            'DSP_GSM'|'DSP_LTE_GGE'|'DSP_WLTE_GGE'|'DSP_TDLTE_TD')
                #-g
                MODEM_G_DSP=" -g $image"
                
                MODEM_G_DSP_IMAGE=$(getImageName $image)
                echo "$image_key=$MODEM_G_DSP_IMAGE">>$Script_path/../$Project/$modem_config/.cfg_check
            ;;
            'DSP_LTE_AG')
                #-a
                MODEM_DSP_AG=" -a $image"
                
                MODEM_DSP_AG_IMAGE=$(getImageName $image)
                echo "$image_key=$MODEM_DSP_AG_IMAGE">>$Script_path/../$Project/$modem_config/.cfg_check
            ;;
            'DFS')
                #-d
                MODEM_DFS=" -d $image"
                
                MODEM_DFS_IMAGE=$(getImageName $image)
                echo "$image_key=$MODEM_DFS_IMAGE">>$Script_path/../$Project/$modem_config/.cfg_check
            ;;
            'DSP_LTE_CDMA'|'DSP_LTE_CD')
                #-x
                MODEM_DSP_LTE_CDMA=" -x $image"

                MODEM_DSP_LTE_CDMA_IMAGE=$(getImageName $image)
                echo "$image_key=$MODEM_DSP_LTE_CDMA_IMAGE">>$Script_path/../$Project/$modem_config/.cfg_check
            ;;
            *)
                #nv
                if [[ "$image" =~ "nvitem" ]] || [[ "$image" =~ "deltanv" ]];then
                    if [ -e $image ];then
                        echo "copy $image"
                        cp -rf $image $Script_path/../ImageFiles
                    
                        NV_IMAGE=$(getImageName $image)
                        echo "$image_key=$NV_IMAGE">>$Script_path/../$Project/$modem_config/.cfg_check
                    else
                        echo "[don't exist $image]"
                        echo "[SIGN] ${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
                        exit 1
                    fi
                fi
        ;;
        esac
    done < $Script_path/../$Project/$modem_config/.sign
    
    sign_param=($MODEM_MODEM_IMAGE $MODEM_DSP_IMAGE $MODEM_G_DSP_IMAGE $MODEM_DSP_AG_IMAGE $MODEM_DFS_IMAGE $MODEM_DSP_LTE_CDMA_IMAGE)
    
    if [ -d $Script_path/../$Project/$modem_config/Sign_Check ];then
        rm -rf $Script_path/../$Project/$modem_config/Sign_Check
    fi
    mkdir -p $Script_path/../$Project/$modem_config/Sign_Check
    
    cd $Script_path
    chmod a+x ./avb_sign_modem_v3.sh
    ./avb_sign_modem_v3.sh $PRODUCT_XML$MODEM_MODEM$MODEM_DSP$MODEM_G_DSP$MODEM_DSP_AG$MODEM_DFS$MODEM_DSP_LTE_CDMA
    ##############################################################################
    SPRD_SECURE_FILE=${PAC_CONFILE%/*}/PRODUCT_SECURE_BOOT_SPRD && echo_eval SPRD_SECURE_FILE
    if [ -f "$SPRD_SECURE_FILE" ]; then
        echo -e "[==find PRODUCT_SECURE_BOOT_SPRD==]"
        #判断签名是否成功
        echo_eval sign_param
        length=${#sign_param[@]}
        for (( i=0; i<$length; i++ ));do
            image=${sign_param[i]}
            echo_eval image
            if [ ! -e $Script_path/../$Project/$modem_config/Sign_Check/$image.check ];then
                echo "Sign @$image fail, exit"
                echo "[SIGN] ${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
                exit 1
            fi
        done
        #拷贝已签名bin文件和
        copy_sign_image
    else
        echo -e "[==not find PRODUCT_SECURE_BOOT_SPRD==]"
        copy_modem_image
    fi
    rm -rf $Script_path/../$Project/$modem_config/Sign_Check
    ##############################################################################
    #检查.cfg文件等
    check_cfg_image
    rm -rf $Script_path/../$Project/$modem_config/.cfg_check
    ##############################################################################
}

function copy_modem_image(){
    #拷贝modem bin到ImageFile文件
    if [ ! -d $Script_path/../ImageFiles ];then
        echo "[not find ImageFiles,exit===]"
        echo "[SIGN] ${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
        exit 1
    fi
    echo -e "###########[copy modem bin to ImageFile]#################"
    while read line ;do
        image=${line#*=}
        image_key=${line%%=*}
        echo_eval image_key
        echo_eval image
        cp $image  $Script_path/../ImageFiles -rfv
        system_return $? $image
    done < $Script_path/../$Project/$modem_config/.sign
}

function copy_sign_image(){
    echo "start copy_sign_image"
    if [ ! -d $code_path/sign_modem ];then
        echo "[not find sign_modem,exit===]"
        echo "[SIGN] ${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
        exit 1
    fi
    if [ ! -d $Script_path/../ImageFiles ];then
        echo "[not find ImageFiles,exit===]"
        echo "[SIGN] ${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
        exit 1
    fi
    sign_tag=(`find $code_path/sign_modem -name "*-sign.*"`)
    echo "sign_tag:$sign_tag"
    if [[ "${#sign_tag[@]}" == "0" ]];then
        cp -rf $code_path/sign_modem/* $Script_path/../ImageFiles
    else
        for sign_image in `ls $code_path/sign_modem`;do
            if [[ "$sign_image" =~ "-sign" ]];then
                echo "copy $sign_image"
                old_image_1=${sign_image%-*}
                old_image_2=${sign_image##*.}
                old_image=$old_image_1"."$old_image_2
                sed -i "s/$old_image/$sign_image/g" $Script_path/../$Project/$modem_config/.cfg_check
                cp -rf $code_path/sign_modem/$sign_image $Script_path/../ImageFiles
                system_return $? $image
            else
                echo "$sign_image not sign,do nothing"
            fi
        done
    fi
}

function check_cfg_image(){
    echo "start check_cfg_image"
    while read line ;do
        image=${line#*=}
        image_key=${line%%=*}
        echo_eval image_key
        echo_eval image
        if [ -e $Script_path/../ImageFiles/$image ];then
            for cfg_img in `grep "$image_key" $Script_path/../$Project/$modem_config/flash.cfg`;do
                if [[ "${cfg_img%%=*}" == "$image_key" ]];then
                    old_cfg=${cfg_img#*@}
                    sed -i "s/$old_cfg/$image/g" $Script_path/../$Project/$modem_config/flash.cfg
                fi
            done
        else
            echo "$image not find in $Script_path/../ImageFiles"
            echo "[SIGN] ${Project}_${modem_config}.pac [FAIL]">>$Script_path/../build_pac.log
            exit 1
        fi
    done < $Script_path/../$Project/$modem_config/.cfg_check
}

function getImageName(){
    local imagename=$1
    echo ${imagename##*/}
}

function Modem_Copy(){
     ###########拷贝modem bin####################
    MODEM_BIN_PATH="device/sprd/$BOARD/modem_bins"
    echo -e "MODEM_BIN_PATH is the --->device/sprd/$BOARD/modem_bins"
    echo -e "cp modem ....."
    if [ ! -d $MODEM_BIN_PATH ];then
        mkdir -p $MODEM_BIN_PATH
    fi
    rm -rf $MODEM_BIN_PATH/*

    while read line ;do
        if [ -z "$line" ];then
            continue
        fi
        modem_name=${line#*=}
        modem_key=${line%%=*}
        echo_eval modem_name
        echo_eval modem_key
        ota_flag='lte'
        if [[ "$modem_key" == "Modem_W" ]];then
            ota_flag='w'
            break
        fi
    done < $Script_path/../$Project/$modem_config/.sign
    
    echo_eval ota_flag
    while read line ;do
        if [ -z "$line" ];then
            continue
        fi
        image=${line#*=}
        image_key=${line%%=*}
        echo_eval image_key
        echo_eval image
        case $image_key in
            'Modem_W'|'Modem_LTE'|'Modem_WLTE'|'Modem_TDLTE')
                #-m
                if [[ "$ota_flag" == "lte" ]];then
                    cp $image $MODEM_BIN_PATH/ltemodem.bin
                else
                    cp $image $MODEM_BIN_PATH/wmodem.bin
                fi
            ;;
            'DSP_LTE_LTE'|'DSP_WLTE_LTE'|'DSP_TDLTE_LTE')
                #-l
                if [[ "$ota_flag" == "lte" ]];then
                    cp $image $MODEM_BIN_PATH/ltedsp.bin
                else
                    cp $image $MODEM_BIN_PATH/wdsp.bin
                fi
            ;;
            'DSP_GSM'|'DSP_LTE_GGE'|'DSP_WLTE_GGE'|'DSP_TDLTE_TD')
                #-g
                if [[ "$ota_flag" == "lte" ]];then
                    cp $image $MODEM_BIN_PATH/ltegdsp.bin
                else
                    cp $image $MODEM_BIN_PATH/wgdsp.bin
                fi
            ;;
            'DSP_LTE_AG')
                #-a
                if [[ "$ota_flag" == "lte" ]];then
                    cp $image $MODEM_BIN_PATH/lteagdsp.bin
                else
                    cp $image $MODEM_BIN_PATH/wagdsp.bin
                fi
            ;;
            'DFS')
                #-d
                cp $image $MODEM_BIN_PATH/pmsys.bin
            ;;
            'DSP_LTE_CDMA'|'DSP_LTE_CD')
                cp $image $MODEM_BIN_PATH/ltecdsp.bin
            ;;
            'WARM_WLTE')
                cp $image $MODEM_BIN_PATH/ltewarm.bin
            ;;
            *)
                #nv
                if [[ "$image" =~ "nvitem" ]];then
                    if [[ "$ota_flag" == "lte" ]];then
                        if [[ "$image" =~ "sharkl2" ]];then
                            if [[ "$image" =~ "AL_" ]];then
                                cp $image $MODEM_BIN_PATH/ltenvitem_AL.bin
                            elif [[ "$image" =~ "A_" ]];then
                                cp $image $MODEM_BIN_PATH/ltenvitem_A.bin
                            fi
                        else
                            cp $image $MODEM_BIN_PATH/ltenvitem.bin
                        fi
                    else
                        cp $image $MODEM_BIN_PATH/wnvitem.bin
                    fi
                fi

                if [[ "$image" =~ "deltanv" ]];then
                    if [[ "$ota_flag" == "lte" ]];then
                        cp $image $MODEM_BIN_PATH/ltedeltanv.bin
                    else
                        cp $image $MODEM_BIN_PATH/wdeltanv.bin
                    fi
                fi
        ;;
        esac
    done < $Script_path/../$Project/$modem_config/.sign

    while read line ;do
        if [ -z "$line" ];then
            continue
        fi
        modem_name=${line#*@}
        modem_key=${line%%=*}
        echo_eval modem_key
        case $modem_key in
            'GPS_BD')
                cp $Script_path/../$Project/$modem_config/$modem_name $MODEM_BIN_PATH/gnssbdmodem.bin
            ;;
            'GPS_GL'|'Modem_GNSS')
                cp $Script_path/../$Project/$modem_config/$modem_name $MODEM_BIN_PATH/gnssmodem.bin
            ;;
            'Modem_WCN')
                cp $Script_path/../$Project/$modem_config/$modem_name $MODEM_BIN_PATH/wcnmodem.bin
            ;;
            'FDL_WCN')
                cp $Script_path/../$Project/$modem_config/$modem_name $MODEM_BIN_PATH/wcnfdl.bin
            ;;
            *)
        ;;
        esac
    done < $Script_path/../$Project/$modem_config/flash.cfg

    if [ -e $MODEM_BIN_PATH/ltenvitem_AL.bin ] && [ -e $MODEM_BIN_PATH/ltenvitem_A.bin ];then
        mv $MODEM_BIN_PATH/ltenvitem_AL.bin  $MODEM_BIN_PATH/ltenvitem_navajo.bin
        mv $MODEM_BIN_PATH/ltenvitem_A.bin  $MODEM_BIN_PATH/ltenvitem_boca.bin
    elif [ ! -e $MODEM_BIN_PATH/ltenvitem_AL.bin ] && [ -e $MODEM_BIN_PATH/ltenvitem_A.bin ];then
        mv $MODEM_BIN_PATH/ltenvitem_A.bin  $MODEM_BIN_PATH/ltenvitem.bin
    elif [ -e $MODEM_BIN_PATH/ltenvitem_AL.bin ] && [ ! -e $MODEM_BIN_PATH/ltenvitem_A.bin ];then
        mv $MODEM_BIN_PATH/ltenvitem_AL.bin  $MODEM_BIN_PATH/ltenvitem.bin
    fi
}

function MAKEOTA(){
    #编译ota
    cd $code_path
    system_return $? cd_code_path
    TARGET_BOARD=`find $code_path/out/target/product -maxdepth 2 -name "*.xml"|tail -n 1|awk -F ".xml" '{print$1}'|awk -F "/" '{print$(NF-1)}'`
	echo_eval TARGET_BOARD

	if [[ "${#TARGET_BOARD[@]}" == "1" ]] && [ -d $code_path/out/target/product/$TARGET_BOARD ];then
		OUT_DIR="$code_path/out/target/product/$TARGET_BOARD"
		echo_eval OUT_DIR
	else
		echo -e "\n[ out dir find fail !]\n"
		exit 1
	fi

    if [ ! -d $OUT_DIR/OTA_${Project_ver}_${Project_vlx} ];then
        mkdir -p $OUT_DIR/OTA_${Project_ver}_${Project_vlx}
    fi
    rm -rf $OUT_DIR/OTA_${Project_ver}_${Project_vlx}/*
############################################################################################################
#以下 "#" 之间是 unisoc 编译验证自动设置环境变更使用，客户需要依据客户环境来设置环境变更。
    if [ -e $Script_path/Build_Path.sh ];then
        chmod a+x $Script_path/Build_Path.sh
        fromdos $Script_path/Build_Path.sh
        source $Script_path/Build_Path.sh $code_path
    fi
############################################################################################################
    BOARD=$(find device/sprd -name "$Project_name.mk"|xargs dirname|cut -c13-)
    CPU_COUNT=$(cat /proc/cpuinfo | grep -i 'processor' | wc -l)
    PLATFORM_SDK_VERSION=$(grep "PLATFORM_SDK_VERSION :="  ./build/core/version_defaults.mk | awk -F "= " '{print $NF}')
    
    if [ $PLATFORM_SDK_VERSION -gt 27 ];then
        source build/envsetup.sh
        choosecombo 1 $Project_name $Project_ver $Project_vlx
    else
        source build/envsetup.sh
        choosecombo 1 $Project_name $Project_ver
    fi

    for flash_cfg in `cd $Script_path/../$Project && find -maxdepth 2 -name flash.cfg`;do
        cd $code_path
        pac_dir=${flash_cfg%/*}
        export modem_config=${pac_dir##*/}
        echo_eval flash_cfg
        echo_eval modem_config
        Modem_Copy

        if [ -e "$Script_path/../$Project/$modem_config/.carrier" ];then
            . $Script_path/../$Project/$modem_config/.carrier
            echo_eval carrier
            if [ -e $OUT_DIR/$carrier/product.img ] && [ -e $OUT_DIR/product.img ];then
                rm $OUT_DIR/product.img -rfv
                cp -lr $OUT_DIR/$carrier/product.img  $OUT_DIR/
                system_return $? cd_carrier_product
            else
                echo -e "####[ 没有编译运营商信息 ]########"
                continue
            fi
            
        fi
        make otapackage -j$CPU_COUNT
        cd $OUT_DIR
        otazip=$(ls ${Project_name}-ota*.zip)
        if [ "$otazip" ];then
            mv -v  $otazip $OUT_DIR/OTA_${Project_ver}_${Project_vlx}/${Project_name}-ota-${modem_config}.zip
            system_return $? mv_ota_file
        else
            echo -e "\n###[ error! not find ota file ]########\n"
            exit 1
        fi
        ota_upgrade_file=$(ls obj/PACKAGING/target_files_intermediates/${Project_name}-target_files*.zip)
        if  [ "$ota_upgrade_file" ];then
            mv -v $ota_upgrade_file  $OUT_DIR/OTA_${Project_ver}_${Project_vlx}/${Project_name}-target_files-${modem_config}.zip
            system_return $? mv_target_file
        else
            echo -e "\n###[error! not find target file ]########\n"
            exit 1
        fi
        cd -
    done
    cd -
}

#export Script_path=`pwd`	&& echo_eval Script_path
#export code_path=`cd ${Script_path}/../../../../.. && pwd` && echo_eval code_path
#export carrier_param=""
#export Modem_path=`cd ${Script_path}/../Modem && pwd` && echo_eval Modem_path

while getopts ":a:b:c:p:t:m:" opt;do
	case $opt in
		a)
			export Project=$OPTARG
			echo -e "parmerter -a:$Project"
			Project_Split $Project
		;;
		b)
			export build_pac=$OPTARG
			echo -e "parmerter -b:$build_pac"
		;;
		p)
			export production_out=$OPTARG
			echo -e "parmerter -p:$production_out"
		;;
		t)
			export root_path=$OPTARG
			echo -e "parmerter -t:$root_path"
		;;
		c)
			export carriers=$OPTARG
			export carriers=`echo "$carriers"|tr ' ;|' ','`
			export carrier_param="--product_carrier $carriers"
			echo -e "parmerter -c:$carriers"
		;;
        m)
			export modem_config=$OPTARG
			echo -e "parmerter -m:$modem_config"
		;;
		\?)
			echo -e "\n[unknow ERROR!]\n"
			exit 1;;
	esac
done

case $build_pac in
	'all'|'ALL')
		BUILD && PAC
	;;
	'bota'|'BOTA')
	    BUILD && MAKEOTA
	;;
	'build'|'BUILD')
		BUILD
	;;
	'pac'|'PAC')
		PAC
	;;
    'ota'|'OTA')
        MAKEOTA
    ;;
	*)
		echo -e "\n[参数 -b 错误!]\n"
	;;
esac

