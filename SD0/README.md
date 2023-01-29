# SD0

**use at your own risk**
little scriptbox for testing what can be done on the system

## installation
simply copy the content (not the directory itself) to the rootfs of your sd-card

## configuration
edit the scripts to your needs.

**don't run them without checking first what they do!**

## functions:
not much to see here yet.
- we have a fully fledged busybox to play with
- rootfs is exported via nfs globally **!**

## todos

- connect to user-configured wifi is non-functional yet
- dropbear would be nice _(see [notes](#notes))_
- tcpdump and friends would be nice

## usage

put the sd-card into your camera and start it
the default `init.d/S99bootdone` by default starts the custom script `/tmp/SD0/bootup.sh` when found.
This project provides a wip/testing `/tmp/SD0/bootup.sh` to play with.

## notes

`bin` and `lib` binaries were downloaded from `https://archlinuxarm.org`

`4a80a51da258cd024de0070657a79af4  busybox`

see:

`https://archlinuxarm.org/packages/aarch64/busybox` _(busybox 1.34.1-1)_

would be nice to have dropbear, but the binary provided by arch linux uses glibc 2.34, the system has 2.21 though
I'm undecided yet, if creating a bigger project for this is worth the time,
so atm I'm not going to setup a matching crosscompiler env for now.

## maybes

dump communication between the closed source apps and the mobile app or _(better, I don't use/trust mobile apps generally)_ the
official [Camera-SDK-Cpp](https://github.com/Insta360Develop/CameraSDK-Cpp).
Unfortunately the SDK required for the `Camera-SDK-Cpp` is hidden behind some registration wall,
so seems like there is no way to create opensource projects which require the SDK...
