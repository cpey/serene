#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# (C) 2021 Carles Pey <cpey@pm.me>

set -x
TOOLS_DIR=$(echo $0 | sed  "s/\(.*\)\(\/.*\)/\1/g")
source $TOOLS_DIR/config.sh
BASE=$TOOLS_DIR/../rootfs
IMG=$BASE/$ROOTFS_IMG
DIR=$BASE/mount-point.dir
HASHED_PASSWD=$(openssl passwd -crypt $PASSWD)

if [[ ! -d $BASE ]]; then
    mkdir $BASE
fi

if [[ ! -d $DIR ]]; then
    mkdir $DIR
fi

# Setup SSH key
SSH_KEY=~/.ssh/$SSH_KEY_NAME
SSH_CONFIG=$(cat <<-EOM

Host $VM_NAME
    Hostname localhost
    Port $VM_PORT
    User $USER
    IdentityFile $SSH_KEY
EOM
)

if [[ ! -e $SSH_KEY ]]; then
    ssh-keygen -t ed25519 -f $SSH_KEY -N ''
    cp ~/.ssh/config ~/.ssh/config.old
    echo "$SSH_CONFIG" >> ~/.ssh/config
fi
SSH_KEY_PUB=$(cat $SSH_KEY.pub)

# Create image
qemu-img create $IMG 1g
mkfs.ext4 $IMG
sudo mount -o loop $IMG $DIR
sudo debootstrap --arch $VM_ARCH $DEBIAN_VERSION $DIR

# Configure the image
CONFIG_CMDS=(
    "passwd"
    "adduser --disabled-password --gecos \"\" $USER"
    "echo $USER:$PASSWD | chpasswd"
    "apt install openssh-server sudo net-tools"
    "usermod -aG sudo $USER"
    "echo \"$USER    ALL= NOPASSWD: ALL\" >> /etc/sudoers"
    "echo -e \"allow-hotplug enp0s3\niface enp0s3 inet dhcp\" >> /etc/network/interfaces"
    "mkdir /home/$USER/.ssh"
    "echo $SSH_KEY_PUB > /home/$USER/.ssh/authorized_keys"
)

for cmd in "${CONFIG_CMDS[@]}"; do
    sudo chroot $DIR /bin/bash -c "$cmd"
done

sudo umount $DIR
rmdir $DIR
