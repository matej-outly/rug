#!/bin/bash

#
# Install all rug gems
#

# Number of arguments
if [ "$#" != "0" ]; then
	echo "Usage: $0"
	exit 1
fi

# Basic setting
script_dir="`cd \"\`dirname \\\"$0\\\"\`\"; pwd`"
root_dir="$script_dir/.."
build_dir="$root_dir/build"

# Install gems 
gem install "$build_dir"/rug_support-*
gem install "$build_dir"/rug_record-*
