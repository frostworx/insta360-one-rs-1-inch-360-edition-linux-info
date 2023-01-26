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




