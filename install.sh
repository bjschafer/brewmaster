#!/bin/bash
###############################################################################
#
# Installs brewmaster and sets it up to run automatically at login
# FOR THE CURRENT USER.
# 
#     Usage: ./install.sh 
#
#  Homepage: http://bjschafer.github.io/brewmaster
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
		if [ $SYS == "Darwin" ]; then
			ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" # note this prompts the user
		elif [ $SYS == "Linux" ]; then
			if hash ruby 2>/dev/null && hash gcc 2>/dev/null; then
				ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
			else
				echo "Please install ruby and gcc using your distribution's package manager and try again."
				exit 4
			fi
		else
			echo "Brewmaster is not supported on your System since Homebrew isn't supported!"
			exit 2
		fi
	fi
}

function install_xcodeTools()
{
	if hash gcc 2>/dev/null; then
		return 0
	else
		if [ $SYS == "Darwin" ]; then
			xcode-select --install
		else
			echo "Missing developer tools. Try a sudo apt-get install build-essential"
			exit 4
		fi
	fi
}

function find_local_config()
{
	config_type="local"

	if [ $SYS == "Darwin" ]; then
		read -e -p "Please enter the path to the .yaml file: " -i "/usr/local/brewmaster/config.yaml" config_location
	else
		read -e -p "Please enter the path to the .yaml file: " -i "$HOME/.linuxbrew/brewmaster/config.yaml" config_location
	fi

	if [ ! -e $config_location ]; then
		echo 
		read -p "File not found. Please ensure the config file is there and you have permissions, then press enter to try again."
		if [ ! -e $config_location ]; then
			echo "File not found. Exiting."
			exit 1
		fi
	fi

}

# Guess we gotta create ANOTHER (?) scheduled task to keep it up to date?? Or just use the same one somehow?
# Assumes that the config file is stored in config.yaml inside the repo.
function find_git_config()
{
	config_type="git"
	read -e -p "Please enter the git repository location: " git_repo

	if [ $SYS == "Darwin" ]; then
		config_base="/usr/local/brewmaster/"
	else
		config_base="$HOME/.linuxbrew/brewmaster/"
	fi

	# Let's just let git handle verification, should generally be safe (?)
	git clone $git_repo $config_location
	repo_name=$(basename $git_repo .git)
	config_location="$config_base/$repo_name/config.yaml"

	sed -i -e "s,UPDATE_CALL,cd $config_base/$repo_name && git pull,g" com.bjschafer.brewmaster.sync.plist
}

function find_http_config()
{
	config_type="http"
	read -e -p "Please enter the URL: " url_repo

	echo $config_location | grep -E -q 'http[s]*:\/\/([A-Za-z0-9]+\.)+[A-Za-z]+[\/\w\.\?=]*'
	if [ $? -ne 0 ]; then # not a valid url
		echo "Invalid URL. Try again."
		find_http_config
	fi

	# if they want a URL, let's store it locally where we please
	if [ $SYS == "Darwin" ]; then
		config_location="/usr/local/brewmaster/config.yaml"
	else
		config_location="$HOME/.linuxbrew/brewmaster/config.yaml"
	fi

	curl -output $config_location $url_repo
	if [ $? -ne 0]; then # unable to access
		echo "Try again?"
		find_http_config
	fi

	sed -i -e "s,UPDATE_CALL,curl -silent -output $config_location $url_repo,g" com.bjschafer.brewmaster.sync.plist
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
	fi
}

function install_brewmaster()
{
	sed -i -e "s,CONFIG_LOCATION,$config_location,g" com.bjschafer.brewmaster.plist
	if ! hash python3 2>/dev/null; then
		if [ $SYS == "Darwin" ]; then
			brew install python3
		else
			echo "Please install Python 3 from your distribution's package manager."
			exit 1
		fi
	fi
	
	if [ $SYS == "Darwin" ]; then
		mkdir -p /usr/local/brewmaster/bin
		cp bin/brewmaster.sh /usr/local/brewmaster/bin

		cp com.bjschafer.brewmaster.plist $HOME/Library/LaunchAgents
		launchctl load $HOME/Library/LaunchAgents/com.bjschafer.brewmaster.plist

		if [ $config_type == "http" ] || [ $config_type == "git" ]; then
			cp com.bjschafer.brewmaster.sync.plist $HOME/Library/LaunchAgents
			launchctl load $HOME/Library/LaunchAgents/com.bjschafer.brewmaster.sync.plist
		fi
	else
		mkdir -p $HOME/.linuxbrew/brewmaster/bin
		cp bin/brewmaster.sh $HOME/.linuxbrew/brewmaster/bin

		if [ $config_type == "http" ] || [ $config_type == "git" ]; then
			cat <(crontab -l) <(echo "12 30 * * * $HOME/.linuxbrew/brewmaster/bin/brewmaster.py") | crontab -
		fi


		cat <(crontab -l) <(echo "12 31 * * * $HOME/.linuxbrew/brewmaster/bin/brewmaster.py") | crontab -
	fi

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

get_config

echo "FINALLY!"
echo "Installing Brewmaster!"
install_brewmaster