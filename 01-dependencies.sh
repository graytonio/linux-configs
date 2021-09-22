#!/bin/bash

# Repo Dependencies
sudo pacman -S awesome alacritty ranger rofi git base-devel ttf-hack fish exa

# Install Yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -r yay

# Yay dependencies
yay -S pywal

# Install starship prompt
sh -c "$(curl -fsSL https://starship.rs/install.sh)"