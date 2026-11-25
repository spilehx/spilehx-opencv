package spilehx.cv;

import haxe.io.Bytes;
import spilehx.cv.core.Mat;
import spilehx.internal.NativeBinding;
import spilehx.internal.NativeLibrary as Lib;
import spilehx.internal.Macros;

/** Image file IO and in-memory encoding without GUI calls. */
class ImgCodecs implements CvProcs {
    static inline function load(n:String, p:Int=0):Dynamic
        return Lib.load("opencv", "hx_cv_imgcodecs_"+n, p > 5 ? -1 : p);

    public static inline var IMREAD_UNCHANGED = -1;
    public static inline var IMREAD_GRAYSCALE = 0;
    public static inline var IMREAD_COLOR_BGR = 1;
    public static inline var IMREAD_ANYDEPTH = 2;
    public static inline var IMREAD_ANYCOLOR = 4;

    /** Returns an owned matrix, or null when the file cannot be decoded. */
    @:CvProc function loadImage(filename:String, flags:Int=IMREAD_COLOR_BGR):Null<Mat>;
    /** Encodes by filename extension. Unsupported encodings raise an OpenCV error. */
    @:CvProc function saveImage(filename:String, image:Mat):Bool;
    /** Encodes owned JPEG bytes in memory. Quality is 0–100; failures throw an OpenCV error. */
    @:CvProc function encodeJpeg(image:Mat, quality:Int=95):Bytes {
        return Bytes.ofData(load("encodeJpeg", 2)(NativeBinding.native(image), quality));
    }
}
