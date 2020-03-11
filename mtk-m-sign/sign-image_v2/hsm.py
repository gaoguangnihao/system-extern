"""
This module is used to delegate signature generation to HSM(Hardware Security Module)
If public key is given for signing instead of private key, we'll know that
we're trying to delegate signature to HSM. Then we look up key table created
here to find HSM parameters. Here public key is used only as id for HSM
parameters and won't act as a public key.
"""
import filecmp
import os
import lib.cert
import traceback
import kai_hsm
import subprocess


class HsmParam(object):
    """
    Parameter for HSM
    """
    def __init__(self):
        # you can add parameter required by your HSM here
        self.m_prvk = None

def create_key_table():
    """
    create key table for public key to private key mapping
    """
    print ('\033[1;33m hsm.py  create_key_table \033[0m')
    prvk_list = []
    pubk_list = []
    key_database_path = os.path.join(os.path.dirname(__file__), 'hsm_test_keys')
    keys = os.listdir(key_database_path)
    key_table = {}
    for key in keys:
        key_path = os.path.join(key_database_path, key)
        if lib.cert.is_prvk(key_path):
            prvk_list.append(key_path)
        elif lib.cert.is_pubk(key_path):
            pubk_list.append(key_path)
    for pubk in pubk_list:
        for prvk in prvk_list:
            tmp_pubk = os.path.join(os.path.dirname(__file__), 'tmp_pubk.pem')
            lib.cert.prvk_to_pubk(prvk, tmp_pubk)
            if filecmp.cmp(pubk, tmp_pubk, False) is True:
                key_table[pubk] = os.path.join(key_database_path, prvk)
                os.remove(tmp_pubk)
                break
            os.remove(tmp_pubk)

    return key_table

def query_key_table(key_table, key):
    """
    get private key from public key.
    In your implementation, you should convert input public
    key to parameter passed to HSM, so HSM knows how to sign
    message. Here as an example, we search public keys in a folder
    as public key data base, and use corresponding private key
    to sign message.
    """
    print ('\033[1;33m hsm.py  query_key_table \033[0m')

    for pubk in key_table.keys():
        if filecmp.cmp(key, pubk, False) is True:
            return key_table[pubk]

    return None


def hsm_rsa_sign(data, key, padding, sig):
    """
    sign data with HSM
    """
    # note that key is pubk actually, use it as index for
    # HSM parameters such as key selection
    print "\033[1;33m hsm.py hsm_rsa_sign \033[0m"
    
    #backtrace for python print stack 

    #traceback.print_stack()
    #hsm_param_obj = HsmParam()
    #key_table = create_key_table()
    #hsm_param_obj.m_prvk = query_key_table(key_table, key)
    #if hsm_param_obj.m_prvk is None:
    #    print 'not valid HSM parameter'
    #    return -1

    print "\033[1;33m hsm.py ======================== \033[0m"
    print "\033[1;33m hsm.py HSM parameter: \033[0m"
    #print "\033[1;33m hsm.py m_prvk  =: \033[0m" + hsm_param_obj.m_prvk
    print "\033[1;33m hsm.py ======================== \033[0m"


    print "dhcui data path is " + data
    print "dhcui padding type is " + padding
    print "dhcui sig file path  is " + sig
    print "dhcui key file path is " + key 
    
    # place hsm request here -- start
    # we re-direct it to signing with private key to mimic HSM
    # data is not hashed here, you can hash data here to reduce
    # network usage

    #disable for check server status
    print "\033[1;31mBegin to call lib to sign \033[0m"
    #lib.cert.sig_gen(data, key, padding, sig)
    #print "\033[1;31m begin to connect server \003[0m"
    #kai_hsm.sshclient_to_Kai(data, key, padding, sig)
    #curl -i -X POST -F file1='@/data' -F file2='@/key' -F file3='@sig' 
    #https://test.kaiostech.com/signature?arg=1&b=1' > xxx.sig

    #os.system('curl -i -X POST -F file1='@/home/dhcui/dahui-share/mtk-m-sign/sign_in/resign/cert/boot/cert2/cert_intermediate/tbs_cert2.der' -F file2='@/local/tools/system-faq/system-extern/mtk-m-sign/sign-image_v2/../mt6739/security/cert_config/cert2_key/boot_pubk2.pem'   -F file3='@/home/dhcui/dahui-share/mtk-m-sign/sign_in/resign/cert/boot/cert2/cert_intermediate/tbs_cert2.sig' 'https://test.kaiostech.com/signature?arg=1&b=1'   > xxx.sig')
    #os.system("curl -i -X POST -F file1=%s -F file2=%s -F file3=%s 'https://test.kaiostech.com/signature?arg=%s&b=1'   > xxx.sig" % (data, key, sig,padding))
    print "\033[1;31mEnd to call lib to sign \033[0m"
    #res = subprocess.call('ls')

    #print "res " ,res
    #print "sig " + sig
    #in_hash_tmp = sig + '_hash.tmp'

    #print "sig is " + in_hash_tmp
    #lib.cert.hash_gen(data,in_hash_tmp)

    #cmd = ""
    #cmd += 'openssl pkeyutl -sign '
    #cmd += ' -in '+ in_hash_tmp
    #cmd += ' -inkey '+ hsm_param_obj.m_prvk
    #cmd += ' -out '+ sig
    #cmd += ' -pkeyopt digest:sha256'
    #cmd += ' -pkeyopt ras_padding_mode:pss'
    #cmd += ' -pkeyopt ras_pss_saltlen:32'
    #print "\033[1;32m cmd: " + cmd +'\033[0m'

    #try:
    #    subprocess.check_call(cmd,shell=True)
    #    os.remove(in_hash_tmp)
    #    return 0
    # place hsm request here -- end
    #except subprocess.CalledProcessError as e:
    #    print "ras_sign error (pss)"
    #   os.remove(in_hash_tmp)
    return 0
