# kaios-sign server 
to be done

## In this intruduction Will be talk about 4 parts:
*  Flow of Generate Private keys for new project (Gen_Key)
*  Flow of Signature for new project (Signature)
*  Script about kaios
*  How to USE

## Gen_Key

[sprd generator keys](https://www.processon.com/mindmap/5ee6df9c6376891e81cb74f3)


## Signature

### sign flow
[kaios sign flow processon](https://www.processon.com/mindmap/5eba0687e401fd16f42e9c22)

### boot image
[boot system image](https://www.processon.com/apps/5e7b1a46e4b01518203cc98a)

### dm verify
[dm](https://www.processon.com/apps/5e79c847e4b092510f713b56)

### kaios sign
[sprd sign](https://www.processon.com/mindmap/5ea67da8f346fb177b998efc)

## script

## How to use

### Generator keys


>  kaios_key_generator_sprd.sh.sh 9820e_1h20 path_of_save

* 1 first parmerter is PRODUCTION name should be get from cpm 
* 2 second parmerter is the path about where your will be save the keys


### Signature
>  kaios_key_sign_sprd.sh /home/dhcui/key_path /home/dhcui/test_sprd_pier2m/source /home/dhcui/test_sprd_pier2m/dest /local/tools/system-faq/system-extern/sprd_sign$ sp9820e_2c10aov userdebug


* 1  is root key path
* 2  is pre sign image path
* 3  is signed imgae path
* 4  is sign tools path 
* 5  is project name
* 6  version type


>  sample as blow 
>  kaios_key_sign_sprd.sh /home/dhcui/key_path /home/dhcui/test_sprd_pier2m/source /home/dhcui/test_sprd_pier2m/dest /local/tools/system-faq/system-extern/sprd_sign$ sp9820e_2c10aov userdebug
