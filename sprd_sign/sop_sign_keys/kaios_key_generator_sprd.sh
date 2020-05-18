##########init valiable ###################
#########################################

echo '============================================='
echo '=========Generator SPRD-9820e keys by KaiOS========='
echo '============================================='
echo 


TOOLSDIR="`dirname $0`"
echo "The script tools path is "$TOOLSDIR


if [ ! -n "$1" ] ;then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "You have not input PRODUCT_NAME!"
    echo "Try ./kaios_key_generator_sprd.sh Kaios31_jpv path_of_save"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 127
else
    echo "The first args you input is $1"

fi

if [ $# -lt 2 ];then
	echo "############WORNG PARG ###########"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "You have not input PRODUCT_NAME!"
	echo "try ./kaios_key_generator.sh Kaios31_jpv path_of_save"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!"
	exit 127
fi
#DEST_FOLDER=/local/keys-mtk/ should be dynamic
PRODUCT_NAME=/tmp/$1
DEST_FOLDER=$2

clean()
{
       echo "!!!!clean begin!!!!"
       rm -fr $PRODUCT_NAME
       echo "!!!!clean end!!!!"
}

if [ ! -d "$PRODUCT_NAME" ];then
       mkdir $PRODUCT_NAME
       mkdir $PRODUCT_NAME/PUBLIC_KEYS
       echo "Should be creat $PRODUCT_NAME for keys generator"
else 
        echo "!!the project already exist!!"
  	echo $PRODUCT_NAME
	exit 128
fi

if [ ! -d $DEST_FOLDER ];then
  echo "!!!!!please creat path of save keys first!!!!"
  clean
  exit 129
fi

# generator root key 
echo '******generator keys and der begin******'

cd $PRODUCT_NAME

openssl genrsa -out rsa2048_0.pem 2048

if [ $? != 0 ];then
   echo "error !! generator rsa2048_0.pem"
   clean
   exit 129
fi

#
openssl rsa -in rsa2048_0.pem -pubout >rsa2048_0_pub.pem

if [ $? != 0 ];then
   echo "error !! generator rsa2048_0_pub.pem"
   clean
   exit 129
fi
#

openssl genrsa -out rsa2048_1.pem 2048

if [ $? != 0 ];then
   echo "error !! generator rsa2048_1.pem"
   clean
   exit 129
fi

#
openssl rsa -in rsa2048_1.pem -pubout >rsa2048_1_pub.pem

if [ $? != 0 ];then
   echo "error !! generator rsa2048_1_pub.pem"
   clean
   exit 129
fi
#

openssl genrsa -out rsa2048_2.pem 2048

if [ $? != 0 ];then
   echo "error !! generator rsa2048_2.pem"
   clean
   exit 129
fi

#
openssl rsa -in rsa2048_2.pem -pubout >rsa2048_2_pub.pem

if [ $? != 0 ];then
   echo "error !! generator rsa2048_2_pub.pem"
   clean
   exit 129
fi
#

echo '******generator keys done******'

#beging to generator dm-key for system device verity

echo "generator RSA key pair"
openssl genrsa -out dm_prvk.pem 2048

if [ $? != 0 ];then
   echo "error !! generator dm_prvk.pem"
   clean
   exit 129
fi

echo "generator verity.pk8"

openssl pkcs8 -topk8 -inform PEM -outform DER -in dm_prvk.pem -out verity.pk8 -nocrypt

if [ $? != 0 ];then
   echo "error !! generator verity.pk8"
   clean
   exit 129
fi

echo "generator verity.x509.pem"
openssl req -new -x509 -key dm_prvk.pem -out verity.x509.pem -sha256 -subj '/C=US/ST=ShangHai/L=Mountain View/O=KaiOS/OU=KaiOS/CN=KaiOS/emailAddress=kaios_sprd9820e@kaiostech.com'

if [ $? != 0 ];then
   echo "error !! generator verity.x509.pem"
   clean
   exit 129
fi

echo "generator verity_key"
LD_LIBRARY_PATH=$TOOLSDIR/lib $TOOLSDIR/bin/generate_verity_key -convert verity.x509.pem verity_key

if [ $? != 0 ];then
   echo "error !! generator verity_key"
   clean
   exit 129
fi

echo "rename verity_key"

mv verity_key.pub verity_key


#cp dakey.h $PRODUCT_NAME/PUBLIC_KEYS||echo "copy dakey error"
#cp oemkey.h $PRODUCT_NAME/PUBLIC_KEYS||echo "copy dakey error"
cp verity_key $PRODUCT_NAME/PUBLIC_KEYS||echo "copy dakey error"
cp rsa2048_0_pub.pem $PRODUCT_NAME/PUBLIC_KEYS||echo "copy dakey error"

cd ..

#FIXED-ME
#DEST_FOLDER=/local/keys-mtk/
echo "copy key files to dest path"

if [ -d $DEST_FOLDER/$1 ];then
  echo "!!!! error for $1 already generator"
  clean
  exit 129
fi  

cp -Rvdp $PRODUCT_NAME $DEST_FOLDER

echo "clean tmp key files"
rm -fr $PRODUCT_NAME

echo '============================================='
echo '=========generator SPRD-9820e keys by KAIOS========='
echo '============================================='
###
#



