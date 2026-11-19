# spilehx-opencv

Haxe bindings for OpenCV 2.4.13.7, with a native runtime for Linux x86_64.

## Requirements

- Haxe 4.x and hxcpp.
- A C++ compiler.
- A Linux x86_64 system compatible with the supplied native binaries, including
  their system dependencies such as Qt and GTK.

Only the C++ target is supported. A prebuilt runtime does not require users to
build OpenCV, but it still requires compatible system libraries. Supported Linux
distributions and exact system package requirements have not yet been validated.

## Install the library

```sh
haxelib install hxcpp
haxelib git spilehx-opencv https://github.com/spilehx/spilehx-opencv
```

Git installation requires the maintainer to commit the prepared `native/Linux64/`
runtime described below. Haxelib does not run `package-haxelib.sh` during Git
installation. An installation without that runtime will fail when compiling.

Once a release has been submitted to the Haxelib registry, users can instead run
`haxelib install spilehx-opencv`. A packaged ZIP can also be installed directly
with `haxelib install /path/to/spilehx-opencv-VERSION-linux64.zip`.

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
contains `cv/`, `haxelib.json`, `extraParams.hxml`, `README.md`, `LICENSE`, and
`native/Linux64/` with `opencv.ndll`, OpenCV shared libraries and the OpenCV
license. It does not install or publish anything.

The same command prepares `native/Linux64` in this checkout. For local development,
register the checkout once with:

```sh
haxelib dev spilehx-opencv /absolute/path/to/hx-opencv
```

Then use the same application build commands above. Re-run the packaging command
when changing the native bindings. Prebuilt releases must be validated on the Linux
distributions they support; Linux x86_64 alone does not guarantee compatibility.

## Publish a release

1. Update the version and release notes in `haxelib.json`.
2. Run `bash package-haxelib.sh` on Linux x86_64.
3. Commit and push the release files, including every generated file in
   `native/Linux64/`. This directory is allowed by `.gitignore`; build intermediates
   in `vendor/`, `build/`, `obj/`, `ndll/`, and release archives in `dist/` stay ignored.
4. Validate the generated ZIP and a fresh Git installation with a separate consumer
   application on each Linux distribution you intend to support. Document the
   required system packages and supported distributions here.
5. Optionally tag the release and attach the ZIP to a GitHub Release. GitHub Release
   attachments are not installed by `haxelib git`.

To publish to the Haxelib registry, register a Haxelib account if needed and submit
the generated ZIP. For the current version:

```sh
haxelib submit dist/spilehx-opencv-0.0.4-linux64.zip
```

Publishing to GitHub and submitting to Haxelib are separate steps. Keep the native
runtime and Haxe bindings from the same release together.

## License

The bindings are distributed under the MIT license in `LICENSE`. The bundled
OpenCV runtime includes its own license in `native/Linux64/OpenCV-LICENSE.txt`.
