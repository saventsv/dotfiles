#!/usr/bin/env bash

bluetoothctl power on
bluetoothctl scan on
sleep 3
bluetoothctl scan off

device=$(
  bluetoothctl devices |
    sed "s/^Device [^ ]* //" |
    sort -u |
    rofi -dmenu -i -p "Bluetooth"
)

if [ -z "$device" ] && exit

mac=$(
  bluetoothctl devices |
  grep -F " $device$" |
  awk '{print $2}' |
  head -n1)
)

if [ -z "$mac" ] && exit

bluetoothctl connect "$mac"
