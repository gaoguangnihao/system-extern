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
	echo "Command: ./kaios_generator_scert_file.sh out_path key_path"
	echo '*****************************************'
}

## need three keys one if root_prvk same as cert1 and efuse blow
## primary_dbg_prvk and secondary_dbg_key 
CURDIR="`pwd`"/"`dirname $0`"

echo "******************************************"
echo "********Generator scert file begin********"
echo "******************************************"
echo $CURDIR
echo "......"
sleep 3
DESTPATH=$1
keypath=$2

if [ $# -lt 2 ];then
	echo "############WORNG PARG ###########"
	usage
	echo "############WORNG PARG ###########"
	exit 128
fi
# config settings/sctrlcert/scc_key.ini
# config scc_primary_dbg.ini
# config scc_seconday_dbg.ini soc_id (can get from GLB__XXX.log)

# this use by root private key owner
primary_key="/primary_dbg_prvk.pem"
root_key="/root_prvk.pem"
second_key="/secondary_dbg_prvk.pem"



#config scc_key.ini
sed -i "s#^imgkey =.*#imgkey = \"$keypath$primary_key\"#" $CURDIR/settings/sctrlcert/scc_key.ini
sed -i "s#^rootkey =.*#rootkey = \"$keypath$root_key\"#" $CURDIR/settings/sctrlcert/scc_key.ini


#config scc_primary_dbg.ini

sed -i "s#^primary_dbg_prvk =.*#primary_dbg_prvk = \"$keypath$primary_key\"#" $CURDIR/settings/sctrlcert/scc_primary_dbg.ini
sed -i "s#^secondary_dbg_prvk =.*#secondary_dbg_prvk = \"$keypath$second_key\"#" $CURDIR/settings/sctrlcert/scc_primary_dbg.ini

#config scc_secondary_dbg.ini
sed -i "s#^secondary_dbg_prvk =.*#secondary_dbg_prvk = \"$keypath$second_key\"#" $CURDIR/settings/sctrlcert/scc_secondary_dbg.ini


python $CURDIR/sctrlcert.py -i $CURDIR/settings/sctrlcert/scc_key.ini -k $CURDIR/out/sctrlcert/key_cert.bin -g $CURDIR/settings/sctrlcert/scc_gfh_config_cert_chain.ini -q $CURDIR/settings/sctrlcert/scc_primary_dbg.ini -p $CURDIR/out/sctrlcert/primary_dbg_cert.bin -s $CURDIR/settings/sctrlcert/scc_secondary_dbg.ini $CURDIR/out/sctrlcert/scc_sv5.cert

if [ $? -ne 0 ] ;then
	echo -e "error !!! scc_key generator"	
	exit 129
fi

#copy key_cert.bin and primary_dbg_cert.bin to prebuilt/sctrlcert
cp $CURDIR/out/sctrlcert/key_cert.bin $CURDIR/prebuilt/sctrlcert
cp $CURDIR/out/sctrlcert/primary_dbg_cert.bin $CURDIR/prebuilt/sctrlcert

#below use by service center

python $CURDIR/sctrlcert.py -k $CURDIR/prebuilt/sctrlcert/key_cert.bin -g $CURDIR/settings/sctrlcert/scc_gfh_config_cert_chain.ini -p $CURDIR/prebuilt/sctrlcert/primary_dbg_cert.bin -s $CURDIR/settings/sctrlcert/scc_secondary_dbg.ini $CURDIR/out/sctrlcert/scc_sv5.cert

if [ $? -ne 0 ] ;then
	echo -e "error !!! scc_key.bin generator"	
	exit 129
fi

cp $CURDIR/out/sctrlcert/scc_sv5.cert $DESTPATH

echo "******************************************"
echo "********Generator scert file end**********"
echo "******************************************"
