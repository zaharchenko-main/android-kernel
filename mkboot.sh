#!/bin/sh

DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p $DIR/boot/bin

cd $DIR/boot/bin && wget https://android.googlesource.com/platform/system/tools/mkbootimg/+archive/refs/heads/master.tar.gz
cd $DIR/boot/bin && wget https://android.googlesource.com/platform/system/libufdt/+archive/refs/heads/master/utils/src.tar.gz

cd $DIR/boot/bin && tar -xf master.tar.gz
cd $DIR/boot/bin && tar -xf src.tar.gz

cp $DIR/out/arch/arm64/boot/Image.gz-dtb $DIR/boot/Image.gz-dtb
cat $DIR/out/arch/arm64/boot/dts/qcom/*.dtb > $DIR/boot/dtb
touch $DIR/boot/ramdisk

cd $DIR/boot && python2 $DIR/boot/bin/mkdtboimg.py create dtbo.img $DIR/out/arch/arm64/boot/dts/qcom/*.dtbo

cd $DIR/boot && python3 $DIR/boot/bin/mkbootimg.py \
  --cmdline "console=ttyMSM0,115200n8 earlycon=msm_geni_serial,0xA90000 androidboot.hardware=qcom androidboot.console=ttyMSM0 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 service_locator.enable=1 androidboot.configfs=true androidboot.usbcontroller=a600000.dwc3 swiotlb=1 loop.max_part=7 buildvariant=userdebug" \
  --kernel ./Image.gz-dtb \
  --ramdisk ./ramdisk \
  --dtb ./dtb \
  --base "0x00000000" \
  --kernel_offset "0x00008000" \
  --ramdisk_offset "0x00000000" \
  --second_offset "0x00000000" \
  --tags_offset "0x00000100" \
  --os_version "12.0.0" \
  --os_patch_level "2021-12-16" \
  --pagesize "4096" \
  --board "" \
  --hashtype sha1 \
  --header_version "0" \
  -o boot.img

cp $DIR/boot/boot.img $DIR/update/boot.img
cp $DIR/boot/dtbo.img $DIR/update/dtbo.img

cd $DIR/update && zip -r9 InfernoKernel_$(cat $DIR/devive)-12-20211215.zip META-INF boot.img dtbo.img
