import os
import time
import sys
import shutil

def env_chage(file, image_path):

	shutil.copy2(file, "env_cfg_backup.txt")

	f = open("env_cfg_backup.txt", "r+")
	lines = f.readlines()
	count = len(lines)
	env_keys_list = []
	env_values_list = []
	env_dict = {}

	for i in range(count):
		line = lines[i]
		item = line.split("=")
		env_key = item[0]
		env_value = item[1]
		env_keys_list.append(env_key)
		env_values_list.append(env_value)
	env_dict_zip = zip(env_keys_list,env_values_list)
	env_dict = dict(env_dict_zip)
	env_dict["in_path"] = image_path + "\n"
	env_dict["out_path"] = image_path + "\n"
	
	env_keys_list = list(env_dict.keys())
	env_value_list = list(env_dict.values())
	num = len(env_keys_list)
	line_list = []
	for j in range(num):
		line_j = env_keys_list[j] + "=" + env_value_list[j]
		line_list.append(line_j)
	line_str = "".join(line_list)
	f2 = open(file, "w")
	f2.write(line_str)
	time.sleep(1)
	f2.close()
	f.close()


if __name__ == "__main__":
	file = str(sys.argv[1])
	image_path = str(sys.argv[2])
	env_chage(file, image_path)
