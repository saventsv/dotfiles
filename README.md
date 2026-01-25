# Dotfiles 

## Needed Programs

- hyprland
- fzf
- yazi
- kitty
- neovim
- rofi-wayland
- sddm 
- waybar
- zellij

## Pulling Dotfiles

- make sure to do this in the dir you want it to be in
`git clone https://github.com/saventsv/dotfiles.git` 

### Installation Programs Command

- note this is the needed stuff for if you installed hyprland with the archinstall script
```bash
sudo pacman -S fzf yazi nvim rofi-wayland waybar zellij swww
```

## Setup

* **for bash just copy the config and don't do a symlink to avoid a broken system**

- for config dirs that don't exist yet
```bash
ln -s ~/path/to/git/dotfiles ~/.config/config
```
- for config dirs that do exist
```bash
ln -sfn ~/path/to/git/dotfiles ~/.config/config
```
- repeat for all of the config files 

- for sddm
```bash
sudo cp -r /path/to/your-theme /usr/share/sddm/themes/
```
- and them 
```bash
sudo nvim /etc/sddm.conf
```
- and add 

```config
[Theme]
Current=nord-sddm
```

- for bash just copy the config to avoid a broken config when screwing around with symlinks

- for sww run 
```bash
swww-daemon
```
- and then
```bash
swww img /path/to/your/image.png
```
- (sww it already put in the hyprland config to start on boot)

