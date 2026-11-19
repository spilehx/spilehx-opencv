#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"
project_dir="$PWD"

source .env

haxe build_cpp.hxml

ndll_dir="$(realpath -m "$PATH_TO_VENDOR_NDLL_DIR/Linux64")"
opencv_lib_dir="$(realpath -m "$PATH_TO_OPEN_CV_INSTALL_DIR/lib")"
export LD_LIBRARY_PATH="$ndll_dir:$opencv_lib_dir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

cd "$project_dir/samples"
exec "$project_dir/bin/Sample1"
