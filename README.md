# Dotfiles 

> [!IMPORTANT]
> For Some of the Programs if you don't put the Dotfiles in .config or Have a Different Username the Paths will Have to be Changed

## Needed Programs

- fzf
- kitty
- neovim
- rofi
- sddm 
- zellij
- starship

## Wayland

- Hyprland
- waybar

## X11 (if using SWM)

- polybar
- picom
- SWM
- feh (no need to do anything else already convered in SWM config)


## Pulling Dotfiles

- make sure to do this in the dir you want it to be in
`git clone https://github.com/saventsv/dotfiles.git` 
- then add the custom wm I made
```bash
git clone https://github.com/saventsv/SWM.git
cd SWM
sudo make clean install
rm -rf .git
```

### Installation Programs Command

- note this is the needed stuff for if you installed hyprland with the archinstall script
```bash
sudo pacman -S fzf yazi nvim rofi-wayland waybar zellij swww starship zsh-autosuggestions zsh-syntax-highlighting wlogout vivid eza
```
- then you have to install yay and run
```bash
yay -S zen-browser-bin zsh-abbr 
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

- set zsh as default shell with
```bash
chsh -s $(which zsh)
```
