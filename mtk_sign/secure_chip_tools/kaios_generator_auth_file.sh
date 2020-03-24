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

echo "GENERATOR AUTH FILE BEGIN"

echo $CURDIR

DESTPATH=$1


# this use by root private key owner

python $CURDIR/toolauth.py -i $CURDIR/settings/toolauth/toolauth_key.ini -g $CURDIR/settings/toolauth/toolauth_gfh_config_pss.ini $CURDIR/out/toolauth/auth_sv5.auth

cp $CURDIR/out/toolauth/auth_sv5.auth $DESTPATH

echo "GENERATOR AUTH FILE END"

