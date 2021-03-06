"""
This module integrates image signing flow so user could sign all images
in one shot.
"""
import os
import re
import shutil
import argparse
import sign

def create_out_dir(path):
    """
    create output folder if it does not exist
    """
    folder_path = os.path.abspath(path)
    print "sign_flow Create dir: dhcui " + folder_path

    try:
        os.makedirs(folder_path)
    except OSError, error:
        if error.errno != os.errno.EEXIST:
            raise

class SignFlow(object):
    """
    sign flow class for android image signing/resigning
    """
    def __init__(self):
        self.in_path = None
        self.out_path = None
        self.cert1_dir = None
        self.cert2_key_dir = None
        self.img_list_path = None
        self.img_ver_path = None
        self.bin_tmp_path = None
        self.platform = None
        self.project = None

    def set_path(self, platform, project, cfg_file_path):
        """
        set up environment for image signing
        """
        print "sign_flow set_path: dhcui " + cfg_file_path

        self.platform = platform
        self.project = project
        cfg_file_dir = os.path.dirname(os.path.abspath(cfg_file_path))
        cfg_file = open(cfg_file_path, 'r')
        for line in cfg_file.readlines():
            line = line.strip()
            if line:
                elements = line.split('=')
                field = elements[0].strip()
                value = elements[1].strip()
                value = value.replace("${PLATFORM}", platform)
                value = value.replace("${PROJECT}", project)
                if field == 'out_path':
                    self.out_path = os.environ.get('PRODUCT_OUT')
                    if self.out_path is None:
                        print 'Use out path in env.cfg'
                        self.out_path = os.path.join(cfg_file_dir, value)
                    else:
                        print 'sign_flow dhcui Use out path in Android'
                    # in_path is optional, hence we give it default value here
                    if self.in_path is None:
                        self.in_path = self.out_path
                elif field == 'in_path':
                    self.in_path = os.environ.get('PRODUCT_OUT')
                    if self.in_path is None:
                        self.in_path = os.path.join(cfg_file_dir, value)
                elif field == 'cert1_dir':
                    self.cert1_dir = os.path.join(cfg_file_dir, value)
                elif field == 'cert2_key_dir':
                    self.cert2_key_dir = os.path.join(cfg_file_dir, value)
                elif field == 'img_list_path':
                    self.img_list_path = os.path.join(cfg_file_dir, value)
                elif field == 'img_ver_path':
                    self.img_ver_path = os.path.join(cfg_file_dir, value)

        self.bin_tmp_path = os.path.join(self.out_path,
                                         "resign",
                                         "bin",
                                         "multi_tmp")

        print "==================================="
        print "sign_flow dhcui environment configuration"
        print "==================================="
        print 'sign_flow dhcui in_path = ' + self.in_path
        print 'sign_flow dhcui out_path = ' + self.out_path
        print 'sign_flow dhcui cert1_dir = ' + self.cert1_dir
        print 'sign_flow dhcui cert2_key_dir = ' + self.cert2_key_dir
        print 'sign_flow dhcui img_list_path = ' + self.img_list_path
        print 'sign_flow dhcui img_ver_path = ' + self.img_ver_path
        print 'sign_flow dhcui bin_tmp_path = ' + self.bin_tmp_path

        cfg_file.close()

        create_out_dir(self.bin_tmp_path)

    def parse_img_list(self):
        """
        parse image list file and get image signing settings
        """

        print 'sign_flow dhcui will be parse_img_list' + self.img_list_path

        img_type = 'SINGLE_BIN'
        pattern1 = r"\[single_bin\]"
        format1 = re.compile(pattern1)
        pattern2 = r"\[multi_bin\]"
        format2 = re.compile(pattern2)
        pattern3 = r"\[image_hash_list\]"
        format3 = re.compile(pattern3)
        img_list_file = open(self.img_list_path, 'r')
        single_bin_dict = {}
        multi_bin_dict = {}
        img_hash_list = []
        for line in img_list_file:
            if not line.strip():
                continue

            if format1.match(line):
                img_type = 'SINGLE_BIN'
            elif format2.match(line):
                img_type = 'MULTI_BIN'
            elif format3.match(line):
                img_type = 'HASH_LIST'
            else:
                if img_type == 'SINGLE_BIN':
                    bin_name = line.split("=")[0].strip()
                    img_name = line.split("=")[1].strip()
                    single_bin_dict[bin_name] = img_name
                elif img_type == 'MULTI_BIN':
                    bin_name = line.split("=")[0].strip()
                    img_name = line.split("=")[1].strip()
                    multi_bin_dict[bin_name] = img_name
                elif img_type == 'HASH_LIST':
                    img_hash_list.append(line.strip())

        img_list_file.close()
        return single_bin_dict, multi_bin_dict, img_hash_list

    def get_img_ver(self, img_name):
        """
        get image version of specified image from image version setting file
        """

        print 'sign_flow dhcui will be get_img_ver' + self.img_ver_path
        img_ver = 0
        target_line = 0

        img_ver_file = open(self.img_ver_path, 'r')

        pattern1 = r"\[" + img_name + r"\]"
        format1 = re.compile(pattern1)
        pattern2 = "img_ver*"
        format2 = re.compile(pattern2)
        for line in img_ver_file:
            if not line.strip():
                continue

            if format1.match(line):
                target_line = 1
            elif format2.match(line):
                if target_line == 1:
                    img_ver = line.split("=")[1].strip()
                target_line = 0

        img_ver_file.close()
        return img_ver

    def gen_cert2(self, img_path, img_name, get_hash_list):
        """
        In certificate chain design, cert1, which is image public key certificate,
        is already generated by security owner, so it's prebuilt binary.
        Image owner will use this module to generate cert2, which is image content
        certificate and inject it into proper place in image.
        """

        print "\033[1;36msign_flow.py gen_cert2 begin\033[0m"

        prvk_path = os.path.join(self.cert2_key_dir, img_name + '_privk2.pem')
        pubk_path = os.path.join(self.cert2_key_dir, img_name + '_pubk2.pem')
        cert_path = os.path.join(self.cert1_dir, img_name + '_cert1.der')
        # image signing will be forwarded to HSM if public key is given.
        # public key has higher priority than private key.

        print 'sign_flow dhcui gen_cert2 cert2_key_dir ..' + self.cert2_key_dir
        print 'sign_flow dhcui gen_cert2 prvk_path ..' + prvk_path
        print 'sign_flow dhcui gen_cert2 pubk_path ..' + pubk_path
        print 'sign_flow dhcui gen_cert2 cert_path ..' + cert_path

        if os.path.isfile(pubk_path):
            key_path = pubk_path
        elif os.path.isfile(prvk_path):
            key_path = prvk_path
        ver = self.get_img_ver(img_name)

        # check bin exist in out folder
        print 'sign_flow img_path is ' + img_path + "\n" + "image name is" + img_name + "\n"+ "key path is " + key_path + "\n"
        if os.path.isfile(img_path):
            sign_obj = sign.Sign()
            sign_obj.args['type'] = 'cert2'
            sign_obj.args['img'] = img_path
            sign_obj.args['name'] = img_name
            sign_obj.args['cert1'] = cert_path
            sign_obj.args['privk'] = key_path
            sign_obj.args['ver'] = str(ver)
            sign_obj.args['getHashList'] = get_hash_list
            sign_obj.args['platform'] = self.platform
            sign_obj.args['project'] = self.project
            sign_obj.sign_op()
            print "\033[1;36msign_flow.py gen_cert2 end\033[0m"
        return

    def sign_single_bin(self, single_bin_dict, img):
        """
        sign image with only one sub-image
        """
        print 'sign_flow dhcui sign_single_bin'

        img_name = single_bin_dict[img]
        in_img_path = os.path.join(self.in_path, img)
        self.gen_cert2(in_img_path, img_name, 0)
        return

    def sign_multi_bin(self, multi_bin_dict, img):
        """
        sign image with multiple sub-images
        """

        print 'sign_flow dhcui sign_multi_bin'

        in_img_path = os.path.join(self.in_path, img)
        img_name_list = multi_bin_dict[img].split(",")
        multi_tmp_bin_in = os.path.join(self.bin_tmp_path, img)
        multi_tmp_bin_out = os.path.join(self.out_path,
                                         "resign",
                                         "bin",
                                         img.split(".")[0] +
                                         "-verified." +
                                         img.split(".")[1])
        if not os.path.exists(in_img_path):
            print "no " + str(img) + " image"
            return
        print "image name path = " + in_img_path
        print "image name = " + multi_tmp_bin_in
        shutil.copy2(in_img_path, multi_tmp_bin_in)

        for img_name in img_name_list:
            img_name = img_name.strip()
            self.gen_cert2(multi_tmp_bin_in, img_name, 0)
            shutil.copy2(multi_tmp_bin_out, multi_tmp_bin_in)
        return

    def sign_img_hash_list(self, img):
        """
        sign image without mkimg header, which is generally too big
        to put all of it into ram so we split them into chunks and
        flash it chunk by chunk.
        """
        print 'sign_flow dhcui sign_multi_bin'

        in_img_path = os.path.join(self.in_path, img)
        if not os.path.exists(in_img_path):
            print "no " + str(img) + " image"
            return
        img_name = img.split('.')[0].strip()
        self.gen_cert2(in_img_path, img_name, 1)
        return

    def sign_all_img(self, single_bin_dict, multi_bin_dict, img_hash_list):
        """
        sign all images if it's in image list file and is also found
        in output folder.
        """
        print "\033[1;35msign_flow dhcui sign_all_img\033[0m"

        for img in single_bin_dict.keys():
            print "\033[1;31msign_flow dhcui sign_all_img\033[0m"
            self.sign_single_bin(single_bin_dict, img)

        for img in multi_bin_dict.keys():
            print "\033[1;32msign_flow dhcui sign_all_img\033[0m"
            self.sign_multi_bin(multi_bin_dict, img)

        for img in img_hash_list:
            print "\033[1;33msign_flow dhcui sign_all_img\033[0m"
            self.sign_img_hash_list(img)

        return

    def sign_single_img(self, single_bin_dict, multi_bin_dict, img_hash_list, tgt):
        """
        sign only specified image in image list file.
        """
        print 'sign_flow dhcui sign_single_img'

        if single_bin_dict.get(tgt) is not None:
            self.sign_single_bin(single_bin_dict, tgt)
        elif multi_bin_dict.get(tgt) is not None:
            self.sign_multi_bin(multi_bin_dict, tgt)
        elif tgt in img_hash_list is True:
            self.sign_img_hash_list(tgt)

        return


def main():
    """
    entry point for image signing
    """
    get_setting_str = lambda arg: 'Not Set' if arg is None else arg
    env_cfg_default_path = os.path.join(os.path.dirname(__file__), 'env.cfg')
    sign_flow = SignFlow()

    parser = argparse.ArgumentParser(description='Integrated Flow for Image Signing')
    parser.add_argument('plat',
                        help='platform name. ex. mt6739.')
    parser.add_argument('proj',
                        help='project name. ex. k39v1_64.')
    parser.add_argument('-env_cfg',
                        dest='env_cfg',
                        help='configuration file for environment',
                        default=env_cfg_default_path)
    parser.add_argument('-target',
                        dest='tgt',
                        help='target image name. ex. lk.img. \
If this option is ignored, then all images found will be signed.')

    sign_flow_args = parser.parse_args()

    print "=========================================="
    print "sign_flow dhcui platform = " + get_setting_str(sign_flow_args.plat)
    print "sign_flow dhcui project = " + get_setting_str(sign_flow_args.proj)
    print "sign_flow dhcui target = " + get_setting_str(sign_flow_args.tgt)
    print "=========================================="

    sign_flow.set_path(sign_flow_args.plat, sign_flow_args.proj, sign_flow_args.env_cfg)
    single_bin_dict, multi_bin_dict, img_hash_list = sign_flow.parse_img_list()


    board_avb_enable = os.environ.get('BOARD_AVB_ENABLE')
    if board_avb_enable is None:
        board_avb_enable = 'false'
    else:
        board_avb_enable = board_avb_enable.lower()
    print "avb = " + get_setting_str(board_avb_enable)

    #bypass boot/recovery image if avb2.0 is enabled because both images fill up the partition
    if board_avb_enable == 'true':
        if single_bin_dict.get('boot.img', 0) != 0:
            del single_bin_dict['boot.img']
        if single_bin_dict.get('recovery.img', 0) != 0:
            del single_bin_dict['recovery.img']

    if sign_flow_args.tgt is None:
        return sign_flow.sign_all_img(single_bin_dict,
                                      multi_bin_dict,
                                      img_hash_list)

    return sign_flow.sign_single_img(single_bin_dict,
                                     multi_bin_dict,
                                     img_hash_list,
                                     sign_flow_args.tgt)


if __name__ == '__main__':
    main()
