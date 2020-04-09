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
	echo "Command: ./kaios_generator_auth_file.sh path"
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

if [ $# -lt 1 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
fi

# this use by root private key owner
# FIXED-ME sla/da key use same with root

python $CURDIR/toolauth.py -i $CURDIR/settings/toolauth/toolauth_key.ini -g $CURDIR/settings/toolauth/toolauth_gfh_config_pss.ini $CURDIR/out/toolauth/auth_sv5.auth

if [ $? -ne 0 ] ;then
	echo -e "error !!! toolauth_key generator"	
	exit 129
fi

cp $CURDIR/out/toolauth/auth_sv5.auth $DESTPATH

echo "******************************************"
echo "********Generator auth file end***********"
echo "******************************************"

