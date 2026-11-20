# Architecture map

Implementation takes precedence if this map becomes outdated. See [working practices](WAYS_OF_WORKING.md), [code style](CODE_STYLE.md), and the [README](../README.md) for development constraints, installation, packaging, and release instructions.

## Scope and entry points

`spilehx-opencv` is a Haxe library binding OpenCV 2.4.13.7 through hxcpp CFFI. The supported consumer target is Linux x86_64 C++, with OpenCV and the wrapper statically linked into the consumer executable. Compatible system libraries are still needed.

- Consumer applications supply their own `main` and use `-lib spilehx-opencv`. `haxelib.json` declares the package, `src` class path, and hxcpp dependency; `extraParams.hxml` invokes `spilehx.internal.Build.configure()`.
- `src/spilehx/internal/Build.hx` rejects unsupported targets, defines `HXCPP_M64`, and adds the `native/Linux64/Build.xml` include to `spilehx.internal.NativeLibrary` through build metadata. Display/no-output compilation skips this setup.
- `make` delegates to `package-haxelib.sh`, the native build/package entry point.
- The Neko branches remaining in source are not the supported package path.

## Code locations

`src/spilehx/internal/` contains implementation support required by consumers during compilation and native binding use. Its types use `@:noCompletion` and `@:noDoc` to suppress completion suggestions and generated documentation; the package name does not enforce privacy.

| Haxe API | Native implementation | Responsibility |
| --- | --- | --- |
| `src/spilehx/cv/Core.hx`, `src/spilehx/cv/core/` | `cpp/core.cpp`, `cpp/core.h` | Images, matrices, geometry, scalars, array operations, drawing, fonts |
| `src/spilehx/cv/ImgProc.hx` | `cpp/imgproc.cpp`, `cpp/imgproc.h` | Image processing, filters, transforms, morphology |
| `src/spilehx/cv/HighGUI.hx`, `src/spilehx/cv/highgui/Capture.hx` | `cpp/highgui.cpp`, `cpp/highgui.h` | Image IO, windows, callbacks, file capture |
| `src/spilehx/cv/Video.hx` | `cpp/video.cpp`, `cpp/video.h` | Optical flow, including array output marshalling |
| `src/spilehx/cv/Features2D.hx`, `src/spilehx/cv/features2d/` | `cpp/features2d.cpp`, `cpp/features2d.h` | BRISK, GFFT, keypoints |
| `src/spilehx/cv/NonFree.hx`, `src/spilehx/cv/nonfree/` | `cpp/nonfree.cpp`, `cpp/nonfree.h` | SIFT and SURF |

`src/spilehx/internal/NativeBinding.hx` stores opaque native handles and supplies null-aware handle/array conversions. `src/spilehx/internal/Macros.hx` generates facade methods. `cpp/utils.h` centralizes CFFI value conversions, property/constant macros, and finalizer helpers. `cpp/main.cpp` initializes all modules' native kinds.

## Calls, data, and lifetime

1. A facade method calls its module's `load()` with a primitive name and arity. The loader prefixes names as `hx_cv_<module>_<operation>` in library `opencv`.
2. On the first load, `src/spilehx/internal/NativeLibrary.hx` calls `hx_opencv_entry()` before `cpp.Lib.load()`. That entry allocates the kinds used to identify and validate native objects.
3. Classes implementing `spilehx.internal.Macros.CvProcs` use `@:CvProc` to generate public static inline methods. Bodyless declarations get argument unwrapping, a native call, and return wrapping through the result type's `cvt()`. Explicit bodies handle special conversions. Generated null checks and `@:CvCheck` checks are debug-only.
4. C++ primitives extract CFFI values, call OpenCV, and return values or update supplied destinations. `spilehx.cv.Core.Arr` aliases `NativeBinding`; image/matrix compatibility is handled by the native operation rather than a distinct Haxe array hierarchy.

`Mat` wraps `CvMat`, and `Image` wraps `IplImage`; feature implementations bridge these to `cv::Mat` with `cv::cvarrToMat`. Algorithms often receive caller-created destination objects. Feature detection and pyramidal optical flow explicitly marshal output arrays and wrap newly added native elements; follow these manual bodies for array outputs because the macro does not generate array-return conversion.

Owned handles use CFFI GC finalizers (`cvReleaseMat`, `cvReleaseImage`, `cvReleaseCapture`, or typed `delete`). `CONVERT_NOGC` creates a wrapper without a finalizer: examples include capture frames and `KeyPoint.pt`. These are borrowed views; preserve the owner's lifetime and do not treat them as independent allocations. `Image.raw`/`Mat.raw` expose native pixel pointers through `CVBuffer`, without copying. HighGUI roots callbacks with `AutoGCRoot` and releases window-associated roots when windows are destroyed.

## Native build and distribution

- `.env` supplies vendor source, install, wrapper, and temporary paths plus the OpenCV download URL.
- `build_vendor.sh` obtains OpenCV source, builds static archives with Qt/GTK and nonfree support, then invokes root `Build.xml` to compile the CFFI wrapper as `opencv.a`.
- Root `Build.xml` lists wrapper translation units and include/compiler settings. `vendor/toolchain/opencv-toolchain.xml` redirects intermediate objects into the configured temporary directory.
- `package-haxelib.sh` copies archives and the OpenCV license, derives system linker flags from `opencv.pc` via `pkg-config`, generates linker XML, refreshes `native/Linux64/`, and writes the release ZIP under `dist/`.
- `native/Linux64/` is the distributable archive/linker bundle. Its `Build.xml` keeps wrapper registration objects with `--whole-archive` and groups OpenCV archives for symbol resolution. It is separate from the root wrapper-build XML. `vendor/`, `obj/`, `ndll/`, `build/`, and `dist/` hold development outputs rather than the consumer API.

## Extending the bindings

- Add an operation to the relevant Haxe facade and matching `cpp/<module>.cpp`. Keep primitive names and arities aligned with `DEFINE_PRIM`; multi-argument primitives use `DEFINE_PRIM_MULT` and loader arity `-1` (most facade loaders translate counts greater than five automatically).
- For a wrapped type, follow neighboring `NativeBinding` subclasses or abstracts, including null-aware `cvt()`, native kind declarations/allocation, conversion helpers, and appropriate owned/borrowed lifetime handling.
- A new native module also needs registration in `cpp/main.cpp` and a translation-unit entry in root `Build.xml`. Native changes require regenerating the packaged bundle; Haxe sources and archives must come from the same release.

This map is based on static source/configuration inspection. Archive contents, runtime behavior, and platform/system-library compatibility were not verified; no build, application, or tests were run.
