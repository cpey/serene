#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# (C) 2021 Carles Pey <cpey@pm.me>

TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
LINUX_SRC=$TOOLS_DIR/../src/linux

CWD=`pwd`

cd $LINUX_SRC
make defconfig
make x86_64_defconfig
make kvm_guest.config
