#!/bin/bash

#
# Publish all RUG gems
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

# All rug_* gems
cat "$script_dir/modules.conf" | while read module; do
	gem inabox "$build_dir"/"$module"-*
done

# Root rug gem
gem inabox "$build_dir"/rug-*
