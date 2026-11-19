#!/bin/bash

# ===== CONFIG =====
PATH_TO_VENDOR_DIR="./vendor"
PATH_TO_VENDOR_SOURCE_DIR="$PATH_TO_VENDOR_DIR/source"

## openCV config
OPEN_CV_LIB_NAME="opencv"
PATH_TO_OPEN_CV_SOURCE_DIR="$PATH_TO_VENDOR_DIR/source/$OPEN_CV_LIB_NAME"


OPEN_CV_SOURCE_URL="https://github.com/opencv/opencv/archive/refs/tags/2.4.13.7.zip"




init(){
    validateDir $PATH_TO_VENDOR_DIR
    validateDir $PATH_TO_VENDOR_SOURCE_DIR




    validateOpenCVBuild
}


validateOpenCVBuild(){
    echo "Validating OpenCV build..."
    validateOpenCVSource

}


validateOpenCVSource(){
    echo "Validating OpenCV source..."

    if [ "$(doesDirExists $PATH_TO_OPEN_CV_SOURCE_DIR)" == "false" ]; then
        echo "Directory $PATH_TO_OPEN_CV_SOURCE_DIR does not exist. Creating now"
        mkdir -p $PATH_TO_OPEN_CV_SOURCE_DIR
    fi

}





#############################################
gotToProjectRoot(){
    cd $PROJECT_ROOT_LOCATION
}

setWorkingDirToScriptLocation(){
    cd "$(dirname "$0")"
    PROJECT_ROOT_LOCATION=$(pwd)
}

getHostName(){
    echo "$(echo $(uname -n) | tr '[a-z]' '[A-Z]')"
}

doesDirExists(){
    if [ -d $@ ] 
    then
        echo "true" 
    else
        echo "false"
    fi
}

validateDir(){
    if [ "$(doesDirExists $1)" == "false" ]; then
        echo "Directory $1 does not exist. Creating now"
        mkdir -p $1
    fi
}


## --- Startup ---
PROJECT_ROOT_LOCATION=""
setWorkingDirToScriptLocation

init $1













# set -euo pipefail

# project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# source_dir="$project_dir/vendor/source/opencv-2.4.13.7"
# build_dir="$source_dir/build"
# install_dir="$project_dir/vendor/opencv-install"

# if ! command -v cmake >/dev/null 2>&1; then
#     echo "CMake is required to build OpenCV." >&2
#     exit 1
# fi

# if [[ ! -f "$source_dir/CMakeLists.txt" ]]; then
#     echo "OpenCV source not found at $source_dir" >&2
#     exit 1
# fi

# # OpenCV 2.4 explicitly selects a macOS policy behavior removed in CMake 4.
# # This targeted, repeatable update lets current CMake configure the source.
# if cmake --version | head -n 1 | grep -Eq 'version ([4-9]|[1-9][0-9]+)\.'; then
#     sed -i 's/cmake_policy(SET CMP0042 OLD)/cmake_policy(SET CMP0042 NEW)/' \
#         "$source_dir/CMakeLists.txt"
# fi

# # Keep the legacy OpenCV installation separate from system libraries.
# # GTK provides the window backend used by Sample1. Video codecs and GPU
# # support are unnecessary for this image sample.
# cmake -S "$source_dir" -B "$build_dir" \
#     -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DCMAKE_INSTALL_PREFIX="$install_dir" \
#     -DCMAKE_INSTALL_LIBDIR=lib \
#     -DBUILD_SHARED_LIBS=ON \
#     -DBUILD_TESTS=OFF \
#     -DBUILD_PERF_TESTS=OFF \
#     -DBUILD_EXAMPLES=OFF \
#     -DBUILD_DOCS=OFF \
#     -DBUILD_opencv_apps=OFF \
#     -DBUILD_opencv_python=OFF \
#     -DBUILD_opencv_java=OFF \
#     -DBUILD_opencv_gpu=OFF \
#     -DBUILD_opencv_ocl=OFF \
#     -DBUILD_opencv_nonfree=ON \
#     -DBUILD_opencv_contrib=ON \
#     -DBUILD_opencv_legacy=ON \
#     -DWITH_CUDA=OFF \
#     -DWITH_OPENCL=OFF \
#     -DWITH_FFMPEG=OFF \
#     -DWITH_GSTREAMER=OFF \
#     -DWITH_OPENEXR=OFF \
#     -DWITH_QT=OFF \
#     -DWITH_GTK=ON

# cmake --build "$build_dir" --parallel "${JOBS:-4}"
# cmake --install "$build_dir"

# echo "OpenCV headers installed to: $install_dir/include"
# echo "OpenCV libraries installed to: $install_dir/lib"
