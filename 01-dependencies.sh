#!/bin/bash

# Repo Dependencies
sudo pacman -S --noconfirm awesome alacritty ranger rofi git base-devel ttf-hack fish exa stow

# Install Yay
git clone https://aur.archlinux.org/yay.git
cd yay
sudo makepkg --noconfrm -si
cd ..
sudo rm -r yay

# Yay dependencies
sudo yay --noconfirm -S pywal

# Install starship prompt
sh -c "$(curl -fsSL https://starship.rs/install.sh)"