#!/usr/bin/env bash
#
#  build.sh - Automic kernel building script for Rosemary Kernel
#
#  Copyright (C) 2021-2023, Crepuscular's AOSP WorkGroup
#  Author: EndCredits <alicization.han@gmail.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License version 2 as
#  published by the Free Software Foundation.
#
#  Add clang to your PATH before using this script.
#

TARGET_ARCH=arm64;
TARGET_CC=clang;
TRAGET_CLANG_TRIPLE=aarch64-linux-gnu-;
TARGET_CROSS_COMPILE=aarch64-linux-gnu-;
TARGET_CROSS_COMPILE_COMPAT=arm-linux-gnueabi-;
THREAD=$(nproc --all);
CC_ADDITIONAL_FLAGS="LLVM_IAS=1 LLVM=1";
TARGET_OUT="../out";
TARGET_DEVICE=renoir
TARGET_DEVICE_DEFCONFIG_NAME=renoir_defconfig

export TARGET_PRODUCT=$TARGET_DEVICE

FINAL_KERNEL_BUILD_PARA="ARCH=$TARGET_ARCH \
                         CC=$TARGET_CC \
                         CROSS_COMPILE=$TARGET_CROSS_COMPILE \
                         CROSS_COMPILE_COMPAT=$TARGET_CROSS_COMPILE_COMPAT \
                         CLANG_TRIPLE=$TARGET_CLANG_TRIPLE \
                         $CC_ADDITIONAL_FLAGS \
                         -j$THREAD \
                         O=$TARGET_OUT \
                         TARGET_PRODUCT=$TARGET_DEVICE";

TARGET_KERNEL_FILE=arch/arm64/boot/Image;
TARGET_KERNEL_DTB=arch/arm64/boot/dtb;
TARGET_KERNEL_DTBO=arch/arm64/boot/dtbo.img
TARGET_VENDOR_DLKM=vendor_dlkm.img
TARGET_KERNEL_NAME=Kernel;
TARGET_KERNEL_MOD_VERSION=$(make kernelversion)

DEFCONFIG_PATH=arch/arm64/configs
DEFCONFIG_NAME="vendor/lahaina-qgki_defconfig vendor/xiaomi_QGKI.config vendor/renoir_QGKI.config";

START_SEC=$(date +%s);
CURRENT_TIME=$(date '+%Y%m%d-%H%M');

link_all_dtb_files(){
    find $TARGET_OUT/arch/arm64/boot/dts/vendor/qcom -name '*.dtb' -exec cat {} + > $TARGET_OUT/arch/arm64/boot/dtb;
}

make_defconfig(){
    echo "------------------------------";
    echo " Building Kernel Defconfig..";
    echo "------------------------------";

    make $FINAL_KERNEL_BUILD_PARA $DEFCONFIG_NAME;
}

build_kernel(){
    echo "------------------------------";
    echo " Building Kernel ...........";
    echo "------------------------------";

    make $FINAL_KERNEL_BUILD_PARA;
    END_SEC=$(date +%s);
    COST_SEC=$[ $END_SEC-$START_SEC ];
    echo "Kernel Build Costed $(($COST_SEC/60))min $(($COST_SEC%60))s"

}

generate_flashable(){
    echo "------------------------------";
    echo " Generating Flashable Kernel";
    echo "------------------------------";

    AK3_PATH=$TARGET_OUT/ak3
    REC_RES=(focaltech_touch.ko goodix_core.ko hwid.ko msm_drm.ko xiaomi_touch.ko)
 
    echo ' Removing old package file ';
    rm -rf $AK3_PATH;

    echo ' Getting AnyKernel ';
    cp -r ./tools/ak3 $AK3_PATH;
    mkdir -p $TARGET_OUT/./ak3/vendor_ramdisk/lib/modules

    cd $TARGET_OUT;
    ANYKERNEL_PATH=./ak3

    echo ' Copying Kernel File '; 
    cp -r $TARGET_KERNEL_FILE $ANYKERNEL_PATH/;
    cp -r $TARGET_KERNEL_DTB $ANYKERNEL_PATH/;
    cp -r $TARGET_KERNEL_DTBO $ANYKERNEL_PATH/;
    cp -r $TARGET_VENDOR_DLKM $ANYKERNEL_PATH/;
    for item in ${REC_RES[*]}; do
        find vendor_dlkm/ -name $item -exec cp {} ./ak3/vendor_ramdisk/lib/modules \;
    done

    echo ' Packaging flashable Kernel ';
    cd $ANYKERNEL_PATH;
    zip -q -r $TARGET_KERNEL_NAME-$CURRENT_TIME-$TARGET_KERNEL_MOD_VERSION.zip *;

   echo " Target File:  $TARGET_OUT/$ANYKERNEL_PATH/$TARGET_KERNEL_NAME-$CURRENT_TIME-$TARGET_KERNEL_MOD_VERSION.zip ";

   cd $KSOURCE
}

save_defconfig(){
    echo "------------------------------";
    echo " Saving kernel config ........";
    echo "------------------------------";

    make $FINAL_KERNEL_BUILD_PARA savedefconfig;
    END_SEC=$(date +%s);
    COST_SEC=$[ $END_SEC-$START_SEC ];
    echo "Finished. Kernel config saved to $TARGET_OUT/defconfig"
    echo "Moving kernel defconfig to source tree"
    mv $TARGET_OUT/defconfig $DEFCONFIG_PATH/$TARGET_DEVICE_DEFCONFIG_NAME
    echo "Kernel Config Build Costed $(($COST_SEC/60))min $(($COST_SEC%60))s"

}

update_gki_defconfig(){
    echo "------------------------------";
    echo "Updating GKI defconfig........";
    echo "------------------------------";
    
    ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- REAL_CC=clang CC=clang CLANG_TRIPLE=aarch64-linux-gnu- LD=ld.lld LLVM=1 scripts/gki/generate_defconfig.sh vendor/lahaina-qgki_defconfig;
}

clean(){
    echo "Clean source tree and build files..."
    make mrproper -j$THREAD;
    make clean -j$THREAD;
    rm -rf $TARGET_OUT;
}

update_gki_defconfig(){
    echo "Updating lahaina-qgki_defconfig from latest source"
    ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- REAL_CC=clang CC=clang CLANG_TRIPLE=aarch64-linux-gnu- LD=ld.lld LLVM=1 scripts/gki/generate_defconfig.sh    vendor/lahaina-qgki_defconfig
}

generate_modules(){
    MODULES_DIR=$TARGET_OUT/modules_inst
    mkdir -p $MODULES_DIR
    make $FINAL_KERNEL_BUILD_PARA INSTALL_MOD_PATH=modules_inst INSTALL_MOD_STRIP=1 modules_install
}

build_vendor_dlkm(){
    echo "------------------------------";
    echo "Generating vendor_dlkm.img ...";
    echo "------------------------------";

    MKE2FS_CONF=$(pwd)/scripts/dlkm/mke2fs.conf
    KSOURCE=$(pwd)

    rm -rf $TARGET_OUT/modules_inst
    
    echo "-1 Modules installing"
    generate_modules

    cd $TARGET_OUT
    loaddeps=(modules.dep modules.softdep modules.alias)

    mkdir -p vendor_dlkm/lib/modules vendor_dlkm/etc

    find ./modules_inst/lib/modules/5.4* -name "*.ko" -exec cp {} ./vendor_dlkm/lib/modules/ \;
    for items in ${loaddeps[*]}; do
        find ./modules_inst/lib/modules/5.4* -name "$items" -exec cp {} ./vendor_dlkm/lib/modules \;
    done
    cp -r $KSOURCE/scripts/dlkm/etc/* ./vendor_dlkm/etc/
    
    echo "-2 Processing modules dependencies"
    sed -i 's/\(kernel\/[^: ]*\/\)\([^: ]*\.ko\)/\/vendor\/lib\/modules\/\2/g' vendor_dlkm/lib/modules/modules.dep
    
    echo "-3 Creating vendor_dlkm image"
    dd if=/dev/zero of=$TARGET_OUT/vendor_dlkm.img bs=1M count=128
    MKE2FS_CONFIG=$MKE2FS_CONF mke2fs -O "extent huge_file" -T largefile -L vendor_dlkm -d vendor_dlkm vendor_dlkm.img
    e2fsck -f vendor_dlkm.img
    resize2fs -M vendor_dlkm.img

    cd $KSOURCE
}

use_prebuilt_dlkm(){
    DLKM_BUILD_PATH=/srv/media/WD/pe/out/target/product/renoir/obj/PACKAGING/target_files_intermediates/aosp_renoir-target_files-eng.credits/IMAGES/
    cp $DLKM_BUILD_PATH/$TARGET_VENDOR_DLKM $TARGET_OUT
}

ksu_prepare(){
    ./scripts/config --file $TARGET_OUT/.config -e CONFIG_KSU
}

main(){
    if [ $1 == "help" -o $1 == "-h" ]
    then
        echo "build.sh: A very simple Kernel build helper"
        echo "usage: build.sh <build option>"
        echo
        echo "Build options:"
        echo "    all             Perform a build without cleaning."
        echo "    cleanbuild      Clean the source tree and build files then perform a all build."
        echo
        echo "    flashable       Only generate the flashable zip file. Don't use it before you have built once."
        echo "    savedefconfig   Save the defconfig file to source tree."
        echo "    kernelonly      Only build kernel image"
        echo "    defconfig       Only build kernel defconfig"
        echo "    upgkidefconf    Update GKI defconfig for lahaina"
        echo "    help ( -h )     Print help information."
        echo
    elif [ $1 == "savedefconfig" ]
    then
        save_defconfig;
    elif [ $1 == "cleanbuild" ]
    then
        clean;
        make_defconfig;
        build_kernel;
        link_all_dtb_files;
        use_prebuilt_dlkm;
        generate_flashable;
    elif [ $1 == "flashable" ]
    then
        generate_flashable;
    elif [ $1 == "kernelonly" ]
    then
        make_defconfig
        build_kernel
    elif [ $1 == "all" ]
    then
        make_defconfig
        build_kernel
        link_all_dtb_files
        use_prebuilt_dlkm
        generate_flashable
    elif [ $1 == "defconfig" ]
    then
        make_defconfig;
    elif [ $1 == "upgkidefconf" ]
    then
        update_gki_defconfig
    elif [ $1 == "buildksu" ]
    then
        make_defconfig
        ksu_prepare
        build_kernel
        link_all_dtb_files
        use_prebuilt_dlkm
        generate_flashable
        git checkout HEAD .
    elif [ $1 == "build_dlkm" ]
    then
        use_prebuilt_dlkm
    else
        echo "Incorrect usage. Please run: "
        echo "  bash build.sh help (or -h) "
        echo "to display help message."
    fi
}

main "$1";
