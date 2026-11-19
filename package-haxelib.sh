#!/bin/bash

set -euo pipefail

init(){
    validateBuildEnvironment
    configurePackage
    buildNativeRuntime
    createTempDir
    prepareNativeRuntime
    updateDevelopmentRuntime
    copyPackageFiles
    createArchive

    echo "Created $PATH_TO_ARCHIVE"
}

validateBuildEnvironment(){
    if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
        echo "Only Linux x86_64 packages are currently supported." >&2
        exit 1
    fi
    local tool
    for tool in python3 patchelf; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "$tool is required to build and package the haxelib." >&2
            exit 1
        fi
    done
}

configurePackage(){
    local version
    version="$(python3 -c 'import json; print(json.load(open("haxelib.json"))["version"])')"
    PATH_TO_ARCHIVE="$PROJECT_ROOT_LOCATION/dist/spilehx-opencv-$version-linux64.zip"
    mkdir -p "$PROJECT_ROOT_LOCATION/dist"
}

buildNativeRuntime(){
    bash build_vendor.sh
}

createTempDir(){
    PATH_TO_TEMP_DIR="$(mktemp -d)"
    trap removeTempDir EXIT
}

removeTempDir(){
    if [[ -n "$PATH_TO_TEMP_DIR" && -d "$PATH_TO_TEMP_DIR" ]]; then
        rm -rf "$PATH_TO_TEMP_DIR"
    fi
}

prepareNativeRuntime(){
    local runtime_dir="$PATH_TO_TEMP_DIR/native/Linux64"
    local library
    mkdir -p "$runtime_dir"
    # Store real files under every SONAME, independent of ZIP symlink support.
    cp -L "$PATH_TO_VENDOR_NDLL_DIR/Linux64/opencv.ndll" \
        "$PATH_TO_OPEN_CV_INSTALL_DIR/lib/"libopencv_*.so* "$runtime_dir/"
    cp "$PATH_TO_OPEN_CV_SOURCE_DIR/LICENSE" "$runtime_dir/OpenCV-LICENSE.txt"
    for library in "$runtime_dir/opencv.ndll" "$runtime_dir/"*.so*; do
        # Each library resolves its dependencies beside itself after relocation.
        patchelf --set-rpath '$ORIGIN' "$library"
    done
}

updateDevelopmentRuntime(){
    mkdir -p "$PROJECT_ROOT_LOCATION/native"
    rm -rf "$PROJECT_ROOT_LOCATION/native/Linux64"
    cp -R "$PATH_TO_TEMP_DIR/native/Linux64" "$PROJECT_ROOT_LOCATION/native/"
}

copyPackageFiles(){
    cp -R cv "$PATH_TO_TEMP_DIR/"
    cp haxelib.json extraParams.hxml README.md "$PATH_TO_TEMP_DIR/"
}

createArchive(){
    # Write a fresh archive; updating an existing ZIP could retain obsolete files.
    python3 - "$PATH_TO_TEMP_DIR" "$PATH_TO_ARCHIVE" <<'PYTHON'
from pathlib import Path
import sys
import zipfile

root = Path(sys.argv[1])
with zipfile.ZipFile(sys.argv[2], "w", zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(root.rglob("*")):
        if path.is_file():
            archive.write(path, path.relative_to(root))
PYTHON
}

#############################################
setWorkingDirToScriptLocation(){
    cd "$(dirname "$0")"
    PROJECT_ROOT_LOCATION="$PWD"
}

## --- Startup ---
PROJECT_ROOT_LOCATION=""
PATH_TO_ARCHIVE=""
PATH_TO_TEMP_DIR=""
setWorkingDirToScriptLocation
source .env

init
