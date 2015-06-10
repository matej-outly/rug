#!/bin/bash

#
# Build all RUG gems
#

# Number of arguments
if [ "$#" != "0" ]; then
	echo "Usage: $0"
	exit 1
fi

# Basic setting
script_dir="`cd \"\`dirname \\\"$0\\\"\`\"; pwd`"
root_dir="$script_dir/.."
output_dir="$root_dir/build"

# Make output directory
mkdir -p "$output_dir"

# All rug_* gems
for gem in rug_support rug_record rug_controller rug_builder; do
	cd "$root_dir/$gem"
	gem build $gem.gemspec
	mv *.gem "$output_dir"
done

# Root rug gem
cd "$root_dir"
gem build rug.gemspec
mv *.gem "$output_dir"
