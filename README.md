# insta360-one-rs-1-inch-360-edition-linux-info
linux related informations about the Insta360 One RS 1-Inch 360 Edition

Recently I bought an "https://github.com/Insta360Develop/CameraSDK-Cpp". Mostly for outdoors, but after I found
[this official library](https://github.com/Insta360Develop/CameraSDK-Cpp), I was also interested in working on it under linux.
The project requires a SDK, which is hidden for whatever reason behind a [registration system](https://www.insta360.com/de/sdk/home).
At the time of writing I'm [still waiting](https://github.com/Insta360Develop/CameraSDK-Cpp/issues/16#issuecomment-1402361583) for my registration to be approved, but fortunately I found something possibly more interesting meanwhile, so they can keep their SDK:

The "Insta360 One RS 1-Inch 360 Edition" itself is running Linux - and even better, it is very simple to enter it:

Simply connect to the AP it opens _(`ONE RS XXXXXX.OSC`)_ with the default password "88888888".
The device has multiple open ports _(see [nmap](#nmap))_, but the most interesting _(for now)_ is port `23`, means telnet is running.
_(my device has the firmware `2.0.8` currently, so this might change later)_

I was prepared to brute force the `root` password, but I didn't get far - the `root` login is **passwordless!**:

```
telnet  192.168.42.1
Trying 192.168.42.1...
Connected to 192.168.42.1.
Escape character is '^]'.

AmbaLink login: root
~# 
```

Where to go from here?

**See separate README.me in the SD0 subdirectory**

Not sure yet, but it is simple to copy all systemfiles to the internal sdcard for later examination without the need to keep the camera running.

Looking at some random files it seems to be very likely that the system is related to the firmware also used in other action cams, and a quick github search leads you to this [ambarella-h22-firmware-tools](https://github.com/RigacciOrg/ambarella-h22-firmware-tools) project, which possibly is able to extract and repack the firmware _(haven't tried that yet)_

Here are some loose stdouts I saved yesterday while crawling through the OS.
Most system files are stored on my system so I might add some more information later.
If you have any questions and/or are interesting on creating a project around the system, please let me know.

# custom boot script built in
Heh, the init script
`init.d/S99bootdone` already starts the custom script `/tmp/SD0/bootup.sh` from the sdcard when found :)


```
# cat init.d/S99bootdone 
#!/bin/sh

echo 'S99bootdone is running...'

#send boot_done to RTOS
if [ -x /usr/bin/SendToRTOS ]; then
	/usr/bin/SendToRTOS boot_done
fi

echo 'S99bootdone' > /sys/module/rpmsg_echo/parameters/example_printk

#setup for each individual board
if [ -x /tmp/SD0/bootup.sh ]; then
	/tmp/SD0/bootup.sh
fi

#auto-run if file exists
if [ -x /mnt/SCAM/cv1_auto_run.sh ]; then
       echo 'Auto-run user script...'
       /mnt/SCAM/cv1_auto_run.sh
fi


if [ -x /usr/bin/instaAIP ]; then
	/usr/bin/instaAIP
fi

exit $?

```



# busybox

```
~# busybox 
BusyBox v1.25.0 (2022-11-29 18:51:59 CST) multi-call binary.
BusyBox is copyrighted by many authors between 1998-2015.
Licensed under GPLv2. See source distribution for detailed
copyright notices.

Usage: busybox [function [arguments]...]
   or: busybox --list[-full]
   or: busybox --install [-s] [DIR]
   or: function [arguments]...

        BusyBox is a multi-call binary that combines many common Unix
        utilities into a single executable.  Most people will create a
        link to busybox for each function they wish to use and BusyBox
        will act like whatever it was invoked as.

Currently defined functions:
        [, [[, addgroup, adduser, ar, arp, arping, ash, awk, basename, blkid, bunzip2, bzcat, cat, catv, chattr, chgrp, chmod, chown, chroot, chrt, chvt, cksum, clear, cmp, cp, cpio, crond,
        crontab, cut, date, dc, dd, deallocvt, delgroup, deluser, devmem, df, diff, dirname, dmesg, dnsd, dnsdomainname, dos2unix, du, dumpkmap, echo, egrep, eject, env, ether-wake, expr, false,
        fbset, fdflush, fdformat, fdisk, fgrep, find, flock, fold, free, freeramdisk, fsck, fstrim, fuser, getopt, getty, grep, gunzip, gzip, halt, hdparm, head, hexdump, hostid, hostname, hwclock,
        i2cdetect, i2cdump, i2cget, i2cset, id, ifconfig, ifdown, ifup, inetd, init, insmod, install, ip, ipaddr, ipcrm, ipcs, iplink, iproute, iprule, iptunnel, kill, killall, killall5, klogd,
        last, less, linux32, linux64, linuxrc, ln, loadfont, loadkmap, logger, login, logname, losetup, ls, lsattr, lsmod, lsof, lspci, lsusb, lzcat, lzma, makedevs, md5sum, mdev, mesg, microcom,
        mkdir, mkfifo, mknod, mkpasswd, mkswap, mktemp, modprobe, more, mount, mountpoint, mt, mv, nameif, netstat, nice, nohup, nslookup, od, openvt, passwd, patch, pidof, ping, pipe_progress,
        pivot_root, poweroff, printenv, printf, ps, pwd, rdate, readlink, readprofile, realpath, reboot, renice, reset, resize, rm, rmdir, rmmod, route, run-parts, runlevel, sed, seq, setarch,
        setconsole, setkeycodes, setlogcons, setserial, setsid, sh, sha1sum, sha256sum, sha3sum, sha512sum, sleep, sort, start-stop-daemon, strings, stty, su, sulogin, swapoff, swapon, switch_root,
        sync, sysctl, syslogd, tail, tar, taskset, tee, telnet, telnetd, test, tftp, time, top, touch, tr, traceroute, true, truncate, tty, ubirename, udhcpc, uevent, umount, uname, uniq, unix2dos,
        unlink, unlzma, unxz, unzip, uptime, usleep, uudecode, uuencode, vconfig, vi, vlock, watch, watchdog, wc, wget, which, who, whoami, xargs, xz, xzcat, yes, zcat
```

# proc cmdline
```
# cat /proc/cmdline 
root=/dev/mtdblock5 rootfstype=squashfs nr_cpus=4 maxcpus=4 swiotlb=1024
```

# proc cpuinfo
```
~# cat /proc/cpuinfo 
processor       : 0
BogoMIPS        : 123.00
Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32
CPU implementer : 0x41
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0xd03
CPU revision    : 4
```

# filesystem

```
~# df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/root                13.9M     13.9M         0 100% /
devtmpfs                 24.2M         0     24.2M   0% /dev
tmpfs                    32.4M         0     32.4M   0% /dev/shm
tmpfs                    32.4M      5.8M     26.6M  18% /tmp
tmpfs                    32.4M     28.0K     32.4M   0% /run
a:                       94.7M      2.0M     92.7M   2% /tmp/FL0
c:                      476.7G    535.0M    476.1G   0% /tmp/SD0
a:                       94.7M      2.0M     92.7M   2% /pref
```

# dmesg
```
# dmesg
[    0.000000] Booting Linux on physical CPU 0x3
[    0.000000] Linux version 4.9.76 (paul@dell-PowerEdge-R740) (gcc version 5.3.1 20160113 (Linaro GCC 5.3-2016.02) ) #1 SMP PREEMPT Tue Nov 29 18:53:48 CST 2022
[    0.000000] Boot CPU: AArch64 Processor [410fd034]
[    0.000000] cma: Reserved 16 MiB at 0x000000007f000000
[    0.000000] On node 0 totalpages: 23040
[    0.000000]   DMA zone: 360 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 23040 pages, LIFO batch:3
[    0.000000] psci: probing for conduit method from DT.
[    0.000000] psci: PSCIv1.0 detected in firmware.
[    0.000000] psci: Using standard PSCI v0.2 function IDs
[    0.000000] psci: MIGRATE_INFO_TYPE not supported.
[    0.000000] percpu: Embedded 20 pages/cpu @ffffffc07ef80000 s44544 r8192 d29184 u81920
[    0.000000] pcpu-alloc: s44544 r8192 d29184 u81920 alloc=20*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1 [0] 2 [0] 3 
[    0.000000] Detected VIPT I-cache on CPU0
[    0.000000] CPU features: enabling workaround for ARM erratum 845719
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 22680
[    0.000000] Kernel command line: root=/dev/mtdblock5 rootfstype=squashfs nr_cpus=4 maxcpus=4 swiotlb=1024
[    0.000000] PID hash table entries: 512 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.000000] Inode-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.000000] Memory: 49636K/92160K available (5182K kernel code, 502K rwdata, 1684K rodata, 320K init, 1272K bss, 26140K reserved, 16384K cma-reserved)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     modules : 0xffffff8000000000 - 0xffffff8008000000   (   128 MB)
[    0.000000]     vmalloc : 0xffffff8008000000 - 0xffffffbebfff0000   (   250 GB)
[    0.000000]       .text : 0xffffff8008080000 - 0xffffff8008590000   (  5184 KB)
[    0.000000]     .rodata : 0xffffff8008590000 - 0xffffff8008740000   (  1728 KB)
[    0.000000]       .init : 0xffffff8008740000 - 0xffffff8008790000   (   320 KB)
[    0.000000]       .data : 0xffffff8008790000 - 0xffffff800880d808   (   503 KB)
[    0.000000]        .bss : 0xffffff800880d808 - 0xffffff800894ba98   (  1273 KB)
[    0.000000]     fixed   : 0xffffffbefe7fd000 - 0xffffffbefec00000   (  4108 KB)
[    0.000000]     PCI I/O : 0xffffffbefee00000 - 0xffffffbeffe00000   (    16 MB)
[    0.000000]     vmemmap : 0xffffffbf00000000 - 0xffffffc000000000   (     4 GB maximum)
[    0.000000]               0xffffffbf01e98000 - 0xffffffbf02000000   (     1 MB actual)
[    0.000000]     memory  : 0xffffffc07a600000 - 0xffffffc080000000   (    90 MB)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 64.
[    0.000000] NR_IRQS:64 nr_irqs:64 0
[    0.000000] CPU features: GIC system register CPU interface present but disabled by higher exception level
[    0.000000] arm_arch_timer: Architected cp15 timer(s) running at 61.50MHz (virt).
[    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x1c5e18e9b3, max_idle_ns: 881590408172 ns
[    0.000004] sched_clock: 56 bits at 61MHz, resolution 16ns, wraps every 4398046511101ns
[    0.000180] Console: colour dummy device 80x25
[    0.000773] console [tty0] enabled
[    0.000858] Calibrating delay loop (skipped), value calculated using timer frequency.. 123.00 BogoMIPS (lpj=246000)
[    0.000891] pid_max: default: 32768 minimum: 301
[    0.000978] Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
[    0.000998] Mountpoint-cache hash table entries: 512 (order: 0, 4096 bytes)
[    0.001723] ASID allocator initialised with 65536 entries
[    0.068348] psci: failed to boot CPU1 (-22)
[    0.068380] CPU1: failed to boot: -22
[    0.068400] CPU1: failed in unknown state : 0x0
[    0.096411] psci: failed to boot CPU2 (-22)
[    0.096439] CPU2: failed to boot: -22
[    0.096458] CPU2: failed in unknown state : 0x0
[    0.124479] psci: failed to boot CPU3 (-22)
[    0.124509] CPU3: failed to boot: -22
[    0.124528] CPU3: failed in unknown state : 0x0
[    0.124585] Brought up 1 CPUs
[    0.124604] SMP: Total of 1 processors activated.
[    0.124629] CPU features: detected feature: 32-bit EL0 Support
[    0.124677] CPU: All CPU(s) started at EL1
[    0.124711] alternatives: patching kernel code
[    0.125244] devtmpfs: initialized
[    0.136878] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.136931] futex hash table entries: 1024 (order: 5, 131072 bytes)
[    0.137536] pinctrl core: initialized pinctrl subsystem
[    0.137851] ambalink ppm2 memory (rtos region): 0x00020000 - 0x7a000000 (0xffffffc000020000)
[    0.137890] ambalink shm (shared memory): 0x7a000000 - 0x7a600000 (0xffffffc07a000000)
[    0.138387] NET: Registered protocol family 16
[    0.139499] vdso: 2 pages (1 code @ ffffff8008597000, 1 data @ ffffff8008795000)
[    0.140917] DMA: preallocated 256 KiB pool for atomic allocations
[    0.144076] ambarella-pinctrl e8009000.pinctrl: Ambarella pinctrl driver registered
[    0.145350] ambarella-gpio e8009000.pinctrl:gpio@0: Ambarella GPIO driver registered
[    0.156912] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.172812] aipc_spin_lock_setup: aipc_slock@0xffffffc07a436000
[    0.173043] aipc_mutex_of_init: aipc_mutex@0xffffffc07a437000
[    0.173317] Init Richtek RegMap
[    0.173558] SCSI subsystem initialized
[    0.173796] usbcore: registered new interface driver usbfs
[    0.173872] usbcore: registered new interface driver hub
[    0.174013] usbcore: registered new device driver usb
[    0.174061] tcpc_class_init (2.0.2_G)
[    0.174082] SVDM supported mode [0]: name = DisplayPort, svid = 0xff01
[    0.174103] SVDM supported mode [1]: name = Direct Charge, svid = 0x29cf
[    0.174124] dpm_check_supported_modes : found "disorder"...
[    0.174156] TCPC class init OK
[    0.174174] pd_dbg_info_init
[    0.174889] ambarella-i2c e8013000.i2c: Ambarella I2C adapter[3] probed!
[    0.175248] ambarella-rproc ambalink:ambarella-rproc: ambarella_rproc_probe device registered
[    0.175446]  remoteproc0: ambarella is available
[    0.175467]  remoteproc0: Note: remoteproc is still under development and considered experimental.
[    0.175498]  remoteproc0: THE BINARY FORMAT IS NOT YET FINALIZED, and backward compatibility isn't yet guaranteed.
[    0.175532]  remoteproc0: powering up ambarella
[    0.175553]  remoteproc0: Booting fw image dummy, size 0
[    0.175688]  remoteproc0: registered virtio0 (type 7)
[    0.175713]  remoteproc0: remote processor ambarella is now up
[    0.175876] virtio_rpmsg_bus virtio0: rpmsg host is online
[    0.177051] clocksource: Switched to clocksource arch_sys_counter
[    0.181637] virtio_rpmsg_bus virtio0: creating channel AmbaRpdev_CLK addr 0x400
[    0.181963] virtio_rpmsg_bus virtio0: creating channel aipc_rpc addr 0x401
[    0.225213] ambarella-sd e001f000.sdmmc2: Max frequency is 120000000Hz
[    0.225443] NET: Registered protocol family 2
[    0.229440] TCP established hash table entries: 1024 (order: 1, 8192 bytes)
[    0.229488] TCP bind hash table entries: 1024 (order: 2, 16384 bytes)
[    0.229528] TCP: Hash tables configured (established 1024 bind 1024)
[    0.229617] UDP hash table entries: 256 (order: 1, 8192 bytes)
[    0.229717] UDP-Lite hash table entries: 256 (order: 1, 8192 bytes)
[    0.229923] NET: Registered protocol family 1
[    0.238928] RPC: Registered named UNIX socket transport module.
[    0.238964] RPC: Registered udp transport module.
[    0.238981] RPC: Registered tcp transport module.
[    0.238997] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.246817] workingset: timestamp_bits=62 max_order=15 bucket_order=0
[    0.256126] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    0.270378] ntfs: driver 2.1.32 [Flags: R/W DEBUG].
[    0.270736] fuse init (API version 7.26)
[    0.273704] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    0.273751] io scheduler noop registered
[    0.273771] io scheduler deadline registered
[    0.274037] io scheduler cfq registered (default)
[    0.274153] Registering the rpc profile device successfully with 251
[    0.274953] virtio_rpmsg_bus virtio0: creating channel aipc_vfs addr 0x402
[    0.275231] virtio_rpmsg_bus virtio0: creating channel aipc_rfs addr 0x403
[    0.276713] virtio_rpmsg_bus virtio0: creating channel link_ctrl addr 0x404
[    0.279198] virtio_rpmsg_bus virtio0: creating channel echo_cortex addr 0x405
[    0.279484] e0032000.uart: ttyS1 at MMIO 0xe0032000 (irq = 21, base_baud = 1500000) is a ambuart
[    0.280028] Unable to detect cache hierarchy from DT for CPU 0
[    0.285218]  ram0: unable to read partition table
[    0.285488] brd: module loaded
[    0.324476] loop: module loaded
[    0.324771] Probe amba_heapmem ok
[    0.325019] Probe amba_dspmem successfully
[    0.325479] hisi_sas: driver version v1.6
[    0.325936] Ambarella read-only mtdblock
[    0.361226] ambarella-nand e0001000.nand: in ecc-[8]bit mode
[    0.418774] random: fast init done
[    0.529121] nand: device found, Manufacturer ID: 0x98, Chip ID: 0xda
[    0.529160] nand: Toshiba TC58NVG1S3H 2G 3.3V 8-bit
[    0.529182] nand: 256 MiB, SLC, erase size: 128 KiB, page size: 2048, OOB size: 128
[    0.565279] Bad block table found at page 131008, version 0x01
[    0.565476] Bad block table found at page 130944, version 0x01
[    0.565664] nand_read_bbt: bad block at 0x00000c000000
[    0.565684] nand_read_bbt: bad block at 0x00000c020000
[    0.565852] 10 ofpart partitions found on MTD device amba_nand
[    0.565874] Creating 10 MTD partitions on "amba_nand":
[    0.565902] 0x000000020000-0x000000040000 : "VENDOR_DATA"
[    0.571285] 0x000000280000-0x000002280000 : "SYS_SW"
[    0.577203] 0x000002280000-0x000002880000 : "DSP_uCode"
[    0.582663] 0x000002880000-0x000005080000 : "SYS_DATA"
[    0.588929] 0x000005080000-0x000006080000 : "LINUX_Kernel"
[    0.594499] 0x000006080000-0x000007080000 : "LINUX_RFS"
[    0.600089] 0x000007080000-0x000008400000 : "VIDEO_REC_IDX"
[    0.605731] 0x000008400000-0x000008880000 : "CALIB"
[    0.610980] 0x000008880000-0x000008c00000 : "USER_SETTING"
[    0.616149] 0x000008c00000-0x00000eea0000 : "DRIVE_A"
[    0.623870] libphy: Fixed MDIO Bus: probed
[    0.623907] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.623968] ehci-ambarella: AMBARELLA-EHCI Host Controller driver
[    0.625190] ambarella-ehci e0018000.ehci: EHCI Host Controller
[    0.625241] ambarella-ehci e0018000.ehci: new USB bus registered, assigned bus number 1
[    0.625577] ambarella-ehci e0018000.ehci: irq 23, io mem 0xe0018000
[    0.641110] ambarella-ehci e0018000.ehci: USB 2.0 started, EHCI 1.00
[    0.641389] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    0.641416] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.641447] usb usb1: Product: EHCI Host Controller
[    0.641468] usb usb1: Manufacturer: Linux 4.9.76 ehci_hcd
[    0.641490] usb usb1: SerialNumber: AmbUSB
[    0.642163] hub 1-0:1.0: USB hub found
[    0.642210] hub 1-0:1.0: 1 port detected
[    0.642682] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.642932] ambarella-ohci e0019000.ohci: Ambarella OHCI
[    0.642970] ambarella-ohci e0019000.ohci: new USB bus registered, assigned bus number 2
[    0.643074] ambarella-ohci e0019000.ohci: irq 24, io mem 0xe0019000
[    0.705303] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    0.705342] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    0.705373] usb usb2: Product: Ambarella OHCI
[    0.705394] usb usb2: Manufacturer: Linux 4.9.76 ohci_hcd
[    0.705415] usb usb2: SerialNumber: AmbUSB
[    0.706079] hub 2-0:1.0: USB hub found
[    0.706126] hub 2-0:1.0: 1 port detected
[    0.706634] usbcore: registered new interface driver cdc_acm
[    0.706656] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[    0.706769] usbcore: registered new interface driver usb-storage
[    0.706894] ambarella-udc e0006000.udc: ambarella_udc: version 21 Jan 2016
[    0.717569] rt1711h_init (2.0.1_G): initializing...
[    0.717609] rt1711h node found...
[    0.717695] rt1711_i2c_probe
[    0.717713] I2C functionality : OK...
[    0.741083] ambarella-i2c e8013000.i2c: No ACK from address 0x9c, 0:0!
[    0.765116] ambarella-i2c e8013000.i2c: No ACK from address 0x9c, 0:0!
[    0.789110] ambarella-i2c e8013000.i2c: No ACK from address 0x9c, 0:0!
[    0.813076] ambarella-i2c e8013000.i2c: No ACK from address 0x9c, 0:0!
[    0.837086] ambarella-i2c e8013000.i2c: No ACK from address 0x9c, 0:0!
[    0.837219] rt1711h 3-004e: read chip ID fail
[    0.837258] rt1711h: probe of 3-004e failed with error -5
[    0.837763] ambarella-rtc e8015000.rtc: rtc core: registered e8015000.rtc as rtc0
[    0.837799] ambarella-rtc e8015000.rtc: Warning: RTC lost power.....
[    0.837822] ambarella-rtc e8015000.rtc: ambrtc_set_mmss is not supported in dual-OSes!
[    0.838010] i2c /dev entries driver
[    0.838523] usbcore: registered new interface driver usbhid
[    0.838545] usbhid: USB HID core driver
[    0.838842] virtio_rpmsg_bus virtio0: creating channel rpmsg_insta360_comm addr 0x406
[    0.839080] [INSTA]<0365:rpmsg_insta360_comm_probe> rpmsg_insta360_comm_probe in, backup rpdev
[    0.839478] Initializing XFRM netlink socket
[    0.839520] NET: Registered protocol family 17
[    0.839656] Key type dns_resolver registered
[    0.842818] console [netcon0] enabled
[    0.842848] netconsole: network logging started
[    0.843060] rt_charger_probe
[    0.843232] Error: failed to get named rt,vbus_gpio 
[    0.843260] rt-charger rt_charger: get rt1711-tcpc fail
[    0.843460] ambarella-rtc e8015000.rtc: setting system clock to 2023-01-25 20:33:43 UTC (1674678823)
[    1.262522] VFS: Mounted root (squashfs filesystem) readonly on device 31:5.
[    1.263648] devtmpfs: mounted
[    1.263947] Freeing unused kernel memory: 320K
[    2.011016] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    2.100508] ambarella-nand e0001000.nand: BCH correct [1]bit in block[815]
[    2.167471] amba_phys_mem_access_prot: set as noncached
[    2.182760] amba_phys_mem_access_prot: set as noncached
[    2.200753] amba_phys_mem_access_prot: set as noncached
[    2.713242] [hdq_open] hdq_open...
[    2.713301] [hdq_ioctl] set hdq proto mode 0
[    2.744957] [hdq_read] type: 0xffff, capacity:80, voltage: 4119mV, average_current:-665
[    2.747792] sgm7220_init (1.0): initializing...
[    2.747839] sgm7220 device tree node found...
[    2.748012] sgm7220_i2c_probe
[    2.748032] I2C functionality : OK...
[    2.748052] sgm7220_parse_dt
[    2.748215] 0x30
[    2.748350] 0x32
[    2.748482] 0x33
[    2.748616] 0x42
[    2.748750] 0x53
[    2.748884] 0x55
[    2.749017] 0x54
[    2.749201] 0x0
[    2.749220] sgm7110 ChipID :023BSUT
[    2.749239] sgm7220_chipID = 0x30
[    2.749298] tcpc_device_register register tcpc device (type_c_port0)
[    2.749566] PD Timer number = 53
[    2.753175] tcpci_timer_init : init OK
[    2.753209] pd_parse_pdata
[    2.753246] pd_parse_pdata src pdo data =
[    2.753266] pd_parse_pdata 0: 0x00019032
[    2.753288] pd_parse_pdata snk pdo data =
[    2.753307] pd_parse_pdata 0: 0x000190c8
[    2.753326] pd_parse_pdata 1: 0x000190c8
[    2.753346] pd_parse_pdata id vdos data =
[    2.753366] pd_parse_pdata 0: 0xd00029cf
[    2.753385] pd_parse_pdata 1: 0x00000000
[    2.753403] pd_parse_pdata 2: 0x00010000
[    2.753423] pd_parse_pdata charging_policy = 33
[    2.753444] pd_parse_pdata_mfrs VID = 0x29cf, PID = 0x5081
[    2.753468] dpm_caps: local_dr_power
[    2.753487] dpm_caps: local_dr_data
[    2.753506] dpm_caps: local_ext_power
[    2.753525] dpm_caps: local_usb_comm
[    2.753543] dpm_caps: local_usb_suspend
[    2.753562] dpm_caps: local_high_cap
[    2.753581] dpm_caps: local_give_back
[    2.753599] dpm_caps: local_no_suspend
[    2.753618] dpm_caps: local_vconn_supply
[    2.753637] dpm_caps: attemp_discover_cable_dfp
[    2.753656] dpm_caps: attemp_enter_dp_mode
[    2.753675] dpm_caps: attemp_discover_cable
[    2.753694] dpm_caps: attemp_discover_id
[    2.753713] dpm_caps: pr_reject_as_source
[    2.753732] dpm_caps: pr_reject_as_sink
[    2.753751] dpm_caps: pr_check_gp_source
[    2.753770] dpm_caps: pr_check_gp_sink
[    2.753788] dpm_caps: dr_reject_as_dfp
[    2.753807] dpm_caps: dr_reject_as_ufp
[    2.753827] dpm_caps = 0x0010e18b
[    2.753851] dp, svid
[    2.753869] dp, ufp_np
[    2.753889] dp, dfp_np
[    2.753917] dp, 1st_connection
[    2.753935] dp, 2nd_connection
[    2.754327] ///PD dbg info 33d
[    2.754347] <    2.753>TCPC-PE:pd_core_init
[    2.754467] sgm7220_init_alert name = type_c_port0, gpio = 63,IRQ = 30
[    2.757202] sgm7220_tcpc_init
[    2.757993] sgm7220_i2c_probe probe OK!
[    2.758234] sgm7220_get_alert_status():Dir(1),Connection(0),Current Level(0)
[    2.760087] amba_phys_mem_access_prot: set as noncached
[    3.299162] [hdq_read] type: 0xffff, capacity:80, voltage: 4120mV, average_current:-665
[    3.825118] [hdq_read] type: 0xffff, capacity:80, voltage: 4120mV, average_current:-668
[    4.350578] [hdq_read] type: 0xffff, capacity:80, voltage: 4120mV, average_current:-668
[    4.876026] [hdq_read] type: 0xffff, capacity:80, voltage: 4118mV, average_current:-665
[    5.417165] [hdq_read] type: 0xffff, capacity:80, voltage: 4118mV, average_current:-665
[    5.463195] request gpio ok
[    5.463228] SET acp gpio 1
[    5.463253] iap2_mfi_communication_test enter
[    5.467891] read err step 1
[    5.467946] ==by Vincent 20170921== serial = IRBEN2208RGABU
[    5.467973] g_amb_stream gadget: Ambarella Data Streaming Gadget, version: 1 Jan 2009
[    5.649665] mmc0: queuing unknown CIS tuple 0x80 (2 bytes)
[    5.651324] mmc0: queuing unknown CIS tuple 0x80 (3 bytes)
[    5.652964] mmc0: queuing unknown CIS tuple 0x80 (3 bytes)
[    5.655899] mmc0: queuing unknown CIS tuple 0x80 (7 bytes)
[    5.659492] mmc0: queuing unknown CIS tuple 0x81 (9 bytes)
[    5.714814] mmc0: new high speed SDIO card at address 0001
[    5.884410] bcmdhd: loading out-of-tree module taints kernel.
[    5.891263] [dhd] dhd_module_init: in Dongle Host Driver, version 100.10.545.24 (r826445-20210908-3)(20210926-5)
[    5.891263] /home/paul/git_insta360_oners/ambalink_sdk_4_9/output.oem/h22_ambalink/build/bcmdhd-amba/driver/bcmdhd.100.10.545.x.ambatw.20210926 compiled on Nov 29 2022 at 18:54:02
[    5.891263] 
[    5.891380] [dhd] ======== dhd_wlan_init_plat_data ========
ff
```

# kernel

```
uname -a
Linux AmbaLink 4.9.76 #1 SMP PREEMPT Tue Nov 29 18:53:48 CST 2022 aarch64 GNU/Linux
~# lsmod 
Module                  Size  Used by    Tainted: G  
bcmdhd               1066140  0 
g_amb_stream           19850  0 
tcpc_sgm7220            9486  0 
nfsd                   81094  5 
cfg80211              286291  1 bcmdhd
rfkill                 10072  3 bcmdhd,cfg80211
```

# proc config.gz

```
/tmp/1# cat config 
#
# Automatically generated file; DO NOT EDIT.
# Linux/arm64 4.9.76 Kernel Configuration
#
CONFIG_ARM64=y
CONFIG_64BIT=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_MMU=y
CONFIG_DEBUG_RODATA=y
CONFIG_ARM64_PAGE_SHIFT=12
CONFIG_ARM64_CONT_SHIFT=4
CONFIG_ARCH_MMAP_RND_BITS_MIN=18
CONFIG_ARCH_MMAP_RND_BITS_MAX=24
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=11
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NO_IOPORT_MAP=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_GENERIC_CSUM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ZONE_DMA=y
CONFIG_HAVE_GENERIC_RCU_GUP=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_SMP=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_KERNEL_MODE_NEON=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=3
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_DEFAULT_HOSTNAME="Ambarella"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_SHOW_LEVEL=y
CONFIG_GENERIC_IRQ_MIGRATION=y
CONFIG_HARDIRQS_SW_RESEND=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_HANDLE_DOMAIN_IRQ=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_ARCH_HAS_TICK_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ_FULL is not set
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_PREEMPT_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
# CONFIG_TASKS_RCU is not set
CONFIG_RCU_STALL_COMMON=y
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=16
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_GENERIC_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
# CONFIG_MEMCG is not set
# CONFIG_BLK_CGROUP is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_HUGETLB=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
# CONFIG_BPF_SYSCALL is not set
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_USERFAULTFD is not set
CONFIG_MEMBARRIER=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
# CONFIG_PERF_EVENTS is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_SLAB_FREELIST_RANDOM is not set
CONFIG_SLUB_CPU_PARTIAL=y
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=y
# CONFIG_KPROBES is not set
CONFIG_JUMP_LABEL=y
# CONFIG_STATIC_KEYS_SELFTEST is not set
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_GENERIC_IDLE_POLL_SETUP=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_ARCH_MMAP_RND_BITS=18
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=11
# CONFIG_HAVE_ARCH_HASH is not set
# CONFIG_ISA_BUS_API is not set
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set
# CONFIG_HAVE_ARCH_VMAP_STACK is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
# CONFIG_TRIM_UNUSED_KSYMS is not set
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
# CONFIG_MINIX_SUBPARTITION is not set
# CONFIG_SOLARIS_X86_PARTITION is not set
# CONFIG_UNIXWARE_DISKLABEL is not set
# CONFIG_LDM_PARTITION is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
# CONFIG_EFI_PARTITION is not set
# CONFIG_SYSV68_PARTITION is not set
CONFIG_AMBPTB_PARTITION=y
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_FREEZER=y

#
# Platform selection
#
CONFIG_ARCH_AMBARELLA=y
# CONFIG_ARCH_AMBARELLA_COMBO_NAND is not set
# CONFIG_ARCH_AMBARELLA_HW_RANDOM is not set
# CONFIG_ARCH_AMBARELLA_S5 is not set
CONFIG_ARCH_AMBARELLA_S5L=y
# CONFIG_ARCH_AMBARELLA_CV1 is not set
# CONFIG_ARCH_SUNXI is not set
# CONFIG_ARCH_ALPINE is not set
# CONFIG_ARCH_BCM2835 is not set
# CONFIG_ARCH_BCM_IPROC is not set
# CONFIG_ARCH_BERLIN is not set
# CONFIG_ARCH_BRCMSTB is not set
# CONFIG_ARCH_EXYNOS is not set
# CONFIG_ARCH_LAYERSCAPE is not set
# CONFIG_ARCH_LG1K is not set
# CONFIG_ARCH_HISI is not set
# CONFIG_ARCH_MEDIATEK is not set
# CONFIG_ARCH_MESON is not set
# CONFIG_ARCH_MVEBU is not set
# CONFIG_ARCH_QCOM is not set
# CONFIG_ARCH_ROCKCHIP is not set
# CONFIG_ARCH_SEATTLE is not set
# CONFIG_ARCH_RENESAS is not set
# CONFIG_ARCH_STRATIX10 is not set
# CONFIG_ARCH_TEGRA is not set
# CONFIG_ARCH_SPRD is not set
# CONFIG_ARCH_THUNDER is not set
# CONFIG_ARCH_UNIPHIER is not set
# CONFIG_ARCH_VEXPRESS is not set
# CONFIG_ARCH_VULCAN is not set
# CONFIG_ARCH_XGENE is not set
# CONFIG_ARCH_ZX is not set
# CONFIG_ARCH_ZYNQMP is not set

#
# Bus support
#
# CONFIG_PCI is not set
# CONFIG_PCI_DOMAINS is not set
# CONFIG_PCI_DOMAINS_GENERIC is not set
# CONFIG_PCI_SYSCALL is not set

#
# Kernel Features
#

#
# ARM errata workarounds via the alternatives framework
#
CONFIG_ARM64_ERRATUM_826319=y
CONFIG_ARM64_ERRATUM_827319=y
CONFIG_ARM64_ERRATUM_824069=y
CONFIG_ARM64_ERRATUM_819472=y
CONFIG_ARM64_ERRATUM_832075=y
CONFIG_ARM64_ERRATUM_845719=y
CONFIG_ARM64_ERRATUM_843419=y
CONFIG_CAVIUM_ERRATUM_22375=y
CONFIG_CAVIUM_ERRATUM_23154=y
CONFIG_CAVIUM_ERRATUM_27456=y
CONFIG_QCOM_QDF2400_ERRATUM_0065=y
CONFIG_ARM64_4K_PAGES=y
# CONFIG_ARM64_16K_PAGES is not set
# CONFIG_ARM64_64K_PAGES is not set
CONFIG_ARM64_VA_BITS_39=y
# CONFIG_ARM64_VA_BITS_48 is not set
CONFIG_ARM64_VA_BITS=39
# CONFIG_CPU_BIG_ENDIAN is not set
# CONFIG_SCHED_MC is not set
# CONFIG_SCHED_SMT is not set
CONFIG_NR_CPUS=4
CONFIG_HOTPLUG_CPU=y
# CONFIG_NUMA is not set
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_ARCH_HAS_HOLES_MEMORYMODEL=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_HAVE_ARCH_PFN_VALID=y
CONFIG_SYS_SUPPORTS_HUGETLBFS=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
# CONFIG_BOUNCE is not set
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
# CONFIG_ZPOOL is not set
# CONFIG_ZBUD is not set
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_IDLE_PAGE_TRACKING is not set
# CONFIG_SECCOMP is not set
# CONFIG_PARAVIRT is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
# CONFIG_KEXEC is not set
# CONFIG_XEN is not set
CONFIG_FORCE_MAX_ZONEORDER=11
# CONFIG_ARMV8_DEPRECATED is not set

#
# ARMv8.1 architectural features
#
CONFIG_ARM64_HW_AFDBM=y
CONFIG_ARM64_PAN=y
# CONFIG_ARM64_LSE_ATOMICS is not set
CONFIG_ARM64_VHE=y

#
# ARMv8.2 architectural features
#
CONFIG_ARM64_UAO=y
CONFIG_ARM64_MODULE_CMODEL_LARGE=y
# CONFIG_RANDOMIZE_BASE is not set

#
# Boot options
#
CONFIG_CMDLINE="console=ttyS0"
# CONFIG_CMDLINE_FORCE is not set
# CONFIG_EFI is not set

#
# Userspace binary formats
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_COMPAT=y
CONFIG_SYSVIPC_COMPAT=y

#
# Power management options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_CPU_PM=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y

#
# CPU Power Management
#

#
# CPU Idle
#
# CONFIG_CPU_IDLE is not set
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=y
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
# CONFIG_IP_MULTIPLE_TABLES is not set
# CONFIG_IP_ROUTE_MULTIPATH is not set
# CONFIG_IP_ROUTE_VERBOSE is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
# CONFIG_NET_IP_TUNNEL is not set
# CONFIG_IP_MROUTE is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_NET_UDP_TUNNEL is not set
# CONFIG_NET_FOU is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
# CONFIG_INET_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
# CONFIG_INET_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NET_PTP_CLASSIFY is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_SOCK_CGROUP_DATA is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
CONFIG_BT=m
CONFIG_BT_BREDR=y
CONFIG_BT_RFCOMM=m
CONFIG_BT_RFCOMM_TTY=y
# CONFIG_BT_BNEP is not set
CONFIG_BT_HIDP=m
# CONFIG_BT_HS is not set
CONFIG_BT_LE=y
# CONFIG_BT_SELFTEST is not set
CONFIG_BT_DEBUGFS=y

#
# Bluetooth device drivers
#
CONFIG_BT_INTEL=m
CONFIG_BT_HCIBTUSB=m
# CONFIG_BT_HCIBTUSB_BCM is not set
# CONFIG_BT_HCIBTUSB_RTL is not set
# CONFIG_BT_HCIBTSDIO is not set
CONFIG_BT_HCIUART=m
CONFIG_BT_HCIUART_H4=y
# CONFIG_BT_BLUESLEEP is not set
# CONFIG_BT_HCIUART_BCSP is not set
# CONFIG_BT_HCIUART_ATH3K is not set
# CONFIG_BT_HCIUART_LL is not set
CONFIG_BT_HCIUART_3WIRE=y
# CONFIG_BT_HCIUART_INTEL is not set
# CONFIG_BT_HCIUART_BCM is not set
# CONFIG_BT_HCIUART_QCA is not set
# CONFIG_BT_HCIUART_AG6XX is not set
# CONFIG_BT_HCIUART_MRVL is not set
# CONFIG_BT_HCIBCM203X is not set
# CONFIG_BT_HCIBPA10X is not set
# CONFIG_BT_HCIBFUSB is not set
# CONFIG_BT_HCIVHCI is not set
# CONFIG_BT_MRVL is not set
# CONFIG_BT_ATH3K is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
# CONFIG_STREAM_PARSER is not set
CONFIG_WIRELESS=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_CFG80211=m
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_DEFAULT_PS=y
CONFIG_CFG80211_DEBUGFS=y
CONFIG_CFG80211_INTERNAL_REGDB=y
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
# CONFIG_LIB80211 is not set
CONFIG_MAC80211=m
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
# CONFIG_MAC80211_RC_MINSTREL_VHT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
# CONFIG_MAC80211_MESH is not set
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
CONFIG_RFKILL=m
# CONFIG_RFKILL_INPUT is not set
# CONFIG_RFKILL_GPIO is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
# CONFIG_LWTUNNEL is not set
# CONFIG_DST_CACHE is not set
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#
CONFIG_ARM_AMBA=y
# CONFIG_ARCH_AMBARELLA_CV is not set
CONFIG_ARCH_AMBARELLA_AMBALINK=y
# CONFIG_AMBALINK_GUEST_2 is not set
CONFIG_AMBALINK_LINKCTRL=y
# CONFIG_AMBALINK_SD is not set
# CONFIG_AMBALINK_PPM is not set
CONFIG_AMBALINK_RPC=y
# CONFIG_AMBALINK_LNX1_RPC2 is not set
# CONFIG_AMBALINK_LNX2_RPC2 is not set
CONFIG_AMBALINK_RFS=y
# CONFIG_AMBALINK_VFFS is not set

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
# CONFIG_DMA_SHARED_BUFFER is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=16
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
# CONFIG_VEXPRESS_CONFIG is not set
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=y
# CONFIG_MTD_TESTS is not set
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=y
# CONFIG_MTD_AFS_PARTS is not set
CONFIG_MTD_OF_PARTS=y
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
# CONFIG_MTD_BLOCK is not set
# CONFIG_MTD_BLOCK_RO is not set
CONFIG_MTD_BLOCK_AMBRO=y
# CONFIG_FTL is not set
# CONFIG_NFTL is not set
# CONFIG_INFTL is not set
# CONFIG_RFD_FTL is not set
# CONFIG_SSFDC is not set
# CONFIG_SM_FTL is not set
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
# CONFIG_MTD_RAM is not set
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_AMBARELLA_SPI_NOR is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
CONFIG_MTD_NAND_BCH=y
CONFIG_MTD_NAND_ECC_BCH=y
# CONFIG_MTD_SM_COMMON is not set
CONFIG_MTD_NAND_AMBARELLA=y
# CONFIG_MTD_SPINAND_AMBARELLA is not set
# CONFIG_MTD_NAND_DENALI_DT is not set
# CONFIG_MTD_NAND_GPIO is not set
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=y
# CONFIG_MTD_NAND_DISKONCHIP is not set
# CONFIG_MTD_NAND_DOCG4 is not set
# CONFIG_MTD_NAND_NANDSIM is not set
# CONFIG_MTD_NAND_BRCMNAND is not set
# CONFIG_MTD_NAND_PLATFORM is not set
# CONFIG_MTD_NAND_HISI504 is not set
# CONFIG_MTD_NAND_MTK is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_MTD_UBI_BLOCK is not set
CONFIG_DTC=y
CONFIG_OF=y
# CONFIG_OF_UNITTEST is not set
CONFIG_OF_FLATTREE=y
CONFIG_OF_EARLY_FLATTREE=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_MDIO=y
CONFIG_OF_RESERVED_MEM=y
# CONFIG_OF_OVERLAY is not set
# CONFIG_PARPORT is not set
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=1
CONFIG_BLK_DEV_RAM_SIZE=65536
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_NVME_TARGET is not set

#
# Misc devices
#
CONFIG_RT_REGMAP=y
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_APDS9802ALS is not set
# CONFIG_ISL29003 is not set
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_SRAM is not set
CONFIG_AMBARELLA_HEAPMEM=y
CONFIG_AMBARELLA_DSPMEM=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set

#
# Intel MIC Bus Driver
#

#
# SCIF Bus Driver
#

#
# VOP Bus Driver
#

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_AFU_DRIVER_OPS is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_NETLINK is not set
# CONFIG_SCSI_MQ_DEFAULT is not set
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
# CONFIG_CHR_DEV_SG is not set
# CONFIG_CHR_DEV_SCH is not set
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_HOST_SMP=y
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
# CONFIG_ISCSI_BOOT_SYSFS is not set
CONFIG_SCSI_HISI_SAS=y
# CONFIG_SCSI_UFSHCD is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_VIRTIO is not set
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_HAVE_PATA_PLATFORM=y
# CONFIG_ATA is not set
# CONFIG_MD is not set
# CONFIG_TARGET_CORE is not set
CONFIG_NETDEVICES=y
CONFIG_MII=m
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_MACSEC is not set
CONFIG_NETCONSOLE=y
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_TUN is not set
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
# CONFIG_VIRTIO_NET is not set
# CONFIG_NLMON is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_NET_VENDOR_AMBARELLA=m
CONFIG_NET_VENDOR_AMBARELLA_INTEN_TUE=y
# CONFIG_NET_VENDOR_AMBARELLA_JUMBO_FRAME is not set
# CONFIG_ALTERA_TSE is not set
# CONFIG_NET_VENDOR_AMAZON is not set
# CONFIG_NET_VENDOR_AMD is not set
# CONFIG_NET_VENDOR_ARC is not set
# CONFIG_NET_VENDOR_AURORA is not set
# CONFIG_NET_CADENCE is not set
# CONFIG_NET_VENDOR_BROADCOM is not set
# CONFIG_DNET is not set
# CONFIG_NET_VENDOR_EZCHIP is not set
# CONFIG_NET_VENDOR_HISILICON is not set
# CONFIG_NET_VENDOR_INTEL is not set
# CONFIG_NET_VENDOR_MARVELL is not set
# CONFIG_NET_VENDOR_MICREL is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
# CONFIG_NET_VENDOR_NETRONOME is not set
# CONFIG_ETHOC is not set
# CONFIG_NET_VENDOR_QUALCOMM is not set
# CONFIG_NET_VENDOR_RENESAS is not set
# CONFIG_NET_VENDOR_ROCKER is not set
# CONFIG_NET_VENDOR_SAMSUNG is not set
# CONFIG_NET_VENDOR_SEEQ is not set
# CONFIG_NET_VENDOR_SMSC is not set
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SYNOPSYS is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
CONFIG_PHYLIB=y
CONFIG_SWPHY=y

#
# MDIO bus device drivers
#
# CONFIG_MDIO_BCM_UNIMAC is not set
# CONFIG_MDIO_BITBANG is not set
# CONFIG_MDIO_BUS_MUX_GPIO is not set
# CONFIG_MDIO_BUS_MUX_MMIOREG is not set
# CONFIG_MDIO_HISI_FEMAC is not set
# CONFIG_MDIO_OCTEON is not set

#
# MII PHY device drivers
#
# CONFIG_AMD_PHY is not set
# CONFIG_AQUANTIA_PHY is not set
# CONFIG_AT803X_PHY is not set
# CONFIG_BCM7XXX_PHY is not set
# CONFIG_BCM87XX_PHY is not set
# CONFIG_BROADCOM_PHY is not set
# CONFIG_CICADA_PHY is not set
# CONFIG_DAVICOM_PHY is not set
# CONFIG_DP83848_PHY is not set
# CONFIG_DP83867_PHY is not set
CONFIG_FIXED_PHY=y
# CONFIG_ICPLUS_PHY is not set
# CONFIG_INTEL_XWAY_PHY is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_SUPERCAM_PHY is not set
# CONFIG_MARVELL_PHY is not set
# CONFIG_MICREL_PHY is not set
# CONFIG_MICROCHIP_PHY is not set
# CONFIG_MICROSEMI_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_QSEMI_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_SMSC_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_TERANETICS_PHY is not set
# CONFIG_VITESSE_PHY is not set
# CONFIG_XILINX_GMII2RGMII is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
CONFIG_USB_NET_DRIVERS=y
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_RTL8152 is not set
# CONFIG_USB_LAN78XX is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_HSO is not set
# CONFIG_USB_IPHETH is not set
CONFIG_WLAN=y
CONFIG_WLAN_VENDOR_ADMTEK=y
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH9K is not set
# CONFIG_ATH9K_HTC is not set
# CONFIG_CARL9170 is not set
# CONFIG_ATH6KL is not set
# CONFIG_AR5523 is not set
# CONFIG_ATH10K is not set
# CONFIG_WCN36XX is not set
CONFIG_WLAN_VENDOR_ATMEL=y
# CONFIG_AT76C50X_USB is not set
CONFIG_WLAN_VENDOR_BROADCOM=y
# CONFIG_B43 is not set
# CONFIG_B43LEGACY is not set
# CONFIG_BRCMSMAC is not set
# CONFIG_BRCMFMAC is not set
CONFIG_WLAN_VENDOR_CISCO=y
CONFIG_WLAN_VENDOR_INTEL=y
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_P54_COMMON is not set
CONFIG_WLAN_VENDOR_MARVELL=y
# CONFIG_LIBERTAS is not set
# CONFIG_LIBERTAS_THINFIRM is not set
# CONFIG_MWIFIEX is not set
CONFIG_WLAN_VENDOR_MEDIATEK=y
# CONFIG_MT7601U is not set
CONFIG_WLAN_VENDOR_RALINK=y
# CONFIG_RT2X00 is not set
CONFIG_WLAN_VENDOR_REALTEK=y
# CONFIG_RTL8187 is not set
CONFIG_RTL_CARDS=m
# CONFIG_RTL8192CU is not set
# CONFIG_RTL8XXXU is not set
CONFIG_WLAN_VENDOR_RSI=y
# CONFIG_RSI_91X is not set
CONFIG_WLAN_VENDOR_ST=y
# CONFIG_CW1200 is not set
CONFIG_WLAN_VENDOR_TI=y
# CONFIG_WL1251 is not set
# CONFIG_WL12XX is not set
# CONFIG_WL18XX is not set
# CONFIG_WLCORE is not set
CONFIG_WLAN_VENDOR_ZYDAS=y
# CONFIG_USB_ZD1201 is not set
# CONFIG_ZD1211RW is not set
# CONFIG_MAC80211_HWSIM is not set
# CONFIG_USB_NET_RNDIS_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_ISDN is not set
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=m
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
# CONFIG_INPUT_KEYBOARD is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_ATMEL_CAPTOUCH is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_E3X0_BUTTON is not set
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
# CONFIG_INPUT_GP2A is not set
# CONFIG_INPUT_GPIO_BEEPER is not set
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
# CONFIG_INPUT_GPIO_DECODER is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_UINPUT=m
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set
# CONFIG_INPUT_DRV260X_HAPTICS is not set
# CONFIG_INPUT_DRV2665_HAPTICS is not set
# CONFIG_INPUT_DRV2667_HAPTICS is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
# CONFIG_SERIO is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
# CONFIG_SERIAL_8250 is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_AMBARELLA=y
CONFIG_SERIAL_AMBARELLA_CONSOLE=y
# CONFIG_SERIAL_AMBA_PL010 is not set
# CONFIG_SERIAL_AMBA_PL011 is not set
# CONFIG_SERIAL_EARLYCON_ARM_SEMIHOST is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_CONEXANT_DIGICOLOR is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_HVC_DCC is not set
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_R3964 is not set

#
# PCMCIA character devices
#
# CONFIG_RAW_DRIVER is not set
# CONFIG_TCG_TPM is not set
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y

#
# I2C Hardware Bus support
#

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_AMBARELLA=y
# CONFIG_I2C_CADENCE is not set
# CONFIG_I2C_CBUS_GPIO is not set
# CONFIG_I2C_DESIGNWARE_PLATFORM is not set
# CONFIG_I2C_EMEV2 is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_NOMADIK is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_RK3X is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_STUB is not set
# CONFIG_I2C_SLAVE is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_SPMI is not set
# CONFIG_HSI is not set

#
# PPS support
#
# CONFIG_PPS is not set

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PINCTRL=y

#
# Pin controllers
#
CONFIG_PINMUX=y
CONFIG_PINCONF=y
# CONFIG_DEBUG_PINCTRL is not set
# CONFIG_PINCTRL_AMD is not set
# CONFIG_PINCTRL_SINGLE is not set
CONFIG_PINCTRL_AMB=y
CONFIG_GPIOLIB=y
CONFIG_OF_GPIO=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_74XX_MMIO is not set
# CONFIG_GPIO_ALTERA is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_GRGPIO is not set
# CONFIG_GPIO_MOCKUP is not set
# CONFIG_GPIO_PL061 is not set
# CONFIG_GPIO_SYSCON is not set
# CONFIG_GPIO_XGENE is not set
# CONFIG_GPIO_XILINX is not set
# CONFIG_GPIO_ZX is not set

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
# CONFIG_GPIO_ADNP is not set
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_TPIC2810 is not set
# CONFIG_GPIO_TS4900 is not set

#
# MFD GPIO expanders
#

#
# SPI or I2C GPIO expanders
#
# CONFIG_GPIO_MCP23S08 is not set

#
# USB GPIO expanders
#
# CONFIG_W1 is not set
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_GPIO is not set
# CONFIG_POWER_RESET_GPIO_RESTART is not set
# CONFIG_POWER_RESET_LTC2952 is not set
# CONFIG_POWER_RESET_RESTART is not set
# CONFIG_POWER_RESET_XGENE is not set
# CONFIG_POWER_RESET_SYSCON is not set
# CONFIG_POWER_RESET_SYSCON_POWEROFF is not set
CONFIG_POWER_RESET_AMBARELLA=y
# CONFIG_SYSCON_REBOOT_MODE is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_CHARGER_RT9455 is not set
# CONFIG_HWMON is not set
# CONFIG_THERMAL is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_CORE is not set
# CONFIG_MFD_ACT8945A is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_MFD_AS3722 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_ATMEL_FLEXCOM is not set
# CONFIG_MFD_ATMEL_HLCDC is not set
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_DA9150 is not set
# CONFIG_MFD_DLN2 is not set
# CONFIG_MFD_EXYNOS_LPASS is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_MFD_HI6421_PMIC is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_HTC_I2CPLD is not set
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77620 is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MT6397 is not set
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RTSX_USB is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_RK808 is not set
# CONFIG_MFD_RN5T618 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TI_LP873X is not set
# CONFIG_MFD_TPS65218 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_DRM is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# Frame buffer Devices
#
# CONFIG_FB is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set
# CONFIG_VGASTATE is not set

#
# Console display driver support
#
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=m
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=m
# CONFIG_HID_APPLEIR is not set
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=m
# CONFIG_HID_BETOP_FF is not set
CONFIG_HID_CHERRY=m
CONFIG_HID_CHICONY=m
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CP2112 is not set
CONFIG_HID_CYPRESS=m
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=m
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=m
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO is not set
CONFIG_HID_LOGITECH=m
# CONFIG_HID_LOGITECH_HIDPP is not set
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_MICROSOFT=m
CONFIG_HID_MONTEREY=m
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTRIG is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PENMOUNT is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_RMI is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set
# CONFIG_HID_ALPS is not set

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_OTG_FSM is not set
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_AMBARELLA=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_AMBARELLA=y
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_REALTEK is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_USBAT is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_STORAGE_ENE_UB6250 is not set
# CONFIG_USB_UAS is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USBIP_CORE is not set

#
# USB Power Delivery
#
# CONFIG_USB_PD is not set
CONFIG_TCPC_CLASS=y
CONFIG_USB_POWER_DELIVERY=y
# CONFIG_TCPC_RT1711 is not set
CONFIG_TCPC_RT1711H=y
CONFIG_TCPC_SGM7220=m
CONFIG_USB_PD_VBUS_STABLE_TOUT=125
CONFIG_USB_PD_VBUS_PRESENT_TOUT=20
# CONFIG_USB_MUSB_HDRC is not set
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_ISP1760 is not set

#
# USB port drivers
#
CONFIG_USB_SERIAL=m
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_SIMPLE is not set
# CONFIG_USB_SERIAL_AIRCABLE is not set
# CONFIG_USB_SERIAL_ARK3116 is not set
# CONFIG_USB_SERIAL_BELKIN is not set
# CONFIG_USB_SERIAL_CH341 is not set
# CONFIG_USB_SERIAL_WHITEHEAT is not set
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
# CONFIG_USB_SERIAL_CP210X is not set
# CONFIG_USB_SERIAL_CYPRESS_M8 is not set
# CONFIG_USB_SERIAL_EMPEG is not set
# CONFIG_USB_SERIAL_FTDI_SIO is not set
# CONFIG_USB_SERIAL_VISOR is not set
# CONFIG_USB_SERIAL_IPAQ is not set
# CONFIG_USB_SERIAL_IR is not set
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
# CONFIG_USB_SERIAL_F81232 is not set
# CONFIG_USB_SERIAL_GARMIN is not set
# CONFIG_USB_SERIAL_IPW is not set
# CONFIG_USB_SERIAL_IUU is not set
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
# CONFIG_USB_SERIAL_KEYSPAN is not set
# CONFIG_USB_SERIAL_KLSI is not set
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
# CONFIG_USB_SERIAL_MCT_U232 is not set
# CONFIG_USB_SERIAL_METRO is not set
# CONFIG_USB_SERIAL_MOS7720 is not set
# CONFIG_USB_SERIAL_MOS7840 is not set
# CONFIG_USB_SERIAL_MXUPORT is not set
# CONFIG_USB_SERIAL_NAVMAN is not set
# CONFIG_USB_SERIAL_PL2303 is not set
# CONFIG_USB_SERIAL_OTI6858 is not set
# CONFIG_USB_SERIAL_QCAUX is not set
# CONFIG_USB_SERIAL_QUALCOMM is not set
# CONFIG_USB_SERIAL_SPCP8X5 is not set
# CONFIG_USB_SERIAL_SAFE is not set
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
# CONFIG_USB_SERIAL_SYMBOL is not set
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
# CONFIG_USB_SERIAL_OPTION is not set
# CONFIG_USB_SERIAL_OMNINET is not set
# CONFIG_USB_SERIAL_OPTICON is not set
# CONFIG_USB_SERIAL_XSENS_MT is not set
# CONFIG_USB_SERIAL_WISHBONE is not set
# CONFIG_USB_SERIAL_SSU100 is not set
# CONFIG_USB_SERIAL_QT2 is not set
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_HSIC_USB3503 is not set
# CONFIG_USB_HSIC_USB4604 is not set
# CONFIG_USB_LINK_LAYER_TEST is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_USB_AMBARELLA_PHY=y
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_ISP1301 is not set
# CONFIG_USB_ULPI is not set
CONFIG_DUAL_ROLE_USB_INTF=y
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=500
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2
# CONFIG_U_SERIAL_CONSOLE is not set

#
# USB Peripheral Controller
#
# CONFIG_USB_FOTG210_UDC is not set
# CONFIG_USB_GR_UDC is not set
# CONFIG_USB_R8A66597 is not set
# CONFIG_USB_PXA27X is not set
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_MV_U3D is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_BDC_UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_GADGET_XILINX is not set
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_AMBARELLA=y
CONFIG_USB_LIBCOMPOSITE=m
CONFIG_USB_F_ACM=m
CONFIG_USB_U_SERIAL=m
CONFIG_USB_U_ETHER=m
CONFIG_USB_F_SERIAL=m
CONFIG_USB_F_OBEX=m
CONFIG_USB_F_ECM=m
CONFIG_USB_F_SUBSET=m
CONFIG_USB_F_RNDIS=m
CONFIG_USB_F_MASS_STORAGE=m
# CONFIG_USB_CONFIGFS is not set
# CONFIG_USB_ZERO is not set
CONFIG_USB_ETH=m
CONFIG_USB_ETH_RNDIS=y
# CONFIG_USB_ETH_EEM is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
CONFIG_USB_MASS_STORAGE=m
CONFIG_USB_G_SERIAL=m
# CONFIG_USB_G_PRINTER is not set
CONFIG_USB_AMB_STREAM=m
CONFIG_USB_MFI_STREAM=m
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_ACM_MS is not set
CONFIG_USB_G_MULTI=m
CONFIG_USB_G_MULTI_RNDIS=y
# CONFIG_USB_G_MULTI_CDC is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_ULPI_BUS is not set
# CONFIG_UWB is not set
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
CONFIG_PWRSEQ_EMMC=m
CONFIG_PWRSEQ_SIMPLE=m

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_MINORS=32
# CONFIG_MMC_BLOCK_BOUNCE is not set
# CONFIG_SDIO_UART is not set
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_AMBARELLA=y
# CONFIG_MMC_ARMMMCI is not set
# CONFIG_MMC_SDHCI is not set
# CONFIG_MMC_DW is not set
# CONFIG_MMC_VUB300 is not set
# CONFIG_MMC_USHC is not set
# CONFIG_MMC_USDHI6ROL0 is not set
# CONFIG_MMC_MTK is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
CONFIG_RTC_INTF_DEV_UIE_EMUL=y
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_ABB5ZES3 is not set
# CONFIG_RTC_DRV_ABX80X is not set
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_HYM8563 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_ISL12022 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF8523 is not set
# CONFIG_RTC_DRV_PCF85063 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
# CONFIG_RTC_DRV_RX8010 is not set
# CONFIG_RTC_DRV_RX8581 is not set
# CONFIG_RTC_DRV_RX8025 is not set
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV8803 is not set

#
# SPI RTC drivers
#
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_PCF2127 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1685_FAMILY is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_DS2404 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set
# CONFIG_RTC_DRV_ZYNQMP is not set

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_PL030 is not set
# CONFIG_RTC_DRV_PL031 is not set
CONFIG_RTC_DRV_AMBARELLA=y
# CONFIG_RTC_DRV_SNVS is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
# CONFIG_SYNC_FILE is not set
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_STAGING is not set
# CONFIG_GOLDFISH is not set
# CONFIG_CHROME_PLATFORMS is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_VERSATILE is not set
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_SI514 is not set
# CONFIG_COMMON_CLK_SI570 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CDCE925 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_CLK_QORIQ is not set
# CONFIG_COMMON_CLK_XGENE is not set
# CONFIG_COMMON_CLK_NXP is not set
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKSRC_OF=y
CONFIG_CLKSRC_PROBE=y
CONFIG_ARM_ARCH_TIMER=y
CONFIG_ARM_ARCH_TIMER_EVTSTREAM=y
CONFIG_FSL_ERRATUM_A008585=y
# CONFIG_ARM_TIMER_SP804 is not set
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
# CONFIG_STE_MODEM_RPROC is not set
CONFIG_AMBARELLA_RPROC=y
# CONFIG_RPCLNT_SUPPORT is not set

#
# Rpmsg drivers
#
CONFIG_RPMSG=y
CONFIG_RPMSG_VIRTIO=y

#
# Ambarella RPMSG Host Programs
#
CONFIG_RPMSG_ECHO=y
# CONFIG_RPMSG_RSH is not set
# CONFIG_RPMSG_VETH is not set
# CONFIG_RPMSG_HOSTRELAY is not set
CONFIG_RPMSG_INSTA360_COMM=y

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_AMBARELLA_SUPPORT_GDMA is not set

#
# Broadcom SoC drivers
#
# CONFIG_SUNXI_SRAM is not set
# CONFIG_SOC_TI is not set
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_PWM is not set
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_ARM_GIC_V3=y
# CONFIG_AMBARELLA_VIC is not set
CONFIG_PARTITION_PERCPU=y
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
# CONFIG_GENERIC_PHY is not set
# CONFIG_PHY_PXA_28NM_HSIC is not set
# CONFIG_PHY_PXA_28NM_USB2 is not set
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_PHY_XGENE is not set
# CONFIG_POWERCAP is not set
# CONFIG_MCB is not set

#
# Performance monitor support
#
# CONFIG_RAS is not set

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_LIBNVDIMM is not set
# CONFIG_NVMEM is not set
# CONFIG_STM is not set
# CONFIG_INTEL_TH is not set

#
# FPGA Configuration Support
#
# CONFIG_FPGA is not set

#
# Firmware Drivers
#
CONFIG_ARM_PSCI_FW=y
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_HAVE_ARM_SMCCC=y
# CONFIG_MESON_SM is not set
# CONFIG_AMBARELLA_SCM is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=m
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_ENCRYPTION is not set
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=m
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=m
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
# CONFIG_NILFS2_FS is not set
# CONFIG_F2FS_FS is not set
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
# CONFIG_FS_ENCRYPTION is not set
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_FAT_DEFAULT_UTF8=y
CONFIG_NTFS_FS=y
CONFIG_NTFS_DEBUG=y
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
# CONFIG_PROC_CHILDREN is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_JFFS2_FS is not set
CONFIG_UBIFS_FS=y
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
# CONFIG_UBIFS_ATIME_SUPPORT is not set
# CONFIG_LOGFS is not set
# CONFIG_CRAMFS is not set
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
CONFIG_SQUASHFS_DECOMP_SINGLE=y
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
# CONFIG_SQUASHFS_XATTR is not set
CONFIG_SQUASHFS_ZLIB=y
CONFIG_SQUASHFS_LZ4=y
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_PSTORE is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
CONFIG_AMBALINK_VFS=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
# CONFIG_NFS_V4 is not set
# CONFIG_NFS_SWAP is not set
CONFIG_ROOT_NFS=y
CONFIG_NFSD=m
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
# CONFIG_NFSD_V4 is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=y
CONFIG_CIFS_STATS=y
# CONFIG_CIFS_STATS2 is not set
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CIFS_SMB2 is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
# CONFIG_VHOST_NET is not set
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set

#
# Kernel hacking
#

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_INFO_REDUCED is not set
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_PAGE_EXTENSION is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_ARCH_KASAN=y
# CONFIG_KASAN is not set
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set
# CONFIG_TIMER_STATS is not set
CONFIG_DEBUG_PREEMPT=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_ATOMIC_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
# CONFIG_STACKTRACE is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_HAVE_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_TORTURE_TEST is not set
# CONFIG_RCU_PERF_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PERCPU_TEST is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_TEST_PRINTF is not set
# CONFIG_TEST_BITMAP is not set
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_TEST_LKM is not set
# CONFIG_TEST_USER_COPY is not set
# CONFIG_TEST_BPF is not set
# CONFIG_TEST_FIRMWARE is not set
# CONFIG_TEST_UDELAY is not set
# CONFIG_MEMTEST is not set
# CONFIG_TEST_STATIC_KEYS is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
# CONFIG_ARM64_PTDUMP is not set
# CONFIG_PID_IN_CONTEXTIDR is not set
# CONFIG_ARM64_RANDOMIZE_TEXT_OFFSET is not set
# CONFIG_DEBUG_SET_MODULE_RONX is not set
# CONFIG_DEBUG_ALIGN_RODATA is not set
# CONFIG_CORESIGHT is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HAVE_ARCH_HARDENED_USERCOPY=y
# CONFIG_HARDENED_USERCOPY is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=m
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_KPP2=y
# CONFIG_CRYPTO_RSA is not set
# CONFIG_CRYPTO_DH is not set
# CONFIG_CRYPTO_ECDH is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=m
CONFIG_CRYPTO_NULL=m
CONFIG_CRYPTO_NULL2=y
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
# CONFIG_CRYPTO_MCRYPTD is not set
# CONFIG_CRYPTO_AUTHENC is not set
# CONFIG_CRYPTO_TEST is not set
CONFIG_CRYPTO_ABLK_HELPER=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=m
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_SEQIV=m
CONFIG_CRYPTO_ECHAINIV=m

#
# Block modes
#
# CONFIG_CRYPTO_CBC is not set
CONFIG_CRYPTO_CTR=m
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
# CONFIG_CRYPTO_LRW is not set
# CONFIG_CRYPTO_PCBC is not set
# CONFIG_CRYPTO_XTS is not set
# CONFIG_CRYPTO_KEYWRAP is not set

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32 is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=m
# CONFIG_CRYPTO_POLY1305 is not set
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
# CONFIG_CRYPTO_SHA1 is not set
CONFIG_CRYPTO_SHA256=y
# CONFIG_CRYPTO_SHA512 is not set
# CONFIG_CRYPTO_SHA3 is not set
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST6 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_CHACHA20 is not set
# CONFIG_CRYPTO_SEED is not set
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=m
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=m
CONFIG_CRYPTO_JITTERENTROPY=m
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_AMBARELLA is not set
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set

#
# Certificates for signature checking
#
CONFIG_ARM64_CRYPTO=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
# CONFIG_CRYPTO_CRC32_ARM64 is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_HAVE_ARCH_BITREVERSE=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
# CONFIG_LIBCRC32C is not set
# CONFIG_CRC8 is not set
CONFIG_AUDIT_ARCH_COMPAT_GENERIC=y
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_BCH=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set
# CONFIG_IRQ_POLL is not set
CONFIG_LIBFDT=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_SBITMAP=y

#
# Insta360 AIP Setup
#
CONFIG_INSTA360_AIP=y
```

# nmap

```
# nmap -T4 -A -v 192.168.42.1
Starting Nmap 7.93 ( https://nmap.org ) at 2023-01-25 20:44 CET
NSE: Loaded 155 scripts for scanning.
NSE: Script Pre-scanning.
Initiating NSE at 20:44
Completed NSE at 20:44, 0.00s elapsed
Initiating NSE at 20:44
Completed NSE at 20:44, 0.00s elapsed
Initiating NSE at 20:44
Completed NSE at 20:44, 0.00s elapsed
Initiating ARP Ping Scan at 20:44
Scanning 192.168.42.1 [1 port]
Completed ARP Ping Scan at 20:44, 0.08s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 20:44
Completed Parallel DNS resolution of 1 host. at 20:44, 0.00s elapsed
Initiating SYN Stealth Scan at 20:44
Scanning 192.168.42.1 [1000 ports]
Discovered open port 23/tcp on 192.168.42.1
Discovered open port 80/tcp on 192.168.42.1
Discovered open port 111/tcp on 192.168.42.1
Discovered open port 53/tcp on 192.168.42.1
Discovered open port 6666/tcp on 192.168.42.1
Discovered open port 2049/tcp on 192.168.42.1
Completed SYN Stealth Scan at 20:44, 1.15s elapsed (1000 total ports)
Initiating Service scan at 20:44
Scanning 6 services on 192.168.42.1
Completed Service scan at 20:47, 176.61s elapsed (6 services on 1 host)
Initiating OS detection (try #1) against 192.168.42.1
NSE: Script scanning 192.168.42.1.
Initiating NSE at 20:47
Completed NSE at 20:47, 15.15s elapsed
Initiating NSE at 20:47
Completed NSE at 20:47, 1.01s elapsed
Initiating NSE at 20:47
Completed NSE at 20:47, 0.00s elapsed
Nmap scan report for 192.168.42.1
Host is up (0.0069s latency).
Not shown: 994 closed tcp ports (reset)
PORT     STATE SERVICE VERSION
23/tcp   open  telnet  BusyBox telnetd
53/tcp   open  domain  dnsmasq 2.76
| dns-nsid: 
|_  bind.version: dnsmasq-2.76
80/tcp   open  http
| fingerprint-strings: 
|   FourOhFourRequest, GetRequest, HTTPOptions, RTSPRequest, SIPOptions: 
|     HTTP/1.0 400
|     Content-Length: 4
|     Content-Type: text/plain
|     Connection: close
|_    1000
|_http-title: Site doesn't have a title (text/plain).
111/tcp  open  rpcbind 2-4 (RPC #100000)
| rpcinfo: 
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100003  3           2049/tcp   nfs
|   100003  3           2049/udp   nfs
|   100005  1,2,3      41796/udp   mountd
|   100005  1,2,3      54873/tcp   mountd
|   100021  1,3,4      35160/udp   nlockmgr
|   100021  1,3,4      42297/tcp   nlockmgr
|   100024  1          33407/udp   status
|_  100024  1          54679/tcp   status
2049/tcp open  nfs     3 (RPC #100003)
6666/tcp open  irc?
|_irc-info: Unable to open connection
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port80-TCP:V=7.93%I=7%D=1/25%Time=63D186B3%P=x86_64-pc-linux-gnu%r(GetR
SF:equest,54,"HTTP/1\.0\x20400\r\nContent-Length:\x204\r\nContent-Type:\x2
SF:0text/plain\r\nConnection:\x20close\r\n\r\n1000")%r(HTTPOptions,54,"HTT
SF:P/1\.0\x20400\r\nContent-Length:\x204\r\nContent-Type:\x20text/plain\r\
SF:nConnection:\x20close\r\n\r\n1000")%r(RTSPRequest,54,"HTTP/1\.0\x20400\
SF:r\nContent-Length:\x204\r\nContent-Type:\x20text/plain\r\nConnection:\x
SF:20close\r\n\r\n1000")%r(FourOhFourRequest,54,"HTTP/1\.0\x20400\r\nConte
SF:nt-Length:\x204\r\nContent-Type:\x20text/plain\r\nConnection:\x20close\
SF:r\n\r\n1000")%r(SIPOptions,54,"HTTP/1\.0\x20400\r\nContent-Length:\x204
SF:\r\nContent-Type:\x20text/plain\r\nConnection:\x20close\r\n\r\n1000");
MAC Address: B8:13:32:XX:XX:XX (Ampak Technology)
Device type: general purpose
Running: Linux 3.X|4.X
OS CPE: cpe:/o:linux:linux_kernel:3 cpe:/o:linux:linux_kernel:4
OS details: Linux 3.2 - 4.9
Uptime guess: 0.007 days (since Wed Jan 25 20:38:36 2023)
Network Distance: 1 hop
TCP Sequence Prediction: Difficulty=259 (Good luck!)
IP ID Sequence Generation: All zeros
Service Info: Host: AmbaLink

TRACEROUTE
HOP RTT     ADDRESS
1   6.93 ms 192.168.42.1

NSE: Script Post-scanning.
Initiating NSE at 20:47
Completed NSE at 20:47, 0.00s elapsed
Initiating NSE at 20:47
Completed NSE at 20:47, 0.00s elapsed
Initiating NSE at 20:47
Completed NSE at 20:47, 0.00s elapsed
Read data files from: /usr/bin/../share/nmap
OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 195.60 seconds
           Raw packets sent: 1030 (46.114KB) | Rcvd: 1017 (41.422KB)

```

# ps

```
# ps
PID   USER     COMMAND
    1 root     init
    2 root     [kthreadd]
    3 root     [ksoftirqd/0]
    4 root     [kworker/0:0]
    5 root     [kworker/0:0H]
    6 root     [kworker/u8:0]
    7 root     [rcu_preempt]
    8 root     [rcu_sched]
    9 root     [rcu_bh]
   10 root     [migration/0]
   11 root     [lru-add-drain]
   12 root     [cpuhp/0]
   13 root     [cpuhp/1]
   14 root     [migration/1]
   15 root     [ksoftirqd/1]
   16 root     [kworker/1:0]
   17 root     [kworker/1:0H]
   18 root     [cpuhp/2]
   19 root     [migration/2]
   20 root     [ksoftirqd/2]
   21 root     [kworker/2:0]
   22 root     [kworker/2:0H]
   23 root     [cpuhp/3]
   24 root     [migration/3]
   25 root     [ksoftirqd/3]
   26 root     [kworker/3:0]
   27 root     [kworker/3:0H]
   28 root     [kdevtmpfs]
   29 root     [netns]
   30 root     [oom_reaper]
   31 root     [writeback]
   32 root     [kcompactd0]
   33 root     [crypto]
   34 root     [kintegrityd]
   35 root     [bioset]
   36 root     [kblockd]
   37 root     [pd_dbg_info]
   38 root     [kworker/0:1]
   39 root     [kworker/0:2]
   40 root     [rpciod]
   41 root     [xprtiod]
   64 root     [kswapd0]
   65 root     [vmstat]
   66 root     [nfsiod]
   67 root     [cifsiod]
   68 root     [cifsoplockd]
   87 root     [bioset]
   88 root     [bioset]
   89 root     [bioset]
   90 root     [bioset]
   91 root     [bioset]
   92 root     [bioset]
   93 root     [bioset]
   94 root     [bioset]
   95 root     [bioset]
   96 root     [bioset]
   97 root     [bioset]
   98 root     [bioset]
   99 root     [bioset]
  100 root     [bioset]
  101 root     [bioset]
  102 root     [bioset]
  103 root     [bioset]
  104 root     [bioset]
  105 root     [bioset]
  106 root     [kworker/0:1H]
  123 root     [kworker/u8:1]
  126 root     /usr/bin/rpcbind
  151 root     /usr/bin/ipcbind -b
  153 root     /usr/bin/util_svc -b
  157 root     /usr/bin/AmbaEventNotifyDaemon
  168 root     [cfg80211]
  185 root     /usr/sbin/telnetd -F
  196 root     rpc.statd
  204 root     [kworker/u8:2]
  207 root     [lockd]
  208 root     [nfsd]
  209 root     [nfsd]
  211 root     rpc.mountd
  215 root     /usr/bin/remoteapi_disc_daemon
  226 root     /usr/bin/remoteapi_cmd_daemon
  232 root     /usr/bin/remoteapi_data_daemon
  238 root     /usr/bin/remoteapi_syssvc_daemon
  243 root     /usr/bin/instaAIP
  244 root     -/bin/sh
  258 root     [tcpc_timer_type]
  261 root     [type_c_port0]
  426 root     [kworker/u9:0]
  427 root     [dhd_eventd]
  429 root     [ext_eventd]
  430 root     [dhd_watchdog_th]
  431 root     [dhd_dpc]
  432 root     [dhd_rxf]
  433 root     [ksdioirqd/mmc0]
  458 nobody   dnsmasq --nodns -5 -K -R -n --dhcp-range=192.168.42.2,192.168.42.6,infinite
  464 root     wpa_supplicant -Dnl80211 -iwlan0 -c/tmp/wpa_supplicant.ap.conf -s -B
  466 root     wpa_cli -iwlan0 -B -a /usr/local/share/script/wpa_event.sh
  474 root     [kworker/u9:1]
  540 root     {bcm_start.sh} /bin/sh /usr/local/share/script/bcm_start.sh BLEHID
  542 root     ./bsa_server_arm64 -r 12 -diag=0 -lpm -d /dev/ttyS1 -pp /tmp/bsa
  551 root     ./app_hogp ONE RS XXXXXX.OSC
  577 root     -sh
  583 root     ps
```

Have fun so far! :)


