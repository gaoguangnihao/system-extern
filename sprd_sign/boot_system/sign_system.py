#!/usr/bin/env python

"""
Build image output_image_file from input_directory and properties_file.

Usage:  build_image input_directory properties_file output_image_file

"""
import os
import os.path
import re
import subprocess
import sys
import commands
import common
import shutil
import tempfile

OPTIONS = common.OPTIONS

FIXED_SALT = "aee087a5be3b982978c923f566a94613496b417f2af592639bc80d141e34dfe7"
CURDIR = os.getcwd()

def RunCommand(cmd):
  """Echo and run the given command.

  Args:
    cmd: the command represented as a list of strings.
  Returns:
    A tuple of the output and the exit code.
  """
  print "Running: ", " ".join(cmd)
  p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  output, _ = p.communicate()
  print "%s" % (output.rstrip(),)
  return (output, p.returncode)

def GetVerityTreeSize(partition_size):
  cmd = "LD_LIBRARY_PATH=boot_system/lib boot_system/bin/build_verity_tree -s %d"
  cmd %= partition_size
  status, output = commands.getstatusoutput(cmd)
  if status:
    print output
    return False, 0
  return True, int(output)

def GetVerityMetadataSize(partition_size):
  cmd = "boot_system/build_verity_metadata.py -s %d"
  cmd %= partition_size

  status, output = commands.getstatusoutput(cmd)
  if status:
    print output
    return False, 0
  return True, int(output)

def AdjustPartitionSizeForVerity(partition_size):
  """Modifies the provided partition size to account for the verity metadata.

  This information is used to size the created image appropriately.
  Args:
    partition_size: the size of the partition to be verified.
  Returns:
    The size of the partition adjusted for verity metadata.
  """
  
  print "AdjustPartitionSizeForVerity %d " % partition_size
  success, verity_tree_size = GetVerityTreeSize(partition_size)
  if not success:
    return 0
  success, verity_metadata_size = GetVerityMetadataSize(partition_size)
  if not success:
    return 0
  return partition_size - verity_tree_size - verity_metadata_size

def BuildVerityTree(sparse_image_path, verity_image_path, prop_dict):
  cmd = "LD_LIBRARY_PATH=boot_system/lib boot_system/bin/build_verity_tree -A %s %s %s" % (
      FIXED_SALT, sparse_image_path, verity_image_path)
  print cmd
  status, output = commands.getstatusoutput(cmd)
  if status:
    print "Could not build verity tree! Error: %s" % output
    return False
  root, salt = output.split()
  prop_dict["verity_root_hash"] = root
  prop_dict["verity_salt"] = salt
  return True

def BuildVerityMetadata(image_size, verity_metadata_path, root_hash, salt,
                        block_device, signer_path, key):
  cmd_template = (
      "python boot_system/build_verity_metadata.py %s %s %s %s %s %s %s")
  cmd = cmd_template % (image_size, verity_metadata_path, root_hash, salt,
                        block_device, signer_path, key)
  print cmd
  status, output = commands.getstatusoutput(cmd)
  if status:
    print "Could not build verity metadata! Error: %s" % output
    return False
  return True

def Append2Simg(sparse_image_path, unsparse_image_path, error_message):
  """Appends the unsparse image to the given sparse image.

  Args:
    sparse_image_path: the path to the (sparse) image
    unsparse_image_path: the path to the (unsparse) image
  Returns:
    True on success, False on failure.
  """
  cmd = "LD_LIBRARY_PATH=boot_system/lib boot_system/bin/append2simg %s %s"
  cmd %= (sparse_image_path, unsparse_image_path)
  print cmd
  status, output = commands.getstatusoutput(cmd)
  if status:
    print "%s: %s" % (error_message, output)
    return False
  return True

def BuildVerifiedImage(data_image_path, verity_image_path,
                       verity_metadata_path):
  if not Append2Simg(data_image_path, verity_metadata_path,
                     "Could not append verity metadata!"):
    return False
  if not Append2Simg(data_image_path, verity_image_path,
                     "Could not append verity tree!"):
    return False
  return True

def UnsparseImage(sparse_image_path, replace=True):
  img_dir = os.path.dirname(sparse_image_path)
  unsparse_image_path = "unsparse_" + os.path.basename(sparse_image_path)
  unsparse_image_path = os.path.join(img_dir, unsparse_image_path)
  if os.path.exists(unsparse_image_path):
    if replace:
      os.unlink(unsparse_image_path)
    else:
      return True, unsparse_image_path
  inflate_command = ["simg2img", sparse_image_path, unsparse_image_path]
  (_, exit_code) = RunCommand(inflate_command)
  if exit_code != 0:
    os.remove(unsparse_image_path)
    return False, None
  return True, unsparse_image_path

def MakeVerityEnabledImage(in_dir, prop_dict, out_file):
  """Creates an image that is verifiable using dm-verity.

  Args:
    in_dir : system image from customer
    out_file: the location to write the verifiable image at
    prop_dict: a dictionary of properties required for image creation and
               verification
  Returns:
    True on success, False otherwise.
  """
    # make a tempdir
  tempdir_name = tempfile.mkdtemp(suffix="_verity_images")
  
   
  verity_image_path = os.path.join(tempdir_name, "verity.img")
  verity_metadata_path = os.path.join(tempdir_name, "verity_metadata.img")
  
  #print "verity_image_path is %s" % verity_image_path
  #print "verity_metadata_path is %s" % verity_metadata_path
  #print "CURDIR is %s " + CURDIR
  
  if not BuildVerityTree(in_dir, verity_image_path, prop_dict):
    shutil.rmtree(tempdir_name, ignore_errors=True)
    return False

  # build the metadata blocks
  #print "success build verifytree"
  root_hash = prop_dict["verity_root_hash"]
  salt = prop_dict["verity_salt"]
  image_size = int(prop_dict["partition_size"])
  block_dev = prop_dict["verity_block_device"]
  signer_key = prop_dict["verity_key"] + ".pk8"
  
  signer_path = prop_dict["verity_signer_cmd"]
    
  #print "verity_salt is %s" % salt
  #print "verity_root_hash %s" % root_hash
  #print "signer_path %s" % signer_path
  #print "block_dev %s" % block_dev
  #print "signer_key %s" % signer_key
  adjusted_size = AdjustPartitionSizeForVerity(image_size)
  #print "adjusted_size is %s" % adjusted_size

  if not BuildVerityMetadata(adjusted_size, verity_metadata_path, root_hash, salt,
                             block_dev, signer_path, signer_key):
    shutil.rmtree(tempdir_name, ignore_errors=True)
    return False

  #print "system image path %s" % in_dir
  #print "out system image path %s " % out_file
  shutil.copy2(in_dir,out_file)
  # build the full verified image
  if not BuildVerifiedImage(out_file,
                            verity_image_path,
                            verity_metadata_path):
    shutil.rmtree(tempdir_name, ignore_errors=True)
    return False
  shutil.rmtree(tempdir_name, ignore_errors=True)
  return True

def SignSystemImage(in_dir, prop_dict, out_file):
  """Build an image to out_file from in_dir with property prop_dict."""

  if not MakeVerityEnabledImage(in_dir, prop_dict, out_file):
      return False
  print "success MakeVerityEnabledImage"
  run_fsck = True 
  if run_fsck and prop_dict.get("skip_fsck") != "true":
    print "build system image UnsparseImage"
    success, unsparse_image = UnsparseImage(out_file, replace=False)
    if not success:
      return False

    # Run e2fsck on the inflated image file
    print "build system image run e2fsck"
    e2fsck_command = ["e2fsck", "-f", "-n", unsparse_image]
    (_, exit_code) = RunCommand(e2fsck_command)

    os.remove(unsparse_image)
    print "build system image done with success"
  return True


def ImagePropFromGlobalDict(glob_dict, mount_point):
  """Build an image property dictionary from the global dictionary.

  Args:
    glob_dict: the global dictionary from the build system.
    mount_point: such as "system", "data" etc.
  """
  d = {}
  if "build.prop" in glob_dict:
    bp = glob_dict["build.prop"]
    if "ro.build.date.utc" in bp:
      d["timestamp"] = bp["ro.build.date.utc"]

  def copy_prop(src_p, dest_p):
    if src_p in glob_dict:
      d[dest_p] = str(glob_dict[src_p])

  common_props = (
      "extfs_sparse_flag",
      "mkyaffs2_extra_flags",
      "selinux_fc",
      "skip_fsck",
      "verity",
      "verity_key",
      "verity_signer_cmd"
      )
  for p in common_props:
    copy_prop(p, p)

  d["mount_point"] = mount_point
  if mount_point == "system":
    copy_prop("fs_type", "fs_type")
    copy_prop("block_list", "block_list")
    # Copy the generic sysetem fs type first, override with specific one if
    # available.
    copy_prop("system_fs_type", "fs_type")
    copy_prop("system_size", "partition_size")
    copy_prop("system_journal_size", "journal_size")
    copy_prop("system_verity_block_device", "verity_block_device")
    copy_prop("system_root_image", "system_root_image")
    copy_prop("ramdisk_dir", "ramdisk_dir")
    copy_prop("has_ext4_reserved_blocks", "has_ext4_reserved_blocks")
    copy_prop("system_squashfs_compressor", "squashfs_compressor")
    copy_prop("system_squashfs_compressor_opt", "squashfs_compressor_opt")
  elif mount_point == "data":
    # Copy the generic fs type first, override with specific one if available.
    copy_prop("fs_type", "fs_type")
    copy_prop("userdata_fs_type", "fs_type")
    copy_prop("userdata_size", "partition_size")
  elif mount_point == "cache":
    copy_prop("cache_fs_type", "fs_type")
    copy_prop("cache_size", "partition_size")
  elif mount_point == "vendor":
    copy_prop("vendor_fs_type", "fs_type")
    copy_prop("vendor_size", "partition_size")
    copy_prop("vendor_journal_size", "journal_size")
    copy_prop("vendor_verity_block_device", "verity_block_device")
    copy_prop("has_ext4_reserved_blocks", "has_ext4_reserved_blocks")
  elif mount_point == "oem":
    copy_prop("fs_type", "fs_type")
    copy_prop("oem_size", "partition_size")
    copy_prop("oem_journal_size", "journal_size")
    copy_prop("has_ext4_reserved_blocks", "has_ext4_reserved_blocks")

  return d


def LoadGlobalDict(filename):
  """Load "name=value" pairs from filename"""
  d = {}
  f = open(filename)
  for line in f:
    line = line.strip()
    if not line or line.startswith("#"):
      continue
    k, v = line.split("=", 1)
    d[k] = v
  f.close()
  return d


def main(argv):
  if len(argv) != 3:
    print __doc__
    sys.exit(1)

  system_dir = argv[0]
  glob_dict_file = argv[1]
  out_file = argv[2]

  glob_dict = LoadGlobalDict(glob_dict_file)
  mount_point = "system"
  
  image_properties = ImagePropFromGlobalDict(glob_dict, mount_point)
  
  if not SignSystemImage(system_dir, image_properties, out_file):
    print >> sys.stderr, "error: failed to build %s from %s" % (out_file,
                                                                system_dir)
    exit(1)


if __name__ == '__main__':
  main(sys.argv[1:])
