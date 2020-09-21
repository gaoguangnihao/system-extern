#!/bin/bash

#######################################
# Initialize variables
#######################################

#######################################
# Specify 
#######################################

function usage() {
	#######################################
	# Dump usage howto
	#######################################
	echo '*****************************************'
	echo "Generator ScertFile ..."
	echo '*****************************************'
	echo "Command: ./kaios_generator_auth_file.sh out_path key_path"
	echo '*****************************************'
}

## need three keys one if root_prvk same as cert1 and efuse blow
## primary_dbg_prvk and secondary_dbg_key 
CURDIR="`pwd`"/"`dirname $0`"

echo "******************************************"
echo "********Generator auth file begin*********"
echo "******************************************"
echo "......"
sleep 3
echo $CURDIR

DESTPATH=$1
keypath=$2
authname=$3

if [ $# -lt 3 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
fi

# this use by root private key owner
# FIXED-ME sla/da key use same with root
img_key="/img_prvk.pem"
root_key="/root_prvk.pem"
sla_key="/sla_prvk.pem"
da_key="/da_prvk.pem"

#config toolauth_key.ini
sed -i "s#^imgkey =.*#imgkey = \"$keypath$img_key\"#" $CURDIR/settings/toolauth/toolauth_key.ini
sed -i "s#^rootkey =.*#rootkey = \"$keypath$root_key\"#" $CURDIR/settings/toolauth/toolauth_key.ini

#config toolauth_gfh_config_pss.ini

sed -i "s#^sla_public_key =.*#sla_public_key = \"$keypath$sla_key\"#" $CURDIR/settings/toolauth/toolauth_gfh_config_pss.ini
sed -i "s#^daa_public_key =.*#daa_public_key = \"$keypath$da_key\"#" $CURDIR/settings/toolauth/toolauth_gfh_config_pss.ini

#config 

sed -i "s#^load_region0_key =.*#load_region0_key = \"$keypath$img_key\"#" $CURDIR/settings/toolauth/bbchips_pss.ini
sed -i "s#^load_region1_key =.*#load_region1_key = \"$keypath$da_key\"#" $CURDIR/settings/toolauth/bbchips_pss.ini
sed -i "s#^load_region2_key =.*#load_region2_key = \"$keypath$da_key\"#" $CURDIR/settings/toolauth/bbchips_pss.ini


python $CURDIR/toolauth.py -i $CURDIR/settings/toolauth/toolauth_key.ini -g $CURDIR/settings/toolauth/toolauth_gfh_config_pss.ini $CURDIR/out/toolauth/auth_sv5.auth

if [ $? -ne 0 ] ;then
	echo -e "error !!! toolauth_key generator"	
	exit 129
fi

cp $CURDIR/out/toolauth/auth_sv5.auth $DESTPATH/auth_${authname}_sv5.auth

echo "******************************************"
echo "********Generator auth file end***********"
echo "******************************************"

