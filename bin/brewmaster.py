#!/usr/bin/env python3
###############################################################################
#
# Manages installed software using Homebrew.
# 
# Usage: python3 brewmaster.py /path/to/config.yaml
#
#  Homepage: https://github.com/bjschafer/brewmaster
#
#    Author: Braxton Schafer <braxton.schafer@gmail.com> (bjs)
#
# Changelog:
# 
###############################################################################

import subprocess
import sys
import yaml

def get_config():
	try:
		config_file = sys.argv[1]
	except IndexError:
		print("Please give me a config file path!")
		sys.exit(0)

	with open(config_file, 'r') as conf:
		return yaml.load(conf)

def check_setup(conf):
	pass # We'll need you later.

def call_brew(args):
	try:
		args = args.split(' ')
	except AttributeError:
		pass # it's already how we expect it to be
	print(args)
	status = subprocess.call((['brew'] + args))
	if status != 0: # Something done goofed.
		print("Something went wrong with brew. Here are the args:\n" + args)


if __name__ == '__main__':
	conf = get_config()
	check_setup(conf)

	call_brew('update')

	# Update out of date packages that may be updated.
	call_brew('upgrade')

	# Let's install what we came here for

	for formula in get_config()['formulae']:
		name = formula['name']
		version = formula['name']
		args = []
		try:
			args = formula['args']
		except:
			args = []

		if version == 'current':
			call_brew(['install', name,  ' '.join(args)])
			
			call_brew(['pin', name])

		elif version == 'latest':
			call_brew(['install', name, ' '.join(args)])

		else:
			call_brew(['install', name, ' '.join(args)])
			
			call_brew(['pin', name])