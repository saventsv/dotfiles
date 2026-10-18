#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/dotfiles/wallpapers"

WALLPAPER=$(find "$WALLPAPER_DIR" -type f | sort)

# Display filenames without their full paths
SELECTED=$(printf '%s\n' "$WALLPAPER" |
  xargs -d '\n' -n 1 basename |
  rofi -dmenu -i -p "Wallpaper")

[[ -z "$SELECTED" ]] && exit 0

# Resolve the selected filename to its full path
FULL_PATH=$(find "$WALLPAPER_DIR" -type f \
  -iname "$SELECTED" -print -quit)

[[ -z "$FULL_PATH" ]] && exit 1

feh --bg-fill "$FULL_PATH"
