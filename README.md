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

## Pulling Dotfiles

- make sure to do this in the dir you want it to be in
`git clone https://github.com/saventsv/dotfiles.git` 

### Installation Programs Command

- note this is the needed stuff for if you installed hyprland with the archinstall script
```bash
sudo pacman -S fzf yazi kitty nvim rofi-wayland waybar
```

## Setup

* ==for bash just copy the config and don't do a symlink to avoid a broken system==

- for config dirs that don't exist yet
```bash
ln -s ~/.config/wanted-config ~/destination
```
- for config dirs that do exist
```bash
ln -sf ~/.config/wanted-config ~/destination
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

