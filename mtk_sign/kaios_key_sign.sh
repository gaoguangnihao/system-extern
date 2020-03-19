##########init valiable ###################
#########################################


if [ ! -n "$1" ] ;then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "Try ./kaios_key_sign.sh /home/kai-user/keys_odm/MTK_Kaios31_jpv_jio /home/kai-user/keys_odm/MTK_Kaios31_jpv_jio /home/kai-user/mtk_m_jpv /home/dhcui/mtk_m_jpv_out"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit
else
    echo "the args you input is $1 $2"

fi


CERT1_PATH=$1
CERT2_KEY_PATH=$2
INPUT_IMG_PATH=$3
OUTPUT_IMG_PATH=$4

##beging to deploy sign certs and sign the image use img_prvk.pem 

cert_generator/kaios_deploy_sign.sh $CERT1_PATH $CERT2_KEY_PATH $INPUT_IMG_PATH $OUTPUT_IMG_PATH

##sign common image done!!!



