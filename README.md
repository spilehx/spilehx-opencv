# spilehx-opencv

Haxe bindings for OpenCV, with a native runtime for Linux x86_64.

## Requirements

- Haxe 4.x and hxcpp.
- A C++ compiler.
- A Linux x86_64 system compatible with the supplied native binaries, including
  their system dependencies such as Qt and GTK.

## Install the library

```sh
haxelib install hxcpp
haxelib install spilehx-opencv
```

Installation by name requires a published release containing the bundled native
runtime described below.

## Build and run your application

Add the library to your project's `build.hxml`. For an application with
`src/Main.hx`:

```hxml
-lib spilehx-opencv
-cp src
-main Main
-cpp bin
```

Use the bindings through imports such as `cv.Core` and `cv.HighGUI`.

Compile from your project directory:

```sh
haxe build.hxml
./bin/Main
```

Using `-lib spilehx-opencv` automatically selects the 64-bit build and copies the
bundled runtime into `bin/native`. The bindings find it relative to the executable;
no deployment command, launcher or `LD_LIBRARY_PATH` setup is required.

Keep the `native` directory beside the executable when distributing or moving
your application. The target machine needs compatible system libraries, but does
not need Haxe or the original library checkout. Application assets still resolve
relative to the working directory unless your application handles them differently.

## Build and package the haxelib

For library development and releases, install the native build prerequisites
(including CMake, the C++ compiler, Qt/GTK development dependencies, `wget` and
`bsdtar`), plus Python 3 and `patchelf`. Configure paths in `.env`, then run from
the library directory:

```sh
bash package-haxelib.sh
```

This builds OpenCV and the wrapper, prepares relocatable native libraries, and
creates `dist/spilehx-opencv-VERSION-linux64.zip` for publication. The package
contains the bindings, automatic build integration, native runtime and OpenCV
license. It does not install or publish anything.

The same command prepares `native/Linux64` in this checkout. For local development,
register the checkout once with:

```sh
haxelib dev spilehx-opencv /absolute/path/to/hx-opencv
```

Then use the same application build commands above. Re-run the packaging command
when changing the native bindings. Prebuilt releases must be validated on the Linux
distributions they support; Linux x86_64 alone does not guarantee compatibility.
