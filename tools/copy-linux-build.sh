#!/bin/sh

TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
LINUX_SRC=$TOOLS_DIR/../src/linux
LINUX_IMG=$LINUX_SRC/arch/x86_64/boot/bzImage
BUILD_DIR=$TOOLS_DIR/../build
OUTDIR=$BUILD_DIR/linux/arch/x86_64/boot

if [[ -d $OUTDIR ]]; then
    rm -r $OUTDIR
fi
 
mkdir -p $OUTDIR
cp $LINUX_IMG $OUTDIR
