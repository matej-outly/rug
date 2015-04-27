#!/bin/bash

#
# Build all rug gems
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

# Rug Support
cd "$root_dir/rug_support"
gem build rug_support.gemspec
mv *.gem "$output_dir"

# Rug Record
cd "$root_dir/rug_record"
gem build rug_record.gemspec
mv *.gem "$output_dir"

# Rug Builder
cd "$root_dir/rug_builder"
gem build rug_builder.gemspec
mv *.gem "$output_dir"

# Rug
cd "$root_dir"
gem build rug.gemspec
mv *.gem "$output_dir"