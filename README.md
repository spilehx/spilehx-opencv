# spilehx-opencv

Modern OpenCV **5.1.0** bindings for Haxe/hxcpp on **Linux x86_64**, with OpenCV
and the CFFI wrapper linked statically into the consumer executable.

## Requirements

- Haxe 4.x and hxcpp; implementation checks used Haxe 4.3.6 and hxcpp 4.3.2.
- A C++ compiler; rebuilding the wrapper requires C++17.
- System development/linker files for Qt5 Widgets, Test and Concurrent (including
  Core/Gui), JPEG, WebP, PNG and TIFF, plus zlib and the Linux C/C++ runtime.
- A working graphical display for window operations; Qt/X11 was exercised locally.

The supported target is Linux x86_64 C++ only. The prepared package includes
OpenCV archives, bundled dependency archives and linker metadata. Consumers need
Haxe, hxcpp, a compiler and the compatible system libraries. Distribution across
other Linux installations requires checking their runtime/ABI compatibility.

## Install and build a consumer

Install hxcpp and the prepared release ZIP:

```sh
haxelib install hxcpp
haxelib install /path/to/spilehx-opencv-0.0.4-linux64.zip
```

Git or development-checkout installations require a prepared `native/Linux64/`
bundle. Haxelib does not invoke the packaging script during Git installation.

For an application with `src/Main.hx`, use:

```hxml
-lib spilehx-opencv
-cp src
-main Main
-cpp bin
```

```sh
haxe build.hxml
./bin/Main
```

Inside your application, for example:

```haxe
import spilehx.cv.Core;
import spilehx.cv.ImgProc;
import spilehx.cv.HighGUI;

var source = HighGUI.loadImage("input.png");
if (source == null) throw "Could not decode input.png";
var grey = Core.createMat();
ImgProc.cvtColor(source, grey, ImgProc.BGR2GRAY);
if (!HighGUI.saveImage("grey.png", grey)) throw "Could not write grey.png";
```

The Haxelib macro selects the 64-bit build and includes the packaged static linker
metadata. The executable still needs compatible system libraries and its assets.
It can run without Haxe or an OpenCV installation. Distribute the applicable
licenses alongside your application.

## Supported API and breaking changes

The modules are `Core`, `ImgProc`, `Features2D`, `Video` and `HighGUI` under
`spilehx.cv`. Direct OpenCV modules are core, imgproc, imgcodecs, features, video,
highgui and videoio, together with their installed transitive dependencies.

- **Matrices:** `Mat` owns a `cv::Mat` header and reference-counted storage. `Arr`
  and the optional `Image` typedef both mean `Mat`. Use `rows`, `cols`, `type`,
  `depth`, `channels` and byte `step`; legacy image layout properties are gone.
  `Core.createMat()` creates an empty destination; operations resize destinations
  through their stored headers. `Core.cloneMat` copies pixels. Type encoding uses
  OpenCV 5's channel shift of **5** and depth mask of **31**.
- **Access and views:** typed `Mat.get_*`/`set_*` methods check depth and bounds,
  use logical component indices and account for row stride. Views returned by
  `getRows`, `getCols`, `getDiag` and `getSubRect` keep shared storage alive without
  the source wrapper. View methods return a Mat directly; caller headers and the
  legacy row-step argument were removed. Raw-pointer/CVBuffer access is gone.
- **Core operations:** arithmetic, masks, statistics, conversions, indexing,
  split/merge, DCT/DFT and drawing use modern Mat APIs. `convertScale` takes an
  explicit destination depth before scale/shift; `-1` preserves source depth.
  `split(src)` returns channel Mats. `scaleAdd` takes one numeric scale.
  `TermCriteria.maxCount` replaces `max_iter`.
- **Processing:** morphology kernels are Mats from `ImgProc.getStructuringElement`
  or ordinary matrix allocation; anchors are explicit optional Points.
  `morphologyEx` needs no scratch image. `equalizeHistAdaptive` uses CLAHE clip-limit
  and tile-grid parameters, with different semantics from the old implementation.
  Use the specific filter methods instead of `smooth`. Corner detection needs no
  scratch images; distance transforms no longer accept custom legacy weights.
- **Drawing:** `putText` takes a font face, one scale, color, thickness and line
  type directly. Font objects and anisotropic/sheared text settings were removed.
- **Features:** `Features2D.gfft` uses GFTTDetector; `Features2D.sift` creates SIFT
  under `features2d`. `SIFT.detectAndCompute` writes a descriptor Mat with one
  128-column `_32FC1` row per keypoint. Keypoint arrays resize to the result count.
  `KeyPoint.pt` returns an independent copy. BRISK, SURF and NonFree were removed.
- **Flow:** sparse `calcOpticalFlowPyrLK` uses point/status/error arrays, optional
  window/criteria and native `OPTFLOW_*` flags. Caller pyramid buffers and the
  count argument were removed. Farneback writes a resizable `_32FC2` flow Mat.
  BM, HS and legacy dense LK were removed.
- **IO/GUI:** `loadImage` returns a Mat or null; select `IMREAD_*` flags.
  `loadImageM` was removed. `saveImage` returns Bool, `namedWindow` returns Void
  and `waitKey` returns the key code or `-1` on timeout. Trackbar and mouse callbacks
  remain rooted until window destruction. `initSystem`, combined `convertImage`
  flags, OpenGL bindings and Qt-specific buttons/overlays/status bars were removed.
- **Capture:** `captureFromFile` accepts an optional backend, `grabFrame` returns
  Bool, and `retrieveFrame`/`readFrame` return independent Mats or null on failure.
  `readFrame` replaces `queryFrame`. Properties have get/set methods;
  `releaseCapture` closes the input immediately, and GC also releases the handle.
  Vendor-specific legacy property constants were removed.

OpenCV exceptions at retained native entry points become Haxe errors. Failed
ordinary image reads return null; failed writes return false, while invalid
encoding requests can raise an error.

## Capture backends and limitations

The pinned installation has Qt and V4L2/OBSENSOR support; FFmpeg, GStreamer and
OpenGL are disabled. Built-in image-sequence and MJPEG file backends are present.
General compressed-video playback is limited to the configured backends. Hardware
capture and arbitrary video codecs have not been exercised.

Use an explicit image-sequence backend for deterministic file input:

```haxe
var capture = HighGUI.captureFromFile("frame-%02d.png", HighGUI.CAP_IMAGES);
if (capture == null) throw "Could not open sequence";
var frame = HighGUI.readFrame(capture);
HighGUI.releaseCapture(capture);
// frame remains valid after release and later capture operations.
```

Capture property support depends on the backend. This wrapper exposes file inputs;
backend compilation alone does not guarantee a usable device or video format.

## Build and package

Install the compiler, hxcpp, CMake, Python 3, pkg-config and the development packages
for Qt5, JPEG, WebP, PNG, TIFF and zlib. Source downloads additionally use `wget`
and `bsdtar`. Configure `.env`, then run:

```sh
bash package-haxelib.sh
```

Decline the source/install deletion prompts to reuse the existing OpenCV 5.1.0
installation at `vendor/lib/opencv`. The wrapper includes `include/opencv5` and
uses C++17. The existing OpenCV build cache and installed modules are preserved
when reusing the installation.

Packaging recursively collects installed `.a` files, rejects duplicate archive
names, preserves CFFI registration with whole-archive, and groups the OpenCV and
bundled archives. A short system link list in `package-haxelib.sh` is pinned to
this Linux build; pkg-config supplies only the Qt flags. Update that list from the
installed CMake exports if the OpenCV configuration changes.

The script refreshes the generated `native/Linux64/` bundle and writes
`dist/spilehx-opencv-0.0.4-linux64.zip`. It includes Haxe sources, metadata, linker
XML, static archives and licenses. For checkout-based development after packaging:

```sh
haxelib dev spilehx-opencv /absolute/path/to/hx-opencv
```

Repackage native changes and rebuild consumers with matching Haxe sources and
archives. Keep Linux target guards in place.

## Samples and validation

From `samples/`, compile the main showcase and run it from `samples/bin/`:

```sh
haxe build-betterSample.hxml
cd bin
./BetterSample
```

It loads `test.jpg`, processes and saves six images, draws GFFT corners, displays
six windows and offers a threshold trackbar. Press a key in an image window to
exit. `haxe build.hxml` compiles the three smaller image examples.

Staged checks exercised matrix allocation/access, stride and view lifetime,
destination mutation, processing/drawing, GFFT/SIFT descriptors and synthetic
PyrLK/Farneback flow. Qt/X11 window/key operations, rooted trackbar and mouse
callbacks, window recreation and BetterSample were exercised; the sample detected
46 corners on its bundled input. Capture checks passed for failed opens, explicit
CAP_IMAGES and automatic selection, three PNG frames, properties/seeking,
grab/retrieve/read, end of input and frame independence after release/GC.
Backend-dependent limitations are listed above.

The final package gate installs the generated ZIP into a separate Haxelib repository
and compiles/runs one headless consumer calling all five retained modules. The
three smaller samples are also compiled against the package.

## Publishing and licenses

Publishing remains a separate maintainer action: update release metadata, package,
validate the ZIP and intended Linux targets, then commit/publish only when ready.
A Git release must include the generated native bundle; a registry release uses
`haxelib submit` with the prepared ZIP.

Bindings use the MIT license in `LICENSE`. Redistribute
`native/Linux64/OpenCV-LICENSE.txt` and the applicable bundled dependency notices
under `native/Linux64/licenses/` with applications using those archives.
