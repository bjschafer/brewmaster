#!/usr/bin/env ruby
###############################################################################
#
# Gets specific data from a YAML file; designed for use in shell scripts.
# 
# Usage: ruby get_yaml.rb /path/to/config.yaml => outputs number of formulae in file
# 		 ruby get_yaml.rb /path/to/config.yaml [0-9]+ [(name)(version)(args)] => outputs info from each formula
#
#  Homepage: https://github.com/bjschafer/brewmaster
#
#    Author: Braxton Schafer <braxton.schafer@gmail.com> (bjs)
#
# Changelog:
# 
###############################################################################


require 'Psych'

data = Psych.load_file(ARGV[0])

if ARGV.length < 2
	puts data["formulae"].length
else
	puts data["formulae"][Integer(ARGV[1])][ARGV[2]] 
end