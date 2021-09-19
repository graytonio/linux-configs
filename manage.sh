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

install_individual_package () {
	echo "Installing $1"
	rm -r ~/.config/$1/*
	mkdir -p ~/.config/$1
	stow -vt ~/.config/$1 -S $1
	echo "$1 Installed"
}

uninstall_individual_package () {
	echo "Uninstalling $1"
	stow -vt ~/.config/$1 -D $1
	echo "$1 Uninstalled"
}

print_usage () {
	echo "Usage install.sh -S | D | A | R"
}

while getopts 'ARS:D:' flag; do
	ops=true
	case "${flag}" in
		A) install_configs ;;
		R) uninstall_configs ;;
		S) install_individual_package $OPTARG ;;
		D) uninstall_individual_package $OPTARG ;;
		*) print_usage 
		   exit 1;;
	esac
done

if [ -z "$ops" ]; then
	print_usage
	exit 1
fi
