import os
import time
import sys
import shutil

def system_img_chage(file, verity_key):

	#os.rename(file, "system_img_chage_backup.txt")
	shutil.copy2(file, "system_img_chage_backup.txt")

	f = open("system_img_chage_backup.txt", "r+")
	lines = f.readlines()
	count = len(lines)
	system_img_keys_list = []
	system_img_values_list = []
	system_img_dict = {}

	for i in range(count):
		line = lines[i]
		item = line.split("=")
		system_img_key = item[0]
		system_img_value = item[1]
		system_img_keys_list.append(system_img_key)
		system_img_values_list.append(system_img_value)
	system_img_dict_zip = zip(system_img_keys_list,system_img_values_list)
	system_img_dict = dict(system_img_dict_zip)
	system_img_dict["verity_key"] = verity_key + "\n"
	system_img_dict["verity_signer_cmd"] = verity_signer_cmd + "\n"
	
	system_img_keys_list = list(system_img_dict.keys())
	system_img_value_list = list(system_img_dict.values())
	num = len(system_img_keys_list)
	line_list = []
	for j in range(num):
		line_j = system_img_keys_list[j] + "=" + system_img_value_list[j]
		line_list.append(line_j)
	line_str = "".join(line_list)
	f2 = open(file, "w")
	f2.write(line_str)
	time.sleep(1)
	f2.close()
	f.close()

if __name__ == "__main__":
	file = str(sys.argv[1])
	verity_key = str(sys.argv[2])
	verity_signer_cmd = str(sys.argv[3])
	system_img_chage(file, verity_key)
