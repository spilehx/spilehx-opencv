package spilehx.cv;

import spilehx.cv.core.Mat;
import spilehx.internal.NativeBinding;
import spilehx.internal.NativeLibrary as Lib;

/**
 * Camera or file capture without window or GUI event handling.
 * Release explicitly with `release()`, or let GC close the input.
 * Returned frames own independent storage and do not retain this capture.
 */
class VideoCapture extends NativeBinding {
    static inline function load(name:String, argumentCount:Int):Dynamic
        return Lib.load("opencv", "hx_cv_videoio_" + name, argumentCount);

    function new(nativeObject:Dynamic) {
        super(nativeObject);
    }

    static inline function cvt(handle:Dynamic):Null<VideoCapture> {
        return if (handle == null) null else new VideoCapture(handle);
    }

    public static inline var CAP_ANY = 0;
    public static inline var CAP_IMAGES = 2000;
    public static inline var CAP_PROP_POS_MSEC = 0;
    public static inline var CAP_PROP_POS_FRAMES = 1;
    public static inline var CAP_PROP_FRAME_WIDTH = 3;
    public static inline var CAP_PROP_FRAME_HEIGHT = 4;
    public static inline var CAP_PROP_FPS = 5;
    public static inline var CAP_PROP_FOURCC = 6;
    public static inline var CAP_PROP_FRAME_COUNT = 7;
    public static inline var CAP_PROP_FORMAT = 8;
    public static inline var CAP_PROP_BACKEND = 42;

    /** Opens a camera by device index, or returns null when it cannot be opened. */
    public static inline function fromCamera(index:Int=0, backend:Int=CAP_ANY):Null<VideoCapture> {
        return cvt(load("fromCamera", 2)(index, backend));
    }

    /** Returns null when the selected installed backend cannot open the file or sequence. */
    public static function fromFile(filename:String, backend:Int=CAP_ANY):Null<VideoCapture> {
        #if debug
        if (filename == null) throw "fromFile :: filename cannot be null";
        #end
        return cvt(load("fromFile", 2)(filename, backend));
    }

    /** Property support and units follow the selected OpenCV backend. */
    public inline function getProperty(property:Int):Float {
        return load("getProperty", 2)(nativeObject, property);
    }

    /** Returns whether the backend accepted the requested property value. */
    public inline function setProperty(property:Int, value:Float):Bool {
        return load("setProperty", 3)(nativeObject, property, value);
    }

    /** Grabs the next frame for a subsequent `retrieveFrame()` call. */
    public inline function grabFrame():Bool {
        return load("grabFrame", 1)(nativeObject);
    }

    /** Returns an independent frame from the last successful grab, or null on failure. */
    public inline function retrieveFrame():Null<Mat> {
        return Mat.cvt(load("retrieveFrame", 1)(nativeObject));
    }

    /** Grabs and retrieves an independent frame, or returns null on failure/end of input. */
    public inline function readFrame():Null<Mat> {
        return Mat.cvt(load("readFrame", 1)(nativeObject));
    }

    /** Closes the input immediately; the handle remains safe to collect later. */
    public inline function release():Void {
        load("release", 1)(nativeObject);
    }
}
