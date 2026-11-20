# Minimal OpenCV 5.1.0 Haxelib plan

## Scope and confirmed starting point

Build a useful modern Linux Haxelib, not a compatible recreation of OpenCV 2.4.
Preserve `src/spilehx/cv`, `cpp/`, existing module organization, hxcpp CFFI and
static Haxelib packaging. Keep the current Linux x86_64 target; no portability work.
No legacy algorithm ports, contrib dependency, compatibility layer or unrelated features.

Planning changes only this file. No builds/tests during planning. Later execution
requires explicit authorization under `.ai/WAYS_OF_WORKING.md`. Never review or
manually edit `native/`; generate its contents through packaging when authorized.

Use these confirmed references without repeating the inventory:

- Source: `vendor/source/opencv`; installed headers:
  `vendor/lib/opencv/include/opencv5`; static archives: `vendor/lib/opencv/lib`.
  Local `core/version.hpp` confirms 5.1.0; `.env` already selects that version.
- Direct modules: **core, imgproc, imgcodecs, features, video, highgui, videoio**.
  Preserve their necessary transitive dependencies. Local archives include
  `libopencv_features.a`; `features2d.hpp` forwards to `features.hpp`.
- Legacy C headers/types are gone. Modern SIFT/GFTT and PyrLK/Farneback exist;
  BRISK/SURF and old BM/HS/dense-LK interfaces are absent from inspected headers.
- BRISK verification: a targeted search of all installed `opencv2` .h/.hpp files
  finds only a descriptive comment in `features.hpp`, no class or factory.
  Drop it for this local installation; do not add contrib or a legacy port.
- Use C++17: installed `lib/cmake/opencv5/OpenCVConfig.cmake:273–287` explicitly
  attaches `cxx_std_17` to opencv_core. Although cvdef.h's basic guard mentions
  C++11, it does not establish compatibility of all headers. Honor the installed
  package's exported minimum; no higher standard or standard-downgrade probes.
- Qt is compiled in; OpenGL, FFmpeg and GStreamer are disabled. Capture support
  depends on the remaining installed backends, not merely on videoio being built.
- `buildOpenCVWrapper` is commented out. Packaging expects `opencv.pc`, but
  `OPENCV_GENERATE_PKGCONFIG=OFF`. Installed CMake exports under
  `lib/cmake/opencv5` identify the dependencies; use the bounded Linux link list
  below rather than generating metadata or translating CMake targets.
- Videoio compile flags confirm V4L2/OBSENSOR; its registry includes built-in
  image-sequence and MJPEG file backends. General compressed-video playback is
  not guaranteed without FFmpeg/GStreamer, and hardware capture needs a device.

## Feature decisions

| Category | Decision |
| --- | --- |
| Matrices/images | Retain allocation, clone, dimensions/type/stride, typed access and useful views using `cv::Mat` alone. |
| Core operations | Retain straightforward arithmetic, bitwise operations, statistics, conversions, split/merge, DCT/DFT and indexing. Use modern parameters/defaults. |
| Processing | Retain existing filters, colour conversion, morphology, threshold, distance/integral/accumulation operations, corners and existing transforms with direct equivalents. |
| IO/drawing | Retain image read/write, circles, lines, rectangles and text. |
| Features | Retain GFFT through `cv::GFTTDetector` and SIFT through `cv::SIFT`. Drop BRISK/SURF rather than adding dependencies. |
| Flow | Retain modern sparse PyrLK and dense Farneback. Drop BM, HS and old dense LK. |
| GUI | Retain ordinary windows, display, key handling, trackbars and mouse callbacks. Drop OpenGL and Qt-specific button/overlay/status-bar bindings; these are unnecessary for the minimal GUI. |
| Capture | Retain file capture, grab/retrieve/read and properties using `cv::VideoCapture`, limited to configured backends. |

Replace legacy interfaces directly:

- `Image` and IPL depths -> `Mat` and modern OpenCV depth/type constants. Allow
  `typedef Image = Mat` if it saves import/type edits; no legacy image properties
  or separate native storage are required.
- Header/createData allocation -> ordinary allocated or empty `Mat`.
- `CvFont`/createFont -> direct putText font face, one scale, thickness and line type.
- IplConvKernel -> matrix kernel, shape/size and explicit anchor arguments.
- Custom adaptive equalization -> `createCLAHE()->apply`, with modern clip-limit
  and tile-grid parameters. This replaces the capability, not its exact output.
- Old smooth dispatcher -> the already-exposed specific filter methods.
- Old convertImage -> explicit existing colour conversion; add a flip binding only
  if required to replace an existing conversion use. No combined legacy flags.
- Flat descriptor arrays -> descriptor `Mat`; keypoint arrays stay explicit.
- PyrLK -> no caller pyramid buffers, modern flags and ordinary point/status/error outputs.

Remove `initSystem`, obsolete flags/constants, unused conversion/finalizer helpers,
header-only allocation and unsafe raw-pointer/CVBuffer exposure. No borrowed frame
or KeyPoint.pt views: return owned matrices and copied point values. No anisotropic
font scaling/shear emulation. Apart from the optional Image typedef, do not
implement aliases for removed Haxe APIs.

## Minimal wrapper architecture

Retain Core, ImgProc, Features2D, Video and HighGUI modules and their native files.
Move SIFT into Features2D and remove NonFree. Keep NativeBinding, NativeLibrary,
Macros and static primitive registration where useful; adapt signatures directly.

A Mat handle owns a heap `cv::Mat` header with a delete finalizer. Views own their
own reference-counted headers. Pass stored destination matrices by reference so
allocation changes reach Haxe. Optional masks use empty matrices. Use `cv::Ptr`
holders for factory-created algorithms and a direct VideoCapture holder for capture.
Geometry uses modern cv types behind the existing simple Haxe wrappers.

Keep explicit native marshalling only where needed: matrices for image/descriptor
outputs, existing keypoint/point arrays for sparse outputs, copied small values
instead of borrowed handles. Reuse current conversions/finalizers where they fit;
remove redundant conversions and wrappers rather than adding generalized helpers.
Return frames in freshly owned matrix headers so no frame-owner rooting is needed.

Keep native conversions small in `cpp/core.h`/`cpp/utils.h`; no generic object model
or new wrapper layer. Catch OpenCV exceptions at native entry points and raise a
consistent Haxe error using the existing CFFI mechanism; do not let C++ exceptions
escape across CFFI. Apply this only to the retained bindings.

## Implementation sequence

### 1. Establish the smallest compiling and linking package

Files: `build_vendor.sh`, `Build.xml`, `package-haxelib.sh`, `cpp/main.cpp`,
`cpp/core.h`, `cpp/core.cpp`, `cpp/utils.h`, `src/spilehx/cv/Core.hx`,
`src/spilehx/cv/core/Mat.hx`.

- Set wrapper include root to `include/opencv5`, use `opencv2/...` includes and
  compile with C++17. Restore the `buildOpenCVWrapper` call.
- Remove obsolete nonfree/contrib/legacy build options and the CMP0042 workaround.
  Leave the working OpenCV installation and build cache alone. Keep the existing
  install reuse path; do not reconfigure/rebuild OpenCV to generate metadata or
  prune modules. Restore wrapper compilation against the existing archives.
- Keep packaging's recursive installed `.a` collection, duplicate-name check,
  whole-archive CFFI registration and archive group. This includes transitive
  OpenCV and bundled dependencies without resolving their target graph.
- Replace only the OpenCV `.pc` lookup and obsolete Qt workaround with the system
  link flags for this installed Linux build. The inspected OpenCVModules.cmake
  exports identify JPEG, WebP, PNG, TIFF, zlib and Qt dependencies. Append
  `-ljpeg -lwebp -lwebpmux -lwebpdemux -lpng -ltiff -lz -ldl -lm -lpthread -lrt`
  after the archive group, plus the output of
  `pkg-config --libs Qt5Widgets Qt5Test Qt5Concurrent` (which includes Qt Core/Gui).
  Keep pkg-config for Qt only; retain required system development packages.
- Keep this short dependency list local to `package-haxelib.sh` with a comment
  identifying the pinned Linux OpenCV build. Let the initial consumer link expose
  any missing installed archive or system dependency; correct only that concrete
  omission. Do not replace missing bundled archives with development-tree paths.
  This is configuration-specific, not automatic support for arbitrary OpenCV builds.
  If the OpenCV build options change later, update the list from its exports.
- No temporary CMake project, link.txt parsing, CMake dependency interpreter or
  OpenCV reconfiguration/rebuild. Keep applicable bundled licenses and existing
  rejection of unresolved vendor paths in generated consumer metadata.
- Initially compile/register only the new core implementation. Implement Mat
  allocation, clone, rows/columns/type/stride and a scalar read/write operation.
  Temporarily exclude unported translation units and allocation calls in main;
  restore each as its feature stage is completed.
- When authorized, package and compile/run a tiny separate Haxe consumer that
  allocates and reads/writes a matrix. This is the first integration gate; resolve
  compiler, registration and static linker issues before implementing more features.

### 2. Implement useful core operations and image processing

Files: `cpp/core.*`, `cpp/imgproc.*`, corresponding `Core.hx`, `ImgProc.hx`,
`src/spilehx/cv/core/*`, plus `cpp/main.cpp`/`Build.xml` registrations.

- Finish modern geometry/scalars/criteria, typed matrix access, views and retained
  core operations. Preserve straightforward Haxe names where useful; change
  signatures to match modern semantics instead of emulating old contracts.
- Remove Font and CVBuffer files and obsolete declarations/imports. Remove Image
  or reduce it to `typedef Image = Mat`, whichever reduces migration effort.
  Replace drawing/font handling with direct modern functions.
- Port filters and processing directly, replacing kernels and adaptive equalization
  as specified above. Remove obsolete dispatcher modes and scratch-buffer arguments.
- Correct migrated operand wiring (old and/div pass src1 twice). Use row-aware
  typed access for views; update outputs through stored Mat references.

### 3. Implement features and modern flow

Files: `cpp/features2d.*`, `cpp/video.*`, `src/spilehx/cv/Features2D.hx`,
`src/spilehx/cv/features2d/*`, `src/spilehx/cv/Video.hx`, registrations/build list.

- Use GFTTDetector::create/detect and SIFT::create/detectAndCompute from features.hpp.
  Reuse keypoint marshalling, return copied pt values and Mat descriptors.
- Delete `cpp/nonfree.*`, `NonFree.hx`, `src/spilehx/cv/nonfree/*` and BRISK bindings;
  remove their includes, native kind allocation and build entries.
- Implement modern calcOpticalFlowPyrLK/Farneback; expose modern flags without
  translation and remove legacy pyramid buffers and BM/HS/dense-LK methods.
  Keep the existing explicit sparse output-array conversion; use Mat for dense
  flow. Validate on synthetic matrices before adding GUI or callback handling.

### 4. Implement IO and basic GUI

Files: `cpp/highgui.*`, `src/spilehx/cv/HighGUI.hx`, affected samples and registrations.

- Use imread/imwrite and Mat-only IO. Return null for failed reads, bool for writes,
  and the key code from waitKey. Use modern void/bool returns elsewhere as appropriate.
- Check image IO first, then ordinary windows/display/key handling. Add callbacks
  last, after these and the earlier core/features checks pass.
- Add retained windows/display/trackbar/mouse functions; reuse callback roots and
  window cleanup. Use AutoGCRoot-backed userdata and root lookup in callbacks,
  avoiding pointers to unrooted Haxe values and shared trackbar-value storage.
- Remove obsolete GUI/init/conversion bindings and constants listed above.
- Update `samples/src/BetterSample.hx` and its existing HXML as needed. Exercise IO,
  processing, drawing, GFFT and windows together.

### 5. Add supported capture and finish package/API cleanup

Files: `cpp/highgui.cpp`, `src/spilehx/cv/HighGUI.hx`,
`src/spilehx/cv/highgui/Capture.hx`, `Build.xml`, `cpp/main.cpp`, relevant samples,
`README.md`, `haxelib.json`, `.ai/ARCHITECTURE.md`.

- Wrap VideoCapture construction/properties/grab/retrieve/read. Return an owned
  Mat header for each frame; avoid exposing a borrowed reusable frame pointer.
- Keep the existing backend configuration. If no local file input is supported,
  document that limitation; do not add FFmpeg/GStreamer in this minimal update.
  Use a tiny image sequence through CAP_IMAGES for deterministic file-capture
  validation; expose an optional backend argument if necessary. This checks capture
  without a camera or codec dependency. V4L2/OBSENSOR hardware is optional and
  unverified unless a device is available; arbitrary video formats remain limited.
- Remove stale symbols/imports and update remaining samples to the new API or
  remove obsolete examples. Retain the existing Linux build/platform guards.
- Record the breaking API changes, dependency/version facts and actual tested
  capability. No publication or commit unless separately requested.

## Minimal incremental validation

Execution only when authorized. No comprehensive suite, benchmarks or platform matrix.

1. Step 1: build/package and run the tiny ZIP-installed consumer to prove the bridge.
2. Step 2: rebuild changed wrapper files and run a tiny headless check for core
   processing, stride/view lifetime and destination mutation.
3. Step 3: one synthetic-image check for GFFT/SIFT output and descriptor Mat type,
   PyrLK status/output lengths and finite Farneback flow with expected dimensions.
4. Step 4: run the adapted BetterSample for IO/processing/GFFT/drawing/display;
   exercise one callback. Step 5: check capture failure and image-sequence frame
   reads. Report unexercised hardware/codec-dependent behaviour.
5. Repackage the finished wrapper and rerun one separate ZIP-installed consumer.
   Include calls into each retained module so missing registration/link dependencies
   are exposed. Repeat only checks affected by subsequent corrections.

Finish with a smaller working API and explicit limitations. Do not reopen the legacy
inventory or recover dropped functionality. Local source/headers remain authoritative;
consult https://docs.opencv.org/5.1.0/ only for a specific implementation uncertainty.
