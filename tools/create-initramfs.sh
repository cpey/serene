#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>

TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
INITRAMFS_DIR=$TOOLS_DIR/../initramfs/
INITRAMFS_TREE=$INITRAMFS_DIR/x86-busybox
INITRAMFS_CPIO=initramfs-busybox-x86.cpio.gz
BUSYBOX=$TOOLS_DIR/../src/busybox/_install

# initramfs
rm -r $INITRAMFS_TREE
mkdir -p $INITRAMFS_TREE
cd $INITRAMFS_TREE
mkdir -pv {bin,sbin,etc,proc,sys,usr/{bin,sbin}}
cp -av $BUSYBOX/* .

# init
cat > $INITRAMFS_TREE/init << EOF
#!/bin/sh

mount -t proc none /proc
mount -t sysfs none /sys

echo -e "\nBoot took $(cut -d' ' -f1 /proc/uptime) seconds\n"

exec /bin/sh
EOF
chmod +x $INITRAMFS_TREE/init

# generate cpio
find . -print0 \
    | cpio --null -ov --format=newc \
    | gzip -9 > $INITRAMFS_DIR/$INITRAMFS_CPIO
