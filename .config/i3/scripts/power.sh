#!/usr/bin/env bash

choice=$(
  printf "%s\n" \
    "Power Off" \
    "Reboot" \
    "Logout" |
    rofi -dmenu -i -p "Power"
)

case "$choice" in
"Power Off")
  systemctl poweroff
  ;;
"Reboot")
  reboot
  ;;
"Logout")
  i3-msg exit
  qtile cmd-obj -o cmd -f shutdown
  ;;
esac
