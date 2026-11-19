#!/bin/bash

set -euo pipefail


# ===== CONFIG =====

# PATH_TO_VENDOR_DIR="./vendor"
# PATH_TO_TEMP_DIR="$PATH_TO_VENDOR_DIR/.temp"
# PATH_TO_VENDOR_SOURCE_DIR="$PATH_TO_VENDOR_DIR/source"
# PATH_TO_VENDOR_LIB_DIR="$PATH_TO_VENDOR_DIR/lib"

# ## openCV config
# OPEN_CV_LIB_NAME="opencv"
# PATH_TO_OPEN_CV_SOURCE_DIR="$PATH_TO_VENDOR_SOURCE_DIR/$OPEN_CV_LIB_NAME"
# PATH_TO_OPEN_CV_SOURCE_BUILD_DIR="$PATH_TO_OPEN_CV_SOURCE_DIR/build"
# PATH_TO_OPEN_CV_INSTALL_DIR="$PATH_TO_VENDOR_LIB_DIR/$OPEN_CV_LIB_NAME"

# OPEN_CV_SOURCE_URL="https://github.com/opencv/opencv/archive/refs/tags/2.4.13.7.zip"




init(){

    ## just in case cleanup and initial setup of folders
    removeTempDir
    validateDir $PATH_TO_VENDOR_DIR
    validateDir $PATH_TO_VENDOR_SOURCE_DIR
    validateDir $PATH_TO_VENDOR_LIB_DIR


    validateOpenCVBuild

    ## just in case cleanup
    removeTempDir
}

validateOpenCVBuild(){
    ECHO_INFO "Validating OpenCV build..."
    validateOpenCVSource
    startOpenCVBuild
    buildOpenCVWrapper
}

buildOpenCVWrapper(){
    ECHO_INFO "Building static OpenCV wrapper..."

    createTempDir

    rm -rf $PATH_TO_VENDOR_NDLL_DIR
    validateDir $PATH_TO_VENDOR_NDLL_DIR
    haxelib run hxcpp Build.xml -DHXCPP_M64 \
        -I"$PATH_TO_VENDOR_DIR" \
        -DOPENCV_INCLUDE_DIR="$PATH_TO_OPEN_CV_INSTALL_DIR/include" \
        -DOPENCV_LIB_DIR="$PATH_TO_OPEN_CV_INSTALL_DIR/lib" \
        -DPATH_TO_VENDOR_NDLL_DIR="$PATH_TO_VENDOR_NDLL_DIR" \
        -DPATH_TO_TEMP_DIR="$PATH_TO_TEMP_DIR"

    removeTempDir
}

startOpenCVBuild(){
    echo ""

    if [ "$(doesDirExists $PATH_TO_OPEN_CV_INSTALL_DIR)" == "true" ]; then
        ECHO_INFO "OpenCV install already exists."

        if requestConfirm "Do you want to delete the existing OpenCV install directory and rebuild?"; then
            ECHO_WARN "Deleting existing OpenCV source and lib directory..."
            rm -rf $PATH_TO_OPEN_CV_INSTALL_DIR
        fi
    fi


    if [[ ! -f "$PATH_TO_OPEN_CV_INSTALL_DIR/lib/libopencv_core.a" ]]; then


        ECHO_INFO "Starting OpenCV build..."

        if ! command -v cmake >/dev/null 2>&1; then
            ECHO_ERROR "CMake is required to build OpenCV." >&2
            exit 1
        fi


        if [[ ! -f "$PATH_TO_OPEN_CV_SOURCE_DIR/CMakeLists.txt" ]]; then
            ECHO_ERROR "OpenCV source not found at $PATH_TO_OPEN_CV_SOURCE_DIR" >&2
            exit 1
        fi


        # OpenCV 2.4 explicitly selects a macOS policy behavior removed in CMake 4.
        # This targeted, repeatable update lets current CMake configure the source.
        if cmake --version | head -n 1 | grep -Eq 'version ([4-9]|[1-9][0-9]+)\.'; then
            sed -i 's/cmake_policy(SET CMP0042 OLD)/cmake_policy(SET CMP0042 NEW)/' \
                "$PATH_TO_OPEN_CV_SOURCE_DIR/CMakeLists.txt"
        fi

        validateDir $PATH_TO_OPEN_CV_INSTALL_DIR

        ECHO_INFO "Building OpenCV in $PATH_TO_OPEN_CV_SOURCE_BUILD_DIR"
        # Keep the legacy OpenCV installation separate from system libraries.
        # Qt provides the button, overlay and status bar functions used by the wrapper.
        # Video codecs and GPU support are unnecessary for the image samples.
        cmake -S "$PATH_TO_OPEN_CV_SOURCE_DIR" -B "$PATH_TO_OPEN_CV_SOURCE_BUILD_DIR" \
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_INSTALL_PREFIX="$PATH_TO_OPEN_CV_INSTALL_DIR" \
            -DCMAKE_INSTALL_LIBDIR=lib \
            -DBUILD_SHARED_LIBS=OFF \
            -DBUILD_TESTS=OFF \
            -DBUILD_PERF_TESTS=OFF \
            -DBUILD_EXAMPLES=OFF \
            -DBUILD_DOCS=OFF \
            -DBUILD_opencv_apps=OFF \
            -DBUILD_opencv_python=OFF \
            -DBUILD_opencv_java=OFF \
            -DBUILD_opencv_gpu=OFF \
            -DBUILD_opencv_ocl=OFF \
            -DBUILD_opencv_nonfree=ON \
            -DBUILD_opencv_contrib=ON \
            -DBUILD_opencv_legacy=ON \
            -DWITH_CUDA=OFF \
            -DWITH_OPENCL=OFF \
            -DWITH_FFMPEG=OFF \
            -DWITH_GSTREAMER=OFF \
            -DWITH_OPENEXR=OFF \
            -DWITH_QT=ON \
            -DWITH_GTK=ON

        echo ""
        ECHO_INFO "Configuring OpenCV build with CMake..."
        cmake --build "$PATH_TO_OPEN_CV_SOURCE_BUILD_DIR" --parallel "${JOBS:-4}"
        cmake --install "$PATH_TO_OPEN_CV_SOURCE_BUILD_DIR"


        echo ""
        ECHO_INFO "OpenCV build and installation completed."

        echo "OpenCV headers installed to: $PATH_TO_OPEN_CV_INSTALL_DIR/include"
        echo "OpenCV libraries installed to: $PATH_TO_OPEN_CV_INSTALL_DIR/lib"

    fi

}

validateOpenCVSource(){
    echo ""
    ECHO_INFO "Validating OpenCV source..."

    if [ "$(doesDirExists $PATH_TO_OPEN_CV_SOURCE_DIR)" == "true" ]; then
        ECHO_INFO "OpenCV source directory already exists."
        if requestConfirm "Do you want to delete the existing OpenCV source directory and action redownload?"; then
            ECHO_WARN "Deleting existing OpenCV source and lib directory..."
            rm -rf $PATH_TO_OPEN_CV_SOURCE_DIR
            rm -rf $PATH_TO_OPEN_CV_INSTALL_DIR
        else
            ECHO_INFO "Will proceed with current openCV version."
        fi
    fi

    ## Check if OpenCV source directory exists after potential deletion
    if [ "$(doesDirExists $PATH_TO_OPEN_CV_SOURCE_DIR)" == "false" ]; then
        getOpenCVSource
    fi

}

getOpenCVSource(){
    ECHO_INFO "Downloading OpenCV source..."
    local path_to_zip="$PATH_TO_TEMP_DIR/$OPEN_CV_LIB_NAME.zip"
    createTempDir

    wget -O "$path_to_zip" $OPEN_CV_SOURCE_URL
    # unzip "$PATH_TO_TEMP_DIR/opencv.zip" -d "$PATH_TO_OPEN_CV_SOURCE_DIR"

    ECHO_WARN "Directory $PATH_TO_OPEN_CV_SOURCE_DIR does not exist. Creating now"
    mkdir -p $PATH_TO_OPEN_CV_SOURCE_DIR
    ## ensure that code is in top-level of the source directory
    bsdtar -xf "$path_to_zip" -C "$PATH_TO_OPEN_CV_SOURCE_DIR" --strip-components=1
    removeTempDir
}

createTempDir(){
    validateDir $PATH_TO_TEMP_DIR
}

removeTempDir(){
    if [ "$(doesDirExists $PATH_TO_TEMP_DIR)" == "true" ]; then
        rm -rf $PATH_TO_TEMP_DIR
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

requestConfirm() {
    # Prompt the user for confirmation (y/n).
    # Usage: requestConfirm "Question?" [doExit]
    #   $1: Question to display.
    #   $2: Optional boolean (true/false). If true, exits on no (default: false).
    # Returns: 0 for yes, 1 for no (unless doExit=true).
    # Example:
    #   requestConfirm "Continue?" true
    #   if requestConfirm "Install dependencies?"; then echo "Installing..."; fi


    local answer
    local doExit="${2:-false}"

    read -r -p $'\033[0;32m'"$1 [y/n]: "$'\033[0m' answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        return 0
    fi

    [[ "$doExit" == "true" ]] && exit 1
    return 1
}


ECHO_INFO() {
    echo -e "\033[0;34m$*\033[0m"
}

ECHO_WARN() {
    echo -e "\033[0;33mWARN: $*\033[0m"
}

ECHO_ERROR() {
    echo -e "\033[0;31mERROR: $*\033[0m"
}


## --- Startup ---
PROJECT_ROOT_LOCATION=""
setWorkingDirToScriptLocation

source .env

init




