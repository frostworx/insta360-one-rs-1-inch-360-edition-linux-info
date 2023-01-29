#!/bin/sh

MYSCRIPTS="/tmp/SD0/scripts"
MYBINS="/tmp/SD0/bin"
MYLIBS="/tmp/SD0/lib"

MYLOG="/tmp/SD0/log"

if [ ! -d "$MYLOG" ]; then
  mkdir "$MYLOG"
fi

if [ -d "$MYLIBS" ]; then
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MYLIBS"
fi

ps aux > "$MYLOG/ps-aux.txt"
lsof > "$MYLOG/lsof.txt"
env > "$MYLOG/env.txt"

# remounting / rw is impossible - it is a squashfs

# connect to own AP 
if [ -x "$MYSCRIPTS"/wpa_connect.sh ]; then
  /usr/local/share/script/wifi_stop.sh nounload > "$MYLOG/wifi_stop.log" 2>&1
  "$MYSCRIPTS"/wpa_connect.sh 
else
  echo "$MYSCRIPTS/wpa_connect.sh not found" > "$MYLOG/bootup.log"
fi

# busybox
  busybox > "$MYLOG/busybox-builtin.log"

if [ -x "$MYBINS"/busybox ]; then
  "$MYBINS"/busybox > "$MYLOG/busybox-custom.log"
else
  echo "$MYBINS/wpa_connect.sh not found" > "$MYLOG/busybox.log"
fi

# dropbear
if [ -x "$MYBINS"/dropbear ]; then
  "$MYBINS"/dropbear --help > "$MYLOG/dropbear.log" 2>&1
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MYLIBS" "$MYBINS"/dropbear --help >> "$MYLOG/dropbear-ld.log" 2>&1
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MYLIBS" "$MYBINS"/dropbear -F -P /run/dropbear.pid -R 2>&1
else
  echo "$MYBINS/dropbear not found or executable" > "$MYLOG/dropbear.log" 2>&1
fi

# export the whole system via nfs
exportfs *:/
exportfs > "$MYLOG/exportfs.log"
#exportfs -u *:/
