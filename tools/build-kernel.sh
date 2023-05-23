#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>


TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
source $TOOLS_DIR/helper.sh

name=''
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
        -n|--kernel-name)
            name="$2"
            shift
            shift
            ;;
        -s|--start-vm)
            startvm=1
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
pushd $LINUX_SRC

arch=$(get_arch $arch)
export ARCH=$arch

if [[ -n $defconfig ]]; then
    make $defconfig
fi
make -j`nproc`

if [[ ! $? -eq 0 ]]; then
    exit -1
fi

stoparg=""
if [[ -n $startvm ]]; then
    stoparg="--reboot"
fi

popd
$TOOLS_DIR/copy-linux-build.sh -l $LINUX_SRC -n $name -a $arch
$TOOLS_DIR/stop-vm.sh $stoparg
