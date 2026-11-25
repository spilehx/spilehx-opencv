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

## Native packaging

`bash package-haxelib.sh` builds OpenCV with its bundled static JPEG codec and
includes the codec archive and licenses in the haxelib. Existing OpenCV installs
without the bundled archive must be rebuilt: when packaging prompts, choose to
rebuild the existing installation. Other system dependencies, including Qt and
other image codecs, remain shared and may themselves require a JPEG runtime.

## Video capture

Use `spilehx.cv.VideoCapture` for camera or file input without creating windows:

```haxe
import spilehx.cv.VideoCapture;

var capture = VideoCapture.fromCamera(0);
if (capture == null)
    throw "Could not open webcam 0";

try {
    var frame = capture.readFrame();
    if (frame != null) {
        // Process the frame here.
    }
} catch (error:Dynamic) {
    capture.release();
    throw error;
}
capture.release();
```

`VideoCapture.fromFile()` opens files supported by the installed backends.
Frames own independent storage and remain valid after capture release.
Use `HighGUI` separately when displaying images or handling window events.
The current package still requires its linked Qt system libraries for headless use.

Capture methods and `CAP_*` constants have moved from `HighGUI` to `VideoCapture`.
Replace `HighGUI.captureFromCamera()` / `captureFromFile()` with
`VideoCapture.fromCamera()` / `fromFile()`. The former `highgui.Capture` handle is
now `VideoCapture`, with instance methods `readFrame()`, `grabFrame()`,
`retrieveFrame()`, `getProperty()`, `setProperty()` and `release()`.
Rebuild and repackage the native wrapper before using this API; the new primitive
names require matching native archives.
