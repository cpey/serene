#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>


while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
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
    TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
    LINUX_SRC=$TOOLS_DIR/../src/linux
fi
CWD=`pwd`

cd $LINUX_SRC
make defconfig
make x86_64_defconfig
make kvm_guest.config
