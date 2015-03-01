#!/bin/bash
###############################################################################
#
# Installs brewmaster and sets it up to run automatically at login
# FOR THE CURRENT USER.
# 
# Usage: ./install.sh 
#
#  Homepage: https://github.com/bjschafer/brewmaster
#
#    Author: Braxton Schafer <braxton.schafer@gmail.com> (bjs)
#
# Changelog:
# 
###############################################################################
OPTIND=1

SYS=$(uname -s)
HOME=$(eval ~)

function install_homebrew()
{
	if hash brew 2>/dev/null; then
		return 1
	else
		if [ SYS == "Darwin" ]; then
			ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" # note this prompts the user
		elif [SYS == "Linux" ]; then
			if hash ruby 2>/dev/null && hash gcc 2>/dev/null; then
				ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
			else
				echo "Please install ruby and gcc using your distribution's package manager and try again."
			fi
		else
			echo "Brewmaster is not supported on your SYStem since Homebrew isn't supported!"
			exit 2
		fi
	fi
}

function install_xcodeTools()
{
	if hash gcc 2>/dev/null; then
		return 1
	else
		xcode-select --install
}

function install_brewmaster()
{
	if ! hash python3 2>/dev/null; then
		brew install python3
	fi
	
	if [ SYS == "Darwin" ]; then
		mkdir -p /usr/local/brewmaster/bin
		cp bin/brewmaster.py /usr/local/brewmaster/bin

		cp com.bjschafer.brewmaster.plist $HOME/Library/LaunchAgents
		launchctl load $HOME/Library/LaunchAgents
	elif [ SYS == "Linux" ]; then
		mkdir -p $HOME/.linuxbrew/brewmaster/bin
		cp bin/brewmaster.py $HOME/.linuxbrew/brewmaster/bin

		cat <(crontab -l) <(echo "12 31 * * * $HOME/.linuxbrew/brewmaster/bin/brewmaster.py") | crontab -
	fi

}

if [ $(id -u) -eq 0 ]; then
	echo "You shouldn't be running this as root."
	exit 3
fi

install_homebrew
install_xcodeTools
install_brewmaster