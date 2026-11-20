# Haxe file inventory

All 30 Haxe files under `src/spilehx/cv` and `src/spilehx/internal`, including subdirectories, grouped by functional area with one-line summaries based on static source inspection.

## Build and native binding infrastructure

| File | Function |
| --- | --- |
| [Build.hx](src/spilehx/internal/Build.hx) | Configures compilation for Linux x86_64 C++ consumers and attaches the packaged native linker configuration. |
| [Macros.hx](src/spilehx/internal/Macros.hx) | Generates static binding methods from `@:CvProc` metadata, including native conversions, defaults, and debug checks. |
| [NativeBinding.hx](src/spilehx/internal/NativeBinding.hx) | Stores opaque native handles and supplies null-aware conversions for individual wrappers and wrapper arrays. |
| [NativeLibrary.hx](src/spilehx/internal/NativeLibrary.hx) | Initializes native OpenCV bindings once before loading C++ CFFI primitives. |

## Core operations, images, matrices, and drawing

| File | Function |
| --- | --- |
| [Core.hx](src/spilehx/cv/Core.hx) | Exposes core OpenCV constants, type constructors, array and matrix operations, drawing, and text rendering. |
| [core/Image.hx](src/spilehx/cv/core/Image.hx) | Wraps a native image and exposes its raw buffer, dimensions, channel count, depth, and memory-layout properties. |
| [core/Mat.hx](src/spilehx/cv/core/Mat.hx) | Wraps a native matrix with typed element access, raw-buffer access, and matrix metadata. |
| [core/CVBuffer.hx](src/spilehx/cv/core/CVBuffer.hx) | Defines an abstract type for opaque raw image or matrix data buffers. |
| [core/Font.hx](src/spilehx/cv/core/Font.hx) | Defines an abstract native font handle used by the core text-rendering API. |
| [core/Scalar.hx](src/spilehx/cv/core/Scalar.hx) | Wraps a native four-component scalar with indexed access and defines the `RGB` alias. |

## Geometry and dimensions

| File | Function |
| --- | --- |
| [core/Point.hx](src/spilehx/cv/core/Point.hx) | Wraps a native two-dimensional point with mutable integer coordinates. |
| [core/Point2D32f.hx](src/spilehx/cv/core/Point2D32f.hx) | Wraps a native two-dimensional point with mutable single-precision coordinates. |
| [core/Point2D64f.hx](src/spilehx/cv/core/Point2D64f.hx) | Wraps a native two-dimensional point with mutable double-precision coordinates. |
| [core/Point3D32f.hx](src/spilehx/cv/core/Point3D32f.hx) | Wraps a native three-dimensional point with mutable single-precision coordinates. |
| [core/Point3D64f.hx](src/spilehx/cv/core/Point3D64f.hx) | Wraps a native three-dimensional point with mutable double-precision coordinates. |
| [core/Rect.hx](src/spilehx/cv/core/Rect.hx) | Wraps a native rectangle with mutable integer position and dimensions. |
| [core/Size.hx](src/spilehx/cv/core/Size.hx) | Wraps native dimensions with mutable integer width and height. |
| [core/Size2D32f.hx](src/spilehx/cv/core/Size2D32f.hx) | Wraps native dimensions with mutable single-precision width and height. |

## Image processing and algorithm criteria

| File | Function |
| --- | --- |
| [ImgProc.hx](src/spilehx/cv/ImgProc.hx) | Exposes image-processing constants and operations for filtering, morphology, thresholding, colour conversion, and corner detection. |
| [core/TermCriteria.hx](src/spilehx/cv/core/TermCriteria.hx) | Wraps native algorithm termination criteria with mutable type, iteration limit, and epsilon. |

## Feature detection and descriptors

| File | Function |
| --- | --- |
| [Features2D.hx](src/spilehx/cv/Features2D.hx) | Provides the native primitive loader and factory methods for BRISK and GFFT feature detectors. |
| [features2d/BRISK.hx](src/spilehx/cv/features2d/BRISK.hx) | Wraps BRISK feature detection and optional descriptor extraction, converting native keypoints into Haxe wrappers. |
| [features2d/GFFT.hx](src/spilehx/cv/features2d/GFFT.hx) | Wraps Good Features to Track detection and converts native keypoints into Haxe wrappers. |
| [features2d/KeyPoint.hx](src/spilehx/cv/features2d/KeyPoint.hx) | Wraps a native feature keypoint with a factory method and access to its position, scale, orientation, and detection metadata. |
| [NonFree.hx](src/spilehx/cv/NonFree.hx) | Provides the native primitive loader and factory methods for SIFT and SURF feature detectors. |
| [nonfree/SIFT.hx](src/spilehx/cv/nonfree/SIFT.hx) | Wraps SIFT feature detection and optional descriptor extraction, converting native keypoints into Haxe wrappers. |
| [nonfree/SURF.hx](src/spilehx/cv/nonfree/SURF.hx) | Wraps SURF feature detection and optional descriptor extraction, with an extended-descriptor setting and keypoint conversion. |

## Windows, image IO, and capture

| File | Function |
| --- | --- |
| [HighGUI.hx](src/spilehx/cv/HighGUI.hx) | Exposes window controls, input callbacks, image loading and saving, and video-file capture operations. |
| [highgui/Capture.hx](src/spilehx/cv/highgui/Capture.hx) | Defines an abstract native capture handle used by the HighGUI frame-retrieval API. |

## Motion and optical flow

| File | Function |
| --- | --- |
| [Video.hx](src/spilehx/cv/Video.hx) | Exposes optical-flow constants and algorithms, including marshalling feature arrays for pyramidal Lucas–Kanade tracking. |
