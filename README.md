# insta360-one-rs-1-inch-360-edition-linux-info
linux related informations about the Insta360 One RS 1-Inch 360 Edition

Recently I bought an "https://github.com/Insta360Develop/CameraSDK-Cpp". Mostly for outdoors, but after I found
[this official library](https://github.com/Insta360Develop/CameraSDK-Cpp), I was also interested in working on it under linux.
The project requires a SDK, which is hidden for whatever reason behind a [registration system](https://www.insta360.com/de/sdk/home).
At the time of writing I'm [still waiting](https://github.com/Insta360Develop/CameraSDK-Cpp/issues/16#issuecomment-1402361583) for my registration to be approved, but fortunately I found something possibly more interesting meanwhile, so they can keep their SDK:

The "Insta360 One RS 1-Inch 360 Edition" itself is running Linux - and even better, it is very simple to enter it:

Simply connect to the AP it opens _(`ONE RS XXXXXX.OSC`)_ with the default password "88888888".
The device has multiple open ports _(see [nmap](#nmap))_, but the most interesting _(for now)_ is port `23`, means telnet is running.
_(my device has the firemware `2.0.8` currently, so this might change later)_

I was prepared to brute force the `root` password, but I didn't get far - the `root` login is **passwordless!**:

telnet  192.168.42.1
Trying 192.168.42.1...
Connected to 192.168.42.1.
Escape character is '^]'.

AmbaLink login: root
~# 

Where to go from here?
Not sure yet, but it is simple to copy all systemfiles to the internal sdcard for later examination without the need to keep the camera running.

Looking at some random files it seems to be very likely that the system is related to the firmware also used in other action cams, and a quick github search leads you to this [ambarella-h22-firmware-tools](https://github.com/RigacciOrg/ambarella-h22-firmware-tools) project, which possibly is able to extract and repack the firmware _(haven't tried that yet)_

Here are some loose stdouts I saved yesterday while crawling through the OS.
Most system files are stored on my system so I might add some more information later.
If you have any questions and/or are interesting on creating a project around the system, please let me know.

# budybox
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
