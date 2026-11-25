# spilehx-opencv

OpenCV bindings for Haxe, providing computer vision and image processing for the **C++ (`cpp`) target only**. Tested only on Linux.

OpenCV and its bundled codec archives are internally packaged; Qt, GStreamer and other
system runtime libraries remain required.
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

`bash package-haxelib.sh` builds OpenCV with bundled static JPEG, WebP, PNG, TIFF,
and zlib libraries and includes their archives and licenses in the haxelib.
Existing OpenCV installs without these archives must be rebuilt: when packaging
prompts, choose to rebuild the existing installation. Qt remains a system shared
dependency, together with its own runtime dependencies. Those dependencies may
still require system codec libraries; the resulting executable is not fully static.

## Image codecs

Image loading, saving, JPEG encoding and `IMREAD_*` constants now belong to
`spilehx.cv.ImgCodecs` rather than `HighGUI`. These operations do not create
windows or process GUI events. `MatHelper.matToJpg(mat, quality)` delegates to
`ImgCodecs.encodeJpeg()` and returns independently owned `haxe.io.Bytes`.
Rebuild and repackage the native wrapper before using the new image codec API.
Qt remains a system dependency of the current package.

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

## Encoded video output

`VideoEncoder` provides H.264 frames in memory through GStreamer. It contains no
HTTP server, signaling, browser sessions or WebRTC transport. Your app consumes
encoded packets and decides how to deliver them. Browser playback through WebRTC
requires a WebRTC media transport implementation in the consuming app.

To encode `CamStream` output, run `startCapture()` on a capture thread and wait
for the first processed frame. On the app's consumer thread:

```haxe
var encoder = cameraStream.createVideoEncoder(30, 2000);

// Repeat from your app's event loop/timer while consuming the stream.
var packets = encoder.pollPackets();
for (packet in packets) {
    // packet.data is haxe.io.Bytes containing one complete encoded frame.
    // Forward it and its metadata through the app's chosen transport.
}
for (error in encoder.pollErrors()) {
    trace(error);
}

// When a new viewer joins, request a new independently decodable frame.
encoder.requestKeyFrame();

// When output is no longer needed:
cameraStream.removeVideoEncoder(encoder);
```

`createVideoEncoder(fps, bitrate)` uses the processed Mat's dimensions; bitrate is
in kbit/s. Frames go to the encoder after `onFrame`, outside the snapshot mutex.
The existing JPEG snapshot API continues to work. `stopCapture()` requests capture
shutdown after the current read/processing returns; capture exit releases attached
encoders. Explicit release discards queued output and does not flush a recording.

Alternatively, construct `new spilehx.cv.VideoEncoder(width, height, fps, bitrate)`
and call `write(mat)` yourself. Explicitly release standalone encoders when done.
Dimensions must be positive, even and fixed. FPS must be 1–240. Input Mats must be
8-bit BGR or grayscale; grayscale is converted to BGR. Pixel copies account for
Mat row stride. Do not modify Mats concurrently while they are being processed,
encoded or read as snapshots.

`pollPackets(maxPackets=8)` is nonblocking and returns at most 1–64 packets per
call, depending on the requested limit. Each packet has:

| Field | Meaning |
| --- | --- |
| `data` | Independently owned `haxe.io.Bytes`, H.264 Annex B, access-unit aligned |
| `timestamp` | Presentation timestamp in seconds relative to pipeline running time |
| `decodeTimestamp` | Decode timestamp in seconds, or null when unavailable |
| `duration` | Nominal duration in seconds, or null when unavailable |
| `keyFrame` | Whether the packet is an independently decodable keyframe |

The stream uses constrained baseline H.264 with no B-frames. SPS/PPS codec headers
are included with every IDR frame through
[h264parse](https://gstreamer.freedesktop.org/documentation/videoparsersbad/h264parse.html).
Codec identity, dimensions, format and timing must be conveyed to the receiver by
your app. Output is elementary H.264, not an MP4 file or a complete WebRTC stream.
`requestKeyFrame()` asks for an IDR with headers; the app must wait for a subsequent
`keyFrame` packet before starting a new viewer's sequence, then preserve packet
order. A true return value means the request was accepted, not that the frame is
already available. One encoder can supply multiple viewers without re-encoding.

Polling consumes packets: use one consumer per encoder, then distribute each
packet to viewers in the app. Poll frequently, including `pollErrors()`. Asynchronous
pipeline errors make `write()` return false; release and recreate a failed encoder.
Invalid dimensions/types and synchronous native failures throw an OpenCV error.

Raw input above the requested FPS is skipped, and the input queue drops old raw
frames when full. The bounded encoded queue preserves packet order and blocks
encoding when full; it does not drop compressed reference frames. A stalled
consumer can still accumulate latency within these queues. The app must handle
slow viewers without blocking its shared consumer; if it drops encoded frames for
a viewer, resume that viewer at a keyframe. Packet timestamps follow real pipeline
time rather than a frame counter; actual FPS depends on capture and processing.

Build and repackage using `bash package-haxelib.sh`. The wrapper requires
GStreamer >= 1.20 development packages. On Debian Trixie:

```sh
sudo apt install pkg-config libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
```

The script derives compiler flags from pkg-config into a temporary XML include.
Direct hxcpp wrapper builds must supply that include through
`-DGSTREAMER_BUILD_XML=...`; consumer builds use packaged linker metadata.
Deployment machines require GStreamer runtime libraries and encoding plugins:

```sh
sudo apt install gstreamer1.0-plugins-base gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly
```

These provide appsrc/appsink, videoconvert, h264parse and x264enc. Qt remains a
system dependency. OpenCV's GStreamer videoio backend remains disabled because
VideoEncoder uses GStreamer directly. Encoding, timing, shutdown and decoder
interoperability require runtime validation; this implementation has not been
built or exercised.
