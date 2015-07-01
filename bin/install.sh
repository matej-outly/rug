#!/bin/bash

#
# Install all RUG gems
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
for gem in rug_support rug_record rug_controller rug_builder rug_view; do
	gem install "$build_dir"/"$gem"-*
done

# Root rug gem
gem install "$build_dir"/rug-*
