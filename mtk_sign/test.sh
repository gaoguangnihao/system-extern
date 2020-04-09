##########init valiable ###################
# return value 127 means that files not exist
# return value 128 means that parm NO. wrong
# return value 129 means that exec prom wrong

bash efuse_generator/kaios_build_efuse.sh /local/keys-mtk/kaios_jpv/root_prvk.pem

curdate="`date +%Y-%m-%d-%H:%M:%S`"

echo $curdate

