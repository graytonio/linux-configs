#!/bin/bash

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
	echo "Usage install.sh -S | R"
}

while getopts 'S:R:' flag; do
	ops=true
	case "${flag}" in
		S) install_individual_package $OPTARG ;;
		R) uninstall_individual_package $OPTARG ;;
		*) print_usage 
		   exit 1;;
	esac
done

if [ -z "$ops" ]; then
	print_usage
	exit 1
fi
