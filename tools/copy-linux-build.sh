#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>


while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -a|--arch)
            arch="$2"
            shift
            shift
            ;;
        -l|--linux-src)
            srctree="$2"
            shift
            shift
            ;;
        -n|--kernel-name)
            name="$2"
            shift
            shift
            ;;
        *)
            echo "Invalid argument"
            exit 1
            ;;
    esac
done

TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
source $TOOLS_DIR/helper.sh

if [[ -n $srctree ]]; then
    LINUX_SRC=$srctree
else
    LINUX_SRC=$TOOLS_DIR/../src/linux
fi

if [[ -n $name ]]; then
    SUFFIX=$name
else
    SUFFIX=$(get_path_hash $LINUX_SRC)
fi

arch=$(get_arch $arch)
if [[ $arch == x86 ]]; then
    $arch=x86_64
    BZIMAGE=$LINUX_SRC/arch/$arch/boot/bzImage
else
    BZIMAGE=$LINUX_SRC/arch/arm64/boot/Image
fi

BUILD_DIR=$TOOLS_DIR/../build
OUTDIR=$BUILD_DIR/linux/arch/$arch/boot
VMLINUX=$LINUX_SRC/vmlinux

if [[ ! -d $OUTDIR ]]; then
    mkdir -p $OUTDIR
fi
 
cp $BZIMAGE $OUTDIR/bzImage-$SUFFIX
cp $VMLINUX $OUTDIR/vmlinux-$SUFFIX
