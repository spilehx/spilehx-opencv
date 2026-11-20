package spilehx.cv;

import spilehx.cv.core.Mat;
import spilehx.cv.highgui.Capture;
import spilehx.internal.NativeLibrary as Lib;
import spilehx.internal.Macros;

/** Mat image IO, file capture and ordinary windows. Use waitKey for GUI events. */
class HighGUI implements CvProcs {
    static inline function load(n:String, p:Int=0):Dynamic
        return Lib.load("opencv", "hx_cv_highgui_"+n, p > 5 ? -1 : p);

    public static inline var WINDOW_NORMAL = 0;
    public static inline var WINDOW_AUTOSIZE = 1;
    public static inline var WINDOW_FREERATIO = 0x100;
    public static inline var WINDOW_KEEPRATIO = 0;

    public static inline var EVENT_MOUSEMOVE     = 0;
    public static inline var EVENT_LBUTTONDOWN   = 1;
    public static inline var EVENT_RBUTTONDOWN   = 2;
    public static inline var EVENT_MBUTTONDOWN   = 3;
    public static inline var EVENT_LBUTTONUP     = 4;
    public static inline var EVENT_RBUTTONUP     = 5;
    public static inline var EVENT_MBUTTONUP     = 6;
    public static inline var EVENT_LBUTTONDBLCLK = 7;
    public static inline var EVENT_RBUTTONDBLCLK = 8;
    public static inline var EVENT_MBUTTONDBLCLK = 9;

    // -------------------------
    // Modifier flags for mouse callbacks.
    // -------------------------
    public static inline var EVENT_FLAG_LBUTTON  = 1;
    public static inline var EVENT_FLAG_RBUTTON  = 2;
    public static inline var EVENT_FLAG_MBUTTON  = 4;
    public static inline var EVENT_FLAG_CTRLKEY  = 8;
    public static inline var EVENT_FLAG_SHIFTKEY = 16;
    public static inline var EVENT_FLAG_ALTKEY   = 32;

    public static inline var IMREAD_UNCHANGED = -1;
    public static inline var IMREAD_GRAYSCALE = 0;
    public static inline var IMREAD_COLOR_BGR = 1;
    public static inline var IMREAD_ANYDEPTH = 2;
    public static inline var IMREAD_ANYCOLOR = 4;

    /** Returns an owned matrix, or null when the file cannot be decoded. */
    @:CvProc function loadImage(filename:String, flags:Int=IMREAD_COLOR_BGR):Null<Mat>;
    /** Encodes by filename extension. Unsupported encodings raise an OpenCV error. */
    @:CvProc function saveImage(filename:String, image:Mat):Bool;
    /** Returns the key code, or -1 on timeout. A delay of 0 waits indefinitely. */
    @:CvProc function waitKey(delay:Int=0):Int;
    @:CvProc function namedWindow(name:String, flags:Int=WINDOW_AUTOSIZE):Void;
    @:CvProc function showImage(name:String, image:Mat):Void;
    @:CvProc function moveWindow(name:String, x:Int, y:Int):Void;
    @:CvProc function resizeWindow(name:String, width:Int, height:Int):Void;
    @:CvProc function destroyWindow(name:String):Void;
    @:CvProc function destroyAllWindows():Void;

    /** Named-window trackbar. Its callback remains rooted until window destruction. */
    @:CvProc function createTrackbar(name:String, windowName:String, value:Int, count:Int, ?onChange:Null<Int->Void>):Bool;
    @:CvProc function getTrackbarPos(name:String, windowName:String):Int;
    @:CvProc function setTrackbarPos(name:String, windowName:String, position:Int):Void;
    /** Receives event, x, y and flags. Pass null to remove the handler. */
    @:CvProc function setMouseCallback(windowName:String, ?onMouse:Null<Int->Int->Int->Int->Void>):Void;

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

    /** Returns null when the selected installed backend cannot open the file or sequence. */
    @:CvProc function captureFromFile(filename:String, backend:Int=CAP_ANY):Null<Capture>;
    /** Property support and units follow the selected OpenCV backend. */
    @:CvProc function getCaptureProperty(capture:Capture, property:Int):Float;
    @:CvProc function setCaptureProperty(capture:Capture, property:Int, value:Float):Bool;
    @:CvProc function grabFrame(capture:Capture):Bool;
    /** Returns an independent frame from the last successful grab, or null on failure. */
    @:CvProc function retrieveFrame(capture:Capture):Null<Mat>;
    /** Grabs and retrieves an independent frame, or returns null on failure/end of input. */
    @:CvProc function readFrame(capture:Capture):Null<Mat>;
    /** Closes the input immediately; the handle remains safe to collect later. */
    @:CvProc function releaseCapture(capture:Capture):Void;
}
