# serene
Collection of scripts to automate VM creation for testing Linux kernel builds.

## Workflow example

1. Create rootfs and host configurations
```
$ ./tools/create-rootfs.sh
```
2. Pull the Linux source code
```
$ git submodule update --init -- src/linux
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
-d: Launch in debug mode
-w: Wait for gdb to attach
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

## Debugging the Linux kernel

Launch the vm in debug mode:

```
[cpey@nuc dev]$ ./tools/start-vm.sh -d -w
QEMU 4.2.1 monitor - type 'help' for more information
```

and connect a gdb client:

```
[cpey@nuc linux]$ gdb -q vmlinux
Reading symbols from vmlinux...
(gdb) target remote :1234
Remote debugging using :1234
kgdb_breakpoint () at kernel/debug/debug_core.c:1196
1196            wmb(); /* Sync point after breakpoint */
(gdb)
```

Serene uses kgdb since Qemu gdb server does not take care of interrupts while debugging. The kernel will need to be built the following .config options:

```
CONFIG_KGDB=y
CONFIG_KGDB_SERIAL_CONSOLE=y
```

When the vm is launched without the `-w` flag, execute the following command from within the vm to enter kgdb before attaching the gdb client:

```
test@test:~$ sudo sh -c "echo g > /proc/sysrq-trigger"
```
