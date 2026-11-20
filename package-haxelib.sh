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
    for tool in python3 pkg-config; do
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
    mkdir -p "$runtime_dir"
    cp "$PATH_TO_VENDOR_NDLL_DIR/Linux64/opencv.a" "$runtime_dir/"
    cp "$PATH_TO_OPEN_CV_SOURCE_DIR/LICENSE" "$runtime_dir/OpenCV-LICENSE.txt"
    python3 - "$PATH_TO_OPEN_CV_INSTALL_DIR" "$runtime_dir" <<'PYTHON'
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

install, runtime = map(Path, sys.argv[1:])
licenses = install / "share/licenses/opencv5"
if licenses.is_dir():
    shutil.copytree(licenses, runtime / "licenses")

archives = {}
for archive in install.rglob("*.a"):
    if archive.name in archives:
        raise SystemExit(f"Duplicate static archive: {archive.name}")
    archives[archive.name] = archive
    shutil.copy2(archive, runtime / archive.name)

# System dependencies exported by the pinned Linux OpenCV 5.1.0 build.
flags = ["-ljpeg", "-lwebp", "-lwebpmux", "-lwebpdemux", "-lpng", "-ltiff",
         "-lz", "-ldl", "-lm", "-lpthread", "-lrt"]
flags.extend(shlex.split(subprocess.check_output(
    ["pkg-config", "--libs", "Qt5Widgets", "Qt5Test", "Qt5Concurrent"],
    text=True)))
if any("NOTFOUND" in flag for flag in flags):
    raise SystemExit("Unresolved system dependency in linker flags")
root = ET.Element("xml")
target = ET.SubElement(root, "target", id="haxe")
def link(value):
    ET.SubElement(target, "lib", name=value)

# Keep all CFFI registration objects, including primitives called only by name.
link("-Wl,--whole-archive")
link("${this_dir}/opencv.a")
link("-Wl,--no-whole-archive")
link("-Wl,--start-group")
for archive in sorted(archives):
    link("${this_dir}/" + archive)
link("-Wl,--end-group")
for flag in flags:
    if flag.startswith("-L"):
        # OpenCV's private build paths must not escape into the package.
        continue
    if flag.startswith("-l") and "lib" + flag[2:] + ".a" in archives:
        continue
    if flag.startswith("-lopencv_"):
        raise SystemExit(f"Missing static OpenCV library: {flag}")
    if str(install) in flag:
        raise SystemExit(f"Unresolved build path in linker flags: {flag}")
    link(flag)
ET.indent(root)
ET.ElementTree(root).write(runtime / "Build.xml", encoding="unicode")
PYTHON
}

updateDevelopmentRuntime(){
    mkdir -p "$PROJECT_ROOT_LOCATION/native"
    rm -rf "$PROJECT_ROOT_LOCATION/native/Linux64"
    cp -R "$PATH_TO_TEMP_DIR/native/Linux64" "$PROJECT_ROOT_LOCATION/native/"
}

copyPackageFiles(){
    cp -R src "$PATH_TO_TEMP_DIR/"
    cp haxelib.json extraParams.hxml README.md LICENSE "$PATH_TO_TEMP_DIR/"
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
