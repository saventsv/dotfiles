#!/usr/bin/env bash

choice=$(
  printf "%s\n" \
    "WiFi" \
    "Bluetooth" \
    "Wallpaper" \
    "Power" \
    "Power Profile" |
    rofi -dmenu -i -p "System"
)

case "$choice" in
"WiFi")
  /home/saven/dotfiles/.config/i3/scripts/wifi.sh
  ;;
"Bluetooth")
  /home/saven/dotfiles/.config/i3/scripts/bluetooth.sh
  ;;
"Wallpaper")
  /home/saven/dotfiles/.config/i3/scripts/wallpaper.sh
  ;;
"Power")
  /home/saven/dotfiles/.config/i3/scripts/power.sh
  ;;
"Power Profile")
  /home/saven/dotfiles/.config/i3/scripts/power-profiles.sh
  ;;
esac
