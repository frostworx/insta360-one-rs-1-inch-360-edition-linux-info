#!/bin/sh
MYSCRIPTS="/tmp/SD0/scripts"
MYWPACONF="$MYSCRIPTS/wpa_connect.conf"
MYLOG="/tmp/SD0/log"

if [ -f "$MYWPACONF" ]; then
  ifconfig > "$MYLOG/ifconfig.log"
  ifconfig -a > "$MYLOG/ifconfig-a.log"
  if grep -q "wlan0" "$MYLOG/ifconfig-a.log"; then
    ifconfig wlan0 up
  fi

  if grep -q "wlan0" "$MYLOG/ifconfig.log"; then
#    pkill dhcpcd
#    dhcpcd wlan0 > "$MYLOG/dhcpcd.log" 2>&1 &
    wpa_supplicant -iwlan0 -c "$MYWPACONF" > "$MYLOG/wpa_connect.log" 2>&1 &
  else
    echo "no wlan0 available" >> "$MYLOG/wpa_connect.log"
  fi
fi
