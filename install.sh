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

function install_homebrew()
{
	if hash brew 2>/dev/null; then
		return 1
	else
		if [ SYS == "Darwin" ]; then
			ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" # note this prompts the user
		elif [ SYS == "Linux" ]; then
			if hash ruby 2>/dev/null && hash gcc 2>/dev/null; then
				ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
			else
				echo "Please install ruby and gcc using your distribution's package manager and try again."
				exit 4
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
		if [ SYS == "Darwin" ]; then
			xcode-select --install
		else
			echo "Missing developer tools. Try a sudo apt-get install build-essential"
			exit 4
		fi
	fi
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
	else
		mkdir -p $HOME/.linuxbrew/brewmaster/bin
		cp bin/brewmaster.py $HOME/.linuxbrew/brewmaster/bin

		cat <(crontab -l) <(echo "12 31 * * * $HOME/.linuxbrew/brewmaster/bin/brewmaster.py") | crontab -
	fi

}

# TODO: Check filepath
function find_local_config()
{
	config_type="local"
	read -e -p "Please enter the path to the .yaml file: " -i "/usr/local/brewmaster/config.yaml" config_location
}


# TODO: Check repo format
# Guess if it's not local we gotta clone it somewhere and create ANOTHER (?) scheduled task to keep it up to date?? Or just use the same one somehow?
function find_git_config()
{
	config_type="git"
	read -e -p "Please enter the git repository location: " config_location
}

#TODO: Check URL format
function find_http_config()
{
	config_type="http"
	read -e -p "Please enter the URL: " config_location
}

function get_config()
{
	if [ $1 ]; then
		source $1
	else
		# Guess we have to do this the hard way.
		echo "Where is your config stored?"
		select lgh in "Locally" "Git" "HTTP"; do
			case $lgh in
				Locally ) find_local_config; break;;
				Git ) find_git_config; break;;
				HTTP ) find_http_config; break;;
			esac
		done
}

if [ $(id -u) -eq 0 ]; then
	echo "You shouldn't be running this as root."
	exit 3
fi

echo "Running install..."
echo "Installing Homebrew if it isn't installed..."
install_homebrew

echo "Installing command line developer utilities if they aren't installed..."
install_xcodeTools

echo "FINALLY!"
echo "Installing Brewmaster!"
install_brewmaster