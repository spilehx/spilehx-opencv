#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"
project_dir="$PWD"

haxe build_cpp.hxml

export LD_LIBRARY_PATH="$project_dir/ndll/Linux64:$project_dir/vendor/lib/opencv/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

cd "$project_dir/samples"
exec "$project_dir/bin/Sample1"
