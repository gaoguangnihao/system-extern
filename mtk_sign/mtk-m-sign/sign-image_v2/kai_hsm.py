"""
comments to explain 
"""
import filecmp
import os
import traceback
import paramiko
import lib.cert

class KaiServer(object):
    """
    Parameter for KaiServer
    """
    def __init__(self):
        # you can add parameter required by your HSM here
        self.hostname = '172.31.16.185'
        self.port = 22
        self.username = 'kai'
        self.password = 'Aa123456'
        self.flag = False
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

def sshclient_to_Kai(data, key, padding, sig):
    """
    sign data with Kai-server
    """
    hsm_param_obj = KaiServer()
    key_table = create_key_table()
    hsm_param_obj.m_prvk = query_key_table(key_table, key)
    if hsm_param_obj.m_prvk is None:
        print 'not valid HSM parameter'
        return -1


    server_param_obj = KaiServer()
    if server_param_obj.flag is True:
        print ('not Support Kai-server sign')
        return -1

    print ("\033[1;33m kai_hsm.py ======================== \033[0m")

    
    # creat ssh object 
    #ssh = paramiko.SSHClient()
    #allow connect computer without know_host files
    #ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    #ssh.connect(server_param_obj.hostname,server_param_obj.port,server_param_obj.username,server_param_obj.password)

    #exec commond 

    #stdin, stdout, stderr = ssh.exec_command('ls')


    #result got 

    #result = stdout.read()

    #print ("\033[1;36m result frome kaios server: " + result +'\033[0m')
    #close connect
    #ssh.close()
    #transport = paramiko.Transport((server_param_obj.hostname, server_param_obj.port))   
    #use password
    #transport.connect(username = server_param_obj.username, password = server_param_obj.password)   
    #use prv key 
    #private = paramiko.RSAKey.from_private_key_file('/Users/root/.ssh/id_rsa')
    #transport.connect(username=server_param_obj.username, pkey=private)
    #sftp = paramiko.SFTPClient.from_transport(transport)
    #datapath = '/local/tools/system-faq/system-extern/mtk-m-sign/adhui.txt'
    #print 'kai_hsm data ' + data

    #sftp.put(data ,os.path.join('/home/kai/dahui', 'tbs_cert2.der'))
    #sftp.put(key ,os.path.join('/home/kai/dahui', 'boot_pubk2.pem'))
    #sftp.put(sig ,os.path.join('/home/kai/dahui', 'tbs_cert2.sig'))

    #sftp.close()

    return 0
