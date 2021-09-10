#!/bin/bash

configs=()

install_configs () {
	get_packages
	echo "Installing Packages"
	for c in "${configs[@]}"; do
		echo "Installing $c"
		mkdir -p ~/.config/$c
		stow -vt ~/.config/$c -S $c
	done
	echo "Packages Installed"
}

uninstall_configs () {
	get_packages
	echo "Uninstalling Packages"
	for c in "${configs[@]}"; do
		echo "Uninstalling $c"
		stow -vt ~/.config/$c -D $c
	done
	echo "Packages Uninstalled"
}

get_packages () {
	echo "Fetching Packages to Install"
	local packages=$(ls -d */)
	for p in $packages; do
		configs+=($p)
	done
	echo "Found ${#configs[@]} Packages"
}

print_usage () {
	echo "Usage install.sh -S | D"
}

while getopts 'SD' flag; do
	ops = true
	case "${flag}" in
		S) install_configs ;;
		D) uninstall_configs ;;
		*) print_usage 
		   exit 1;;
	esac
done

if [ -z "$ops" ]; then
	print_usage
	exit 1
fi
