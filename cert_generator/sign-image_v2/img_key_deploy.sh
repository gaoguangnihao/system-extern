#!/bin/bash

#######################################
# Initialize variables
#######################################

PLATFORM=mt6739 python ./sign-image_v2/img_key_deploy.py mt6739 kaios31_jpv cert1_key_path=/local/keys-mtk/kaios_jpv/root_prvk.pem cert2_key_path=/local/keys-mtk/kaios_jpv/img_prvk.pem root_key_padding=pss | tee img_key_deploy.log

