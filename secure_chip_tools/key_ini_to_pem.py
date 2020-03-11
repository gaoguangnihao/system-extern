import sys
import os
import subprocess
import base64
script_folder, script_name = os.path.split(os.path.realpath(__file__))
sys.path.append(os.path.join(script_folder, "lib"))
import cert
import asn1_gen

def pem_to_der(pem_file_path, der_file_path):
    in_file = open(pem_file_path, 'r')
    in_data = ""
    while True:
        line = in_file.readline()
        if line == '':
            break
        if line[0] != '-':
            in_data = in_data + line

    out_data = base64.standard_b64decode(in_data)

    out_file = open(der_file_path, 'wb')
    out_file.write(out_data)
    out_file.close()
    return

def der_to_pem(der_file_path, pem_file_path):
	in_file = open(der_file_path, "rb")
	in_data = ""
	while True:
		byte = in_file.read(1)
		if byte == "":
			break;
		in_data = in_data + byte

	out_data = base64.standard_b64encode(in_data)
	out_file = open(pem_file_path, "w")
	out_file.write(out_data)
	out_file.close()
	return

def create_prvk_cfg(prvk, key_cfg):
	key_cfg_file = open(key_cfg, 'w')
	key_cfg_file.write("PRVK SEQUENCE ::= {\n")
	key_cfg_file.write("	VERSION INTEGER ::= 0\n")
	key_cfg_file.write("	MODULUS INTEGER ::= " + str(prvk.m_n_val) + "\n")
	key_cfg_file.write("	PUBLICEXPONENT INTEGER ::= " + str(prvk.m_e_val) + "\n")
	key_cfg_file.write("	PRIVATEXPONENT INTEGER ::= " + str(prvk.m_d_val) + "\n")
	key_cfg_file.write("	PRIME1 INTEGER ::= " + str(prvk.m_p_val) + "\n")
	key_cfg_file.write("	PRIME2 INTEGER ::= " + str(prvk.m_q_val) + "\n")
	key_cfg_file.write("	EXPONENT1 INTEGER ::= " + str(prvk.m_exp1_val) + "\n")
	key_cfg_file.write("	EXPONENT2 INTEGER ::= " + str(prvk.m_exp2_val) + "\n")
	key_cfg_file.write("	COEFFICIENT INTEGER ::= " + str(prvk.m_coeff_val) + "\n")
	key_cfg_file.write("}\n")
	key_cfg_file.close()
	return

def create_pubk_cfg(pubk, key_cfg):
	key_cfg_file = open(key_cfg, 'w')
	key_cfg_file.write("PUBK SEQUENCE ::= {\n")
	key_cfg_file.write("    OID SEQUENCE ::= {\n")
	key_cfg_file.write("        oid OID ::= 1.2.840.113549.1.1.1\n")
	key_cfg_file.write("        NULL\n")
	key_cfg_file.write("    }\n")
	key_cfg_file.write("    KEY BITSTRING ::= {\n")
	key_cfg_file.write("        KEY SEQUENCE ::= {\n")
	key_cfg_file.write("            N INTEGER ::= " + str(pubk.m_n_val) + "\n")
	key_cfg_file.write("            E INTEGER ::= " + str(pubk.m_e_val) + "\n")
	key_cfg_file.write("        }\n")
	key_cfg_file.write("    }\n")
	key_cfg_file.write("}\n")
	key_cfg_file.close()
	return

def create_prvk_pem(tmp_pem, output):
	#load content from pem file
	tmp_pem_file = open(tmp_pem, 'r')
	tmp_pem_file.seek(0, 2)
	tmp_pem_file_size = tmp_pem_file.tell()
	tmp_pem_file.seek(0, 0)
	pem_data = tmp_pem_file.read(tmp_pem_file_size)
	tmp_pem_file.close()
	#re-format and write result to outptu file
	output_file = open(output, 'w')
	output_file.write("-----BEGIN RSA PRIVATE KEY-----\n")
	for i in range(0, tmp_pem_file_size):
		output_file.write(pem_data[i])
		if ((i + 1) % 64 == 0):
			output_file.write("\n")
	output_file.write("\n")
	output_file.write("-----END RSA PRIVATE KEY-----\n")
	tmp_pem_file.close()
	output_file.close()
	return

def create_pubk_pem(tmp_pem, output):
	#load content from pem file
	tmp_pem_file = open(tmp_pem, 'r')
	tmp_pem_file.seek(0, 2)
	tmp_pem_file_size = tmp_pem_file.tell()
	tmp_pem_file.seek(0, 0)
	pem_data = tmp_pem_file.read(tmp_pem_file_size)
	tmp_pem_file.close()
	#re-format and write result to outptu file
	output_file = open(output, 'w')
	output_file.write("-----BEGIN PUBLIC KEY-----\n")
	for i in range(0, tmp_pem_file_size):
		output_file.write(pem_data[i])
		if ((i + 1) % 64 == 0):
			output_file.write("\n")
	output_file.write("\n")
	output_file.write("-----END PUBLIC KEY-----\n")
	tmp_pem_file.close()
	output_file.close()
	return

def key_ini_parse(ini_file_path, key):
	key.m_n_val = 0
	key.m_e_val = 65537
	key.m_d_val = 0
	ini_file = open(ini_file_path, 'r')
	lines = ini_file.readlines()
	for line in lines:
		line = line.strip()
		line = line.replace('\"', '')
		node = line.split('=')
		if len(node) == 2:
			node[0] = node[0].strip()
			if node[0] == "private_key_n" or node[0] == "AUTH_PARAM_N":
				node[1] = node[1].replace("0x", "")
				node[1] = node[1].strip()
				for ch in node[1]:
					key.m_n_val = key.m_n_val * 16 + cert.chToVal(ch)
			if node[0] == "private_key_d" or node[0] == "AUTH_PARAM_D":
				node[1] = node[1].replace("0x", "")
				node[1] = node[1].strip()
				for ch in node[1]:
					key.m_d_val = key.m_d_val * 16 + cert.chToVal(ch)
			if node[0] == "public_key_n":
				node[1] = node[1].replace("0x", "")
				node[1] = node[1].strip()
				for ch in node[1]:
					key.m_n_val = key.m_n_val * 16 + cert.chToVal(ch)
		if key.m_n_val != 0 and key.m_d_val != 0:
			break;
	ini_file.close()
	if key.m_n_val == 0:
		return -1
	else:
		return 0

def main():
	key_cfg = "key.cfg"
	output_der = "out_key.der"
	output_pem = "out_key.pem"
	key_ini_path = sys.argv[1]
	key_type = sys.argv[2]
	output = sys.argv[3]
	print "========================================="
	print "key_ini_path           = " + key_ini_path
	print "output                 = " + output
	print "========================================="

	key = cert.rsakey()
	if 0 != key_ini_parse(key_ini_path, key):
		print "key ini parsing failed"
		return -1

	if key_type != 'prvk' and key_type != 'pubk':
		print "unknown key type"
		return -1

	if key_type == 'prvk':
		if key.m_n_val == 0:
			print "n is missing"
			return -1
		if key.m_e_val == 0:
			print "e is missing"
			return -1
		if key.m_d_val == 0:
			print "n is missing"
			return -1
		#n, e, d comes from key ini file
		cert.key_populate(key, False)
		create_prvk_cfg(key, key_cfg)
		asn1_gen.asn1_gen(key_cfg, output_der, False)
		der_to_pem(output_der, output_pem)
		create_prvk_pem(output_pem, output)
	elif key_type == 'pubk':
		if key.m_n_val == 0:
			print "n is missing"
			return -1
		if key.m_e_val == 0:
			print "e is missing"
			return -1
		#n, e comes from key ini file
		create_pubk_cfg(key, key_cfg)
		asn1_gen.asn1_gen(key_cfg, output_der, False)
		der_to_pem(output_der, output_pem)
		create_pubk_pem(output_pem, output)
	os.remove(key_cfg)
	os.remove(output_der)
	os.remove(output_pem)
	return 0

if __name__ == '__main__':
	main()
