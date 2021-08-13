# serene
Collection of scripts to automate VM creation for testing Linux kernel builds.

## Workflow example

1. Pull the Linux source code
```
$ git submodule update --init -- src/linux
```
2. Create rootfs and local configurations
```
$ ./tools/create-rootfs.sh
```
3. Make default kernel config 
```
$ ./tools/make-defconfig.sh
```
4. Build the Linux kernel
```
$ ./tools/build-kernel.sh
```
5. Start VM
```
$ ./tools/start-vm.sh
```
6. SSH into vm
```
$ ssh test
```
7. Stop VM
```
$ ./tools/stop-vm.sh
```

## Arguments to the VM

Optional arguments to `start-vm.sh`:

```
-c: CPU security related parameters (smep, smap)
-k: Kernel security (kpti=1, kaslr)
```

Examples:

```
$ ./tools/start-vm.sh -c smep
$ ./tools/start-vm.sh -c smap
$ ./tools/start-vm.sh -c smep,smap
$ ./tools/start-vm.sh -k kpti=1
$ ./tools/start-vm.sh -k kaslr
$ ./tools/start-vm.sh -k kpti=1,kaslr
$ ./tools/start-vm.sh -c smep,smap -k kpti=1,kaslr
```
