#!/usr/bin/env bash

choice=$(
  printf "%s\n" \
    "Performance" \
    "Balanced" \
    "Power Saver" |
    rofi -dmenu -i -p "Power Profiles"
)

case "$choice" in
"Performance")
  powerprofilesctl set performance
  ;;
"Balanced")
  powerprofilesctl set balanced
  ;;
"Power Saver")
  powerprofilesctl set power-saver
  ;;
esac
