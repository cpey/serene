#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>

set -ex
TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
source $TOOLS_DIR/config.sh
BASE=$TOOLS_DIR/../rootfs
MOUNT_DIR=$BASE/mount-point.dir

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -n|--kernel-name)
            name="$2"
            shift
            shift
            ;;
        -r|--root-fs)
            rootfs="$2"
            shift
            shift
            ;;
        *)
            echo "Invalid argument"
            exit 1
            ;;
    esac
done

if [[ ! -n $name ]]; then
    echo "Please specify build name"
    exit -1
fi

if [[ ! -n $rootfs ]]; then
    echo "Please specify rootfs"
    exit -1
fi

version=$(head -n 3 $TOOLS_DIR/../build/linux/arch/x86_64/boot/config-$name | tail -n 1 | sed 's/.*Linux\/x86 \([0-9.]*\).*/\1/')
sudo mount -o loop $rootfs $MOUNT_DIR

USR_SRC_HEADER_PATH=$MOUNT_DIR/usr/src/linux-headers-$version
[[ -d $USR_SRC_HEADER_PATH ]] && sudo rm -rf $USR_SRC_HEADER_PATH
sudo mkdir -p sudo mkdir -p $USR_SRC_HEADER_PATH
sudo tar xzvf $TOOLS_DIR/../build/linux/arch/x86_64/boot/headers-base-$name.tgz -C $USR_SRC_HEADER_PATH
sudo tar xzvf $TOOLS_DIR/../build/linux/arch/x86_64/boot/headers-arch-$name.tgz -C $USR_SRC_HEADER_PATH

LIB_MODULES_PATH=$MOUNT_DIR/lib/modules/$version
[[ -d $LIB_MODULES_PATH ]] && sudo rm -rf $LIB_MODULES_PATH
sudo mkdir -p $LIB_MODULES_PATH
sudo ln -s /usr/src/linux-headers-$version $LIB_MODULES_PATH/build

sudo umount $MOUNT_DIR
