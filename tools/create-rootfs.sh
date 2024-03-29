#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021 Carles Pey <cpey@pm.me>

set -ex
TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
source $TOOLS_DIR/config.sh
source $TOOLS_DIR/helper.sh
BASE=$TOOLS_DIR/../rootfs
IMG=$BASE/$ROOTFS_IMG
DIR=$BASE/mount-point.dir

if [[ ! -d $BASE ]]; then
    mkdir $BASE
fi

if [[ ! -d $DIR ]]; then
    mkdir $DIR
fi

# Setup SSH key
SSH_CONFIG_FILE=~/.ssh/config
SSH_KEY=~/.ssh/$SSH_KEY_NAME
SSH_CONFIG=$(cat <<-EOM

Host $VM_HOSTNAME
    Hostname localhost
    Port $VM_PORT
    User $USER
    IdentityFile $SSH_KEY
EOM
)

if [[ ! -e $SSH_KEY ]]; then
    ssh-keygen -t ed25519 -f $SSH_KEY -N ''
    [[ ! -e $SSH_CONFIG_FILE ]] && cp $SSH_CONFIG_FILE $SSH_CONFIG_FILE.old
    echo "$SSH_CONFIG" >> $SSH_CONFIG_FILE
fi
SSH_KEY_PUB=$(cat $SSH_KEY.pub)

# Create image
qemu-img create $IMG 2g
mkfs.ext4 $IMG
DEVICE=$(losetup -l | grep $(basename $IMG) | cut -d' ' -f1)
[[ ! $DEVICE == '' ]] && sudo umount $DEVICE
sudo mount -o loop $IMG $DIR
sudo debootstrap --arch $VM_ARCH $DEBIAN_VERSION $DIR

# VM configuration
INSTALL_PKG=(
    openssh-server
    sudo
    net-tools
    build-essential
    libc6-dev
    libc6-dev-i386
    gdb
    strace
    haveged
)
INSTALL_PKG_CMD="apt install"
for pkg in "${INSTALL_PKG[@]}"; do
    INSTALL_PKG_CMD="${INSTALL_PKG_CMD} $pkg"
done

CONFIG_CMDS=(
    "$INSTALL_PKG_CMD"
    "passwd"
    "adduser --disabled-password --gecos \"\" $USER"
    "echo $USER:$PASSWD | chpasswd"
    "usermod -aG sudo $USER"
    "usermod -aG systemd-journal $USER"
    "echo \"$USER    ALL= NOPASSWD: ALL\" >> /etc/sudoers"
    "echo -e \"allow-hotplug enp0s3\niface enp0s3 inet dhcp\" >> /etc/network/interfaces"
    "mkdir /home/$USER/.ssh"
    "echo $SSH_KEY_PUB > /home/$USER/.ssh/authorized_keys"
    "echo $VM_HOSTNAME > /etc/hostname"
    "echo 127.0.1.1 $VM_HOSTNAME >> /etc/hosts"
    "echo \"kernel.perf_event_paranoid=1\" >> /etc/sysctl.d/99-sysctl.conf"
    "sed -Ei 's/(Options=).*/\1mode=0755/' /usr/lib/systemd/system/sys-kernel-debug.mount"
)

for cmd in "${CONFIG_CMDS[@]}"; do
    while
        sudo chroot $DIR /bin/bash -c "$cmd"
        :; [[ $? -ne 0 ]]
    do :; done
done

# Remove previous build ssh server public key fingerprint
cp  ~/.ssh/known_hosts ~/.ssh/known_hosts.old
sed -i "/^\[localhost\]:$VM_PORT .*$/d" ~/.ssh/known_hosts

sudo umount $DIR
rmdir $DIR

