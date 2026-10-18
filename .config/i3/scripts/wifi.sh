#!/usr/bin/env bash

wifi=$(
  nmcli -t -f SSID device wifi list |
    sed '/^$/d' |
    sort -u |
    rofi -dmenu -i -p "Wi-Fi"
)

[ -z "$wifi" ] && exit

password=$(
  rofi -dmenu -password -p "Password"
)

# TODO fix to make it so that entering nothing gives no password instead of exiting
# [ -z "$password" ] && exit

if [ -z "$password" ]; then
  nmcli device wifi connect "$wifi"
else
  nmcli device wifi connect "$wifi" password "$password"
fi
