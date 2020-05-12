import os
import time
import sys
import shutil

def preloader_chage (file, key_path):

	print file
	print key_path

	shutil.copy2(file, "preloader_backup.txt")
	f = open("preloader_backup.txt", "r+")
	lines = f.readlines()
	count = len(lines)
	preloader_keys_list = []
	preloader_values_list = []
	preloader_dict = {}
	for i in range(count):
		line = lines[i]
		item = line.split("=")
		preloader_key = item[0]
		a="[CONTENT]"
		b="[KEY]"
		a=a.strip()
		b=b.strip()
		preloader_key = preloader_key.strip()
		if preloader_key == a or preloader_key == b:
			print "AAAAAA/BBBBB"
			continue
		preloader_value = item[1]
		preloader_keys_list.append(preloader_key)
		preloader_values_list.append(preloader_value)
	preloader_dict_zip = zip(preloader_keys_list,preloader_values_list)
	preloader_dict = dict(preloader_dict_zip)
	preloader_dict["rootkey"] = key_path + "\n"
	preloader_dict["imgkey"] = key_path + "\n"
	
	preloader_keys_list = list(preloader_dict.keys())
	preloader_value_list = list(preloader_dict.values())
	num = len(preloader_keys_list)
	line_list = []
	for j in range(num):
		line_j = preloader_keys_list[j] + "=" + preloader_value_list[j]
		line_list.append(line_j)
	line_str = "".join(line_list)
	f2 = open(file, "w")
	f2.write(line_str)
	time.sleep(1)
	f2.close()
	f.close()


if __name__ == "__main__":
	file = str(sys.argv[1])
	key_path = str(sys.argv[2])
	preloader_chage(file, key_path)
