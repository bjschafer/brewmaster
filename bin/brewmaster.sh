#!/bin/bash
###############################################################################
#
# Manages installed software using Homebrew.
# 
#     Usage: ./brewmaster.sh /path/to/config.yaml
#
#  Homepage: http://bjschafer.github.io/brewmaster
#
#    Author: Braxton Schafer <braxton.schafer@gmail.com> (bjs)
#
# Changelog:
# 
###############################################################################
OPTIND=1
yaml_parser="$(pwd)/get_yaml.rb"
config_file=$1

function call_brew()
{
	brew $1 >/dev/null 2>&1

	if [ ! $? -eq 0 ]; then
		echo "Something went wrong with brew. Here are the args:"
		echo $1
		exit 1
	fi
}

function format_brew()
{
	if [ $version == "current" ]; then
		call_brew "install $name $args"
		call_brew "pin $name"
	elif [ $version == "latest" ]; then
		call_brew "install $name $args"
	else
		call_brew "install $name $args"
		echo $name
		call_brew "pin $name"
	fi
}

function installer()
{
	formula_count=$(ruby $yaml_parser $config_file)-1 # TODO: Check this

	for i in $(seq 0 $formula_count); do
		name=$(ruby $yaml_parser $config_file) $i name
		version=$(ruby $yaml_parser $config_file) $i version
		args=$(ruby $yaml_parser $config_file) $i args

		format_brew # each time through args should be global
	done
}

function config_updater()
{
	config_type="$(ruby $yaml_parser $config_file) config type"
	config_location="$(ruby $yaml_parser $config_file) config location"

	if [ "$config_type" == "git" ]; then
		cd $(dirname $config_location)
		git pull
		cd - # this needs to change
	elif [ "$config_type" == "http" ]; then 
		curl -output -silent $config_file $config_location
	fi
}

function startup()
{
	if [[ $# -eq 0 ]] ; then
    		echo "Usage: ./brewmaster.sh config.yaml"
    		exit 1
	fi
	if [ ! -e $config_file ]; then
		echo "Invalid config file specified."
		exit 1
	fi
	call_brew update # do I need quotes?
	call_brew upgrade --all
}

startup
installer
