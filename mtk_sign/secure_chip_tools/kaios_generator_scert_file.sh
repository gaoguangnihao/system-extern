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
	echo "Command: ./kaios_generator_scert_file.sh"
	echo '*****************************************'
}

## need three keys one if root_prvk same as cert1 and efuse blow
## primary_dbg_prvk and secondary_dbg_key 
CURDIR="`pwd`"/"`dirname $0`"

echo "GENERATOR SCERT FILE BEGIN"
echo $CURDIR
DESTPATH=$1

# config settings/sctrlcert/scc_key.ini
# config scc_primary_dbg.ini
# config scc_seconday_dbg.ini soc_id (can get from GLB__XXX.log)

# this use by root private key owner

python $CURDIR/sctrlcert.py -i $CURDIR/settings/sctrlcert/scc_key.ini -k $CURDIR/out/sctrlcert/key_cert.bin -g $CURDIR/settings/sctrlcert/scc_gfh_config_cert_chain.ini -q $CURDIR/settings/sctrlcert/scc_primary_dbg.ini -p $CURDIR/out/sctrlcert/primary_dbg_cert.bin -s $CURDIR/settings/sctrlcert/scc_secondary_dbg.ini $CURDIR/out/sctrlcert/scc_sv5.cert

#copy key_cert.bin and primary_dbg_cert.bin to prebuilt/sctrlcert
cp $CURDIR/out/sctrlcert/key_cert.bin $CURDIR/prebuilt/sctrlcert
cp $CURDIR/out/sctrlcert/primary_dbg_cert.bin $CURDIR/prebuilt/sctrlcert

#below use by service center

python $CURDIR/sctrlcert.py -k $CURDIR/prebuilt/sctrlcert/key_cert.bin -g $CURDIR/settings/sctrlcert/scc_gfh_config_cert_chain.ini -p $CURDIR/prebuilt/sctrlcert/primary_dbg_cert.bin -s $CURDIR/settings/sctrlcert/scc_secondary_dbg.ini $CURDIR/out/sctrlcert/scc_sv5.cert

cp $CURDIR/out/sctrlcert/scc_sv5.cert $DESTPATH


