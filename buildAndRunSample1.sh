#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"
project_dir="$PWD"

# haxe build.hxml

export LD_LIBRARY_PATH="$project_dir/vendor/lib/opencv/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
# Keep Neko's standard libraries available when NEKOPATH is initially unset.
export NEKOPATH="$project_dir/ndll/Linux64:${NEKOPATH:-/usr/lib/x86_64-linux-gnu/neko}"

cd "$project_dir/samples"
exec neko "$project_dir/bin/Sample1.n"
