# spilehx-opencv

OpenCV bindings for Haxe, providing computer vision and image processing for the **C++ (`cpp`) target only**. Tested only on Linux.

All openCV dependencies internally packaged.
Based on openCV 5.1.0

**Early alpha pre-release:** this library may contain bugs. Use with caution.
Small subset of openCV implemented. See samples for working parts of the API

## Install and use

Install from Git:

```sh
haxelib git spilehx-opencv https://github.com/spilehx/spilehx-opencv.git
```

Add the library to your project's `.hxml` file and compile to C++:

```hxml
-lib spilehx-opencv
```

## Samples

Example code is in [samples/src/](samples/src/), with build configurations in [samples/](samples/).
