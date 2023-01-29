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
- `ambafs` _(the sd-card is mounted with it)_ can't be exported via nfs, maybe it can be mounted natively before

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

when searching the web for `ambafs` you find some similar projects for other camera/drone devices.
likely the firmware used is similar and the work on the projects could be merged (just guessing).
random findings (unchecked so far):

- https://cgg.mff.cuni.cz/gitlab/i3d/mi-camera_photo/-/raw/43c9ad80c93807b8303a4647d2bdd663797b45be/random.txt
- https://t-shaped.nl/2020/reverse-engineering-the-vuze-xr-camera
- https://github.com/droner69/MavicPro
- https://github.com/RigacciOrg/ambarella-h22-firmware-tools _(not found in the ambafs context, but related anyway)_
- more?

## maybes

dump communication between the closed source apps and the mobile app or _(better, I don't use/trust mobile apps generally)_ the
official [Camera-SDK-Cpp](https://github.com/Insta360Develop/CameraSDK-Cpp).
Unfortunately the SDK required for the `Camera-SDK-Cpp` is hidden behind some registration wall,
so seems like there is no way to create opensource projects which require the SDK...
