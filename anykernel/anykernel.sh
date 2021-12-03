# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers
## AnyKernel setup
# begin properties
properties() { '
kernel.string=Zaharchenko
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=jd2019
device.name2=kunlun2
'; }
# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;
## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;
## AnyKernel install
split_boot;

flash_boot;
flash_dtbo;

## end install
