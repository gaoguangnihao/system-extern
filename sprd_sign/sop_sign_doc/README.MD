# kaios-sign server 
[mtk-version-sign](https://git.kaiostech.com/xiao.yu/local_project/-/blob/master/version_sign/README.md)

## In this intruduction Will be talk about 4 parts:
*  Flow of Generate Private keys for new project (Gen_Key)
*  Flow of Signature for new project (Signature)
*  Script about kaios
*  How to USE

## Gen_Key

[mtk generator keys](https://www.processon.com/mindmap/5ebb5ba5f346fb6907ef6148)


## Signature

### sign flow
[sign flow processon](https://www.processon.com/diagraming/5e66e7e0e4b06578661f76bd)

### boot image
[boot system image](https://www.processon.com/apps/5e7b1a46e4b01518203cc98a)

### dm verify
[dm](https://www.processon.com/apps/5e79c847e4b092510f713b56)

### kaios sign
[kaios sign](https://www.processon.com/mindmap/5e859a59e4b0893f957c88c4)

## script

## How to use

### Generator keys


>  kaios_key_generator.sh Kaios31_jpv path_of_save

* 1 first parmerter is PRODUCTION name should be get from cpm 
* 2 second parmerter is the path about where your will be save the keys


### Signature
>  kaios_key_sign.sh /home/kai-user/key_path /home/kai-user/key_path /home/kai-user/image_path /home/dhcui/image_out preloader signda /home/dhcui/da_path efuse

* 1  is root key path
* 2  is imgae key path
* 3  is pre sign image path
* 4  is signed imgae path
* 5  is a flag , wiil be sign preloader or not
* 6  is a flag , will be sign da or not
* 7  is da image path for will be signed
* 8  is a flag , will be for efuse write  to generator

>  sample as blow 
>  kaios_key_sign.sh /home/kai-user/key_path /home/kai-user/key_path /home/kai-user/image_path /home/dhcui/image_out preloader null /home/dhcui/da_path null
