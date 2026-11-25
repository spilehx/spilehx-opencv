# Architecture map

Implementation takes precedence if this map becomes outdated. See [working practices](WAYS_OF_WORKING.md), [code style](CODE_STYLE.md), and the [README](../README.md) for build instructions, API changes and tested limitations.

## Scope and entry points

`spilehx-opencv` binds OpenCV 5.1.0 through hxcpp CFFI for Linux x86_64 C++.
The wrapper, OpenCV and installed bundled dependencies are static archives;
compatible system libraries, including Qt5, GStreamer and their runtime dependencies, remain required.

- Consumers provide a main class and use `-lib spilehx-opencv`. `haxelib.json`
  declares the `src` class path and hxcpp dependency; `extraParams.hxml` invokes
  `spilehx.internal.Build.configure()`.
- That macro rejects unsupported targets, defines `HXCPP_M64` and adds the generated
  native linker XML to `NativeLibrary`. Display/no-output compilation skips setup.
- Run `bash package-haxelib.sh` from the repository root to build and package the library.

## Code locations

| Haxe API | Native implementation | Responsibility |
| --- | --- | --- |
| `Core.hx`, `core/` | `cpp/core.*` | Mat, geometry, scalars, criteria, arithmetic, indexing, views, transforms and drawing |
| `ImgProc.hx` | `cpp/imgproc.*` | Filters, morphology, CLAHE, color conversion, integral/distance operations, accumulators and corners |
| `Features2D.hx`, `features2d/` | `cpp/features2d.*` | GFTTDetector, SIFT, keypoints and descriptor Mats |
| `ObjDetect.hx`, `objdetect/` | `cpp/objdetect.*` | YuNet face detection from an external ONNX model |
| `Video.hx` | `cpp/video.*` | Sparse PyrLK and dense Farneback flow |
| `HighGUI.hx` | `cpp/highgui.*` | Ordinary windows, GUI events and rooted callbacks |
| `ImgCodecs.hx` | `cpp/imgcodecs.*` | Image file IO and in-memory JPEG encoding |
| `VideoCapture.hx` | `cpp/videoio.*` | Camera/file capture, frame reads and capture properties without GUI calls |
| `VideoEncoder.hx` | `cpp/videoencoder.*` | In-memory H.264 encoding with polled packets through GStreamer |

Haxe paths in the table are relative to `src/spilehx/cv/`.
`src/spilehx/internal/` provides the native handles, loader, API macros and build
configuration. Its types use `@:noCompletion`/`@:noDoc`.

## Calls and ownership

1. Facades use `NativeLibrary.load` with `hx_cv_<module>_<operation>` names and the
   primitive arity. Counts over five use the CFFI multi-argument path.
2. The first load calls `hx_opencv_entry()` to initialize core, feature and capture
   kinds. Static primitive registration is retained through whole-archive linking.
3. `@:CvProc` generates argument unwrapping and return wrapping for simple methods.
   Sparse point/keypoint arrays use explicit Haxe/native marshalling. Generated
   Haxe null checks are debug-only; retained native boundaries check kinds and
   relevant array/access bounds.
4. `CV_PRIM`/`CV_PRIM_MULT` in `cpp/utils.h` translate OpenCV exceptions to Haxe
   errors. `core.h` supplies small typed conversions; no legacy C array bridge is
   used.

`NativeBinding` stores an opaque native handle. `Mat` owns a heap `cv::Mat` header
with a typed delete finalizer. `Core.Arr` and `core.Image` are Mat typedefs. Views
have independent headers sharing reference-counted storage; clones copy pixels.
Destination arguments are passed by reference to the stored header so OpenCV
allocation/type changes reach the Haxe wrapper. Optional masks/kernels use empty
Mats. Typed component access accounts for row stride and validates depth/bounds.

Geometry, scalars and criteria own modern cv values. Keypoint handles own copied
`cv::KeyPoint` values; `KeyPoint.pt` returns a fresh owned `cv::Point2f`, with no
owner rooting or borrowed coordinate view. GFFT and SIFT handles own heap `cv::Ptr`
holders. SIFT descriptors are Mat outputs, and keypoint arrays resize exactly.

Capture handles own `cv::VideoCapture` directly. Grab/read/retrieve and property
methods delegate to the configured backend. Returned frames have independently
owned cloned storage, so they survive later reads, explicit release and capture GC.
`VideoCapture.release()` closes the input; the finalizer deletes the handle later.

Each VideoEncoder owns a GStreamer appsrc/x264enc/h264parse/appsink pipeline.
Native worker threads do not call Haxe. `pollPackets()` copies complete Annex B
access units into independently owned byte arrays, wrapped as Haxe Bytes. Packet
timestamps are converted through the sample segment to pipeline running time.
Only raw input frames may be dropped; the bounded encoded output queue preserves
frame order and applies backpressure to encoding. Explicit release stops the
pipeline and discards pending output; finalization is a fallback. CamStream fans
processed Mats out to attached encoders outside its locks and releases them on
capture exit. One app consumer polls an encoder and owns distribution to viewers;
there is no HTTP server, signaling or WebRTC transport in the haxelib.

HighGUI stores per-window callback roots. OpenCV userdata points to an
`AutoGCRoot`; callbacks resolve the current Haxe value with `get()`. Roots are
released after window destruction. Trackbars use OpenCV-managed positions with a
null integer pointer, and initialize through `setTrackbarPos`; there is no shared
trackbar-value variable. Only ordinary windows, trackbars and mouse callbacks are
retained.

## Native build and packaging

- `.env` pins source/install/temp paths and the OpenCV 5.1.0 URL. Existing source,
  build cache and installation can be reused through the build script's prompts.
- JPEG, WebP, PNG, TIFF and zlib are built from OpenCV's bundled sources with their
  `BUILD_*` options enabled. SPNG and zlib-ng are disabled to keep PNG/zlib archive
  selection consistent. Reused installations must include `liblibjpeg-turbo.a`,
  `liblibwebp.a`, `liblibpng.a`, `liblibtiff.a` and `libzlib.a`. Packaging links these
  archives instead of system codec flags. Qt remains a shared system dependency.
- Root `Build.xml` compiles all retained translation units with C++17 and the
  `include/opencv5` root. `vendor/toolchain/opencv-toolchain.xml` redirects wrapper
  intermediates into the temporary directory.
- `package-haxelib.sh` builds the wrapper, recursively collects installed `.a`
  archives with duplicate-name rejection, and copies OpenCV/bundled licenses.
  WebP's license is copied from its bundled source because its build does not
  install it.
- Generated linker XML keeps wrapper registration objects with whole-archive and
  groups the installed archives. The pinned Linux system dependencies are listed
  in the packaging script; pkg-config resolves Qt5 Widgets/Test/Concurrent and
  GStreamer app/video dependencies. GStreamer >= 1.20 development
  packages supply wrapper compiler flags through a temporary XML include.
  OpenCV `.pc` files and development-tree archive paths are not required.
- Packaging generates `native/Linux64/` and a ZIP in `dist/`. Never review or
  manually edit generated `native/` files. Consumer sources and archives must come
  from the same package. Build outputs live under vendor/build/obj/ndll/dist paths.

The OpenCV build includes Qt, V4L2/OBSENSOR and built-in image-sequence/MJPEG
backends; its FFmpeg, GStreamer and OpenGL backends are disabled. VideoEncoder uses
GStreamer directly, independently of OpenCV's videoio backend. Hardware capture and general
video-format support remain backend-dependent and unverified.

## Validation and extension

Stages exercised headless core/processing and view lifetimes, synthetic GFFT/SIFT
and PyrLK/Farneback, plus Qt/X11 windows, keys, rooted callbacks and BetterSample.
See the README for the final capture/package validation record.

Add operations to the existing facade/native module with matching primitive names
and arities. Reuse the typed conversions, finalizers and exception macros. New
handle kinds require initialization in `cpp/main.cpp`; new translation units also
need a root `Build.xml` entry. Repackage native changes before consumer validation.
