#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -d|--default)
            defconfig=1
            shift
            ;;
        -s|--start-vm)
            startvm=1
            shift
            ;;
        -l|--linux-src)
            srctree=$2
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
if [[ -v srctree ]]; then
    LINUX_SRC=$srctree
else
    LINUX_SRC=$TOOLS_DIR/../src/linux
fi
CWD=$(pwd)

cd $LINUX_SRC
if [[ -v defconfig ]]; then
    yes "" | make -j`nproc`
else
    make -j`nproc`
fi

if [[ ! $? -eq 0 ]]; then
    exit -1
fi

stoparg=""
if [[ -n $startvm ]]; then
    stoparg="--reboot"
fi

cd $CWD
$TOOLS_DIR/copy-linux-build.sh -l $LINUX_SRC
$TOOLS_DIR/stop-vm.sh $stoparg -l $LINUX_SRC
