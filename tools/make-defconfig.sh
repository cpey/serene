#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>

TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
source $TOOLS_DIR/helper.sh

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -a|--arch)
            arch="$2"
            shift
            shift
            ;;
        -d|--defconfig)
            defconfig="$2"
            shift
            shift
            ;;
        -l|--linux-src)
            srctree="$2"
            shift
            shift
            ;;
        *)
            echo "Invalid argument"
            exit 1
            ;;
    esac
done

if [[ -n $srctree ]]; then
    LINUX_SRC=$srctree
else
    LINUX_SRC=$TOOLS_DIR/../src/linux
fi

arch=$(get_arch $arch)
export ARCH=$arch

CWD=`pwd`
cd $LINUX_SRC
if [[ ! -n $defconfig ]]; then
    if [[ $arch == x86 ]]; then
        defconfig="x86_64_defconfig"
    else
        defconfig="defconfig"
    fi
else
    make savedefconfig
    cp defconfig arch/$arch/configs/$defconfig
fi

make defconfig
make $defconfig
make kvm_guest.config
