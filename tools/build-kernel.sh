#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# (C) 2021 Carles Pey <cpey@pm.me>

TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
LINUX_SRC=$TOOLS_DIR/../src/linux
CWD=$(pwd)

cd $LINUX_SRC
make -j`nproc`
if [[ ! $? -eq 0 ]]; then
    exit -1
fi

cd $CWD
$TOOLS_DIR/copy-linux-build.sh
$TOOLS_DIR/stop-vm.sh
$TOOLS_DIR/start-vm.sh
