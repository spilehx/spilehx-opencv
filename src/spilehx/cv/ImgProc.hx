package spilehx.cv;

import spilehx.internal.NativeBinding;
import spilehx.internal.NativeLibrary as Lib;
import spilehx.internal.Macros;
import spilehx.cv.Core.Arr;
import spilehx.cv.core.*;

/** Filtering, morphology and color conversion with resizable Mat destinations. */
class ImgProc implements CvProcs {
    @:allow(spilehx.cv.imgproc)
    static inline function load(n:String, p:Int=-1):Dynamic
        return Lib.load("opencv", "hx_cv_imgproc_"+n, p > 5 ? -1 : p);

    public static inline var SHAPE_RECT    = 0;
    public static inline var SHAPE_CROSS   = 1;
    public static inline var SHAPE_ELLIPSE = 2;

    // -------------------------
    // Morphological operator flags.
    // -------------------------
    public static inline var MOP_ERODE    = 0;
    public static inline var MOP_DILATE   = 1;
    public static inline var MOP_OPEN     = 2;
    public static inline var MOP_CLOSE    = 3;
    public static inline var MOP_GRADIENT = 4;
    public static inline var MOP_TOPHAT   = 5;
    public static inline var MOP_BLACKHAT = 6;

    // -------------------------
    // Color conversion flags.
    // -------------------------
    public static inline var BGR2BGRA        = 0;
    public static inline var RGB2RGBA        = BGR2BGRA;
    public static inline var BGRA2BGR        = 1;
    public static inline var RGBA2RGB        = BGRA2BGR;
    public static inline var BGR2RGBA        = 2;
    public static inline var RGB2BGRA        = BGR2RGBA;
    public static inline var RGBA2BGR        = 3;
    public static inline var BGRA2RGB        = RGBA2BGR;
    public static inline var BGR2RGB         = 4;
    public static inline var RGB2BGR         = BGR2RGB;
    public static inline var BGRA2RGBA       = 5;
    public static inline var RGBA2BGRA       = BGRA2RGBA;
    public static inline var BGR2GRAY        = 6;
    public static inline var RGB2GRAY        = 7;
    public static inline var GRAY2BGR        = 8;
    public static inline var GRAY2RGB        = GRAY2BGR;
    public static inline var GRAY2BGRA       = 9;
    public static inline var GRAY2RGBA       = GRAY2BGRA;
    public static inline var BGRA2GRAY       = 10;
    public static inline var RGBA2GRAY       = 11;
    public static inline var BGR2BGR565      = 12;
    public static inline var RGB2BGR565      = 13;
    public static inline var BGR5652BGR      = 14;
    public static inline var BGR5652RGB      = 15;
    public static inline var BGRA2BGR565     = 16;
    public static inline var RGBA2BGR565     = 17;
    public static inline var BGR5652BGRA     = 18;
    public static inline var BGR5652RGBA     = 19;
    public static inline var GRAY2BGR565     = 20;
    public static inline var BGR5652GRAY     = 21;
    public static inline var BGR2BGR555      = 22;
    public static inline var RGB2BGR555      = 23;
    public static inline var BGR5552BGR      = 24;
    public static inline var BGR5552RGB      = 25;
    public static inline var BGRA2BGR555     = 26;
    public static inline var RGBA2BGR555     = 27;
    public static inline var BGR5552BGRA     = 28;
    public static inline var BGR5552RGBA     = 29;
    public static inline var GRAY2BGR555     = 30;
    public static inline var BGR5552GRAY     = 31;
    public static inline var BGR2XYZ         = 32;
    public static inline var RGB2XYZ         = 33;
    public static inline var XYZ2BGR         = 34;
    public static inline var XYZ2RGB         = 35;
    public static inline var BGR2YCrCb       = 36;
    public static inline var RGB2YCrCb       = 37;
    public static inline var YCrCb2BGR       = 38;
    public static inline var YCrCb2RGB       = 39;
    public static inline var BGR2HSV         = 40;
    public static inline var RGB2HSV         = 41;
    public static inline var BGR2Lab         = 44;
    public static inline var RGB2Lab         = 45;
    public static inline var BayerBG2BGR     = 46;
    public static inline var BayerGB2BGR     = 47;
    public static inline var BayerRG2BGR     = 48;
    public static inline var BayerGR2BGR     = 49;
    public static inline var BayerBG2RGB     = BayerRG2BGR;
    public static inline var BayerGB2RGB     = BayerGR2BGR;
    public static inline var BayerRG2RGB     = BayerBG2BGR;
    public static inline var BayerGR2RGB     = BayerGB2BGR;
    public static inline var BGR2Luv         = 50;
    public static inline var RGB2Luv         = 51;
    public static inline var BGR2HLS         = 52;
    public static inline var RGB2HLS         = 53;
    public static inline var HSV2BGR         = 54;
    public static inline var HSV2RGB         = 55;
    public static inline var Lab2BGR         = 56;
    public static inline var Lab2RGB         = 57;
    public static inline var Luv2BGR         = 58;
    public static inline var Luv2RGB         = 59;
    public static inline var HLS2BGR         = 60;
    public static inline var HLS2RGB         = 61;
    public static inline var BayerBG2BGR_VNG = 62;
    public static inline var BayerGB2BGR_VNG = 63;
    public static inline var BayerRG2BGR_VNG = 64;
    public static inline var BayerGR2BGR_VNG = 65;
    public static inline var BayerBG2RGB_VNG = BayerRG2BGR_VNG;
    public static inline var BayerGB2RGB_VNG = BayerGR2BGR_VNG;
    public static inline var BayerRG2RGB_VNG = BayerBG2BGR_VNG;
    public static inline var BayerGR2RGB_VNG = BayerGB2BGR_VNG;
    public static inline var BGR2HSV_FULL    = 66;
    public static inline var RGB2HSV_FULL    = 67;
    public static inline var BGR2HLS_FULL    = 68;
    public static inline var RGB2HLS_FULL    = 69;
    public static inline var HSV2BGR_FULL    = 70;
    public static inline var HSV2RGB_FULL    = 71;
    public static inline var HLS2BGR_FULL    = 72;
    public static inline var HLS2RGB_FULL    = 73;
    public static inline var LBGR2Lab        = 74;
    public static inline var LRGB2Lab        = 75;
    public static inline var LBGR2Luv        = 76;
    public static inline var LRGB2Luv        = 77;
    public static inline var Lab2LBGR        = 78;
    public static inline var Lab2LRGB        = 79;
    public static inline var Luv2LBGR        = 80;
    public static inline var Luv2LRGB        = 81;
    public static inline var BGR2YUV         = 82;
    public static inline var RGB2YUV         = 83;
    public static inline var YUV2BGR         = 84;
    public static inline var YUV2RGB         = 85;
    public static inline var BayerBG2GRAY    = 86;
    public static inline var BayerGB2GRAY    = 87;
    public static inline var BayerRG2GRAY    = 88;
    public static inline var BayerGR2GRAY    = 89;
    public static inline var YUV2RGB_NV12     = 90;
    public static inline var YUV2BGR_NV12     = 91;
    public static inline var YUV2RGB_NV21    = 92;
    public static inline var YUV2BGR_NV21    = 93;

    // -------------------------
    // Distance metric flags.
    // -------------------------
    public static inline var DIST_L1     = 1;
    public static inline var DIST_L2     = 2;
    public static inline var DIST_C      = 3;
    public static inline var DIST_L12    = 4;
    public static inline var DIST_FAIR   = 5;
    public static inline var DIST_WELSCH = 6;
    public static inline var DIST_HUBER  = 7;

    // -------------------------
    // Threshold operators flags.
    // -------------------------
    public static inline var THRESH_BINARY     = 0;
    public static inline var THRESH_BINARY_INV = 1;
    public static inline var THRESH_TRUNC      = 2;
    public static inline var THRESH_TOZERO     = 3;
    public static inline var THRESH_TOZERO_INV = 4;
    public static inline var THRESH_MASK      = 7;
    public static inline var THRESH_OTSU      = 8;

    public static inline var ADAPTIVE_THRESH_MEAN_C      = 0;
    public static inline var ADAPTIVE_THRESH_GAUSSIAN_C  = 1;

    // -------------------------
    // Border flags.
    // -------------------------
    public static inline var BORDER_CONSTANT    = 0;
    public static inline var BORDER_REPLICATE   = 1;
    public static inline var BORDER_REFLECT     = 2;
    public static inline var BORDER_WRAP        = 3;
    public static inline var BORDER_REFLECT_101 = 4;
    public static inline var BORDER_TRANSPARENT = 5;
    public static inline var BORDER_ISOLATED    = 16;
    public static inline var BORDER_DEFAULT     = BORDER_REFLECT_101;

    /** Returns a Mat kernel; custom kernels can be allocated and filled directly. */
    @:CvProc function getStructuringElement(shape:Int, size:Size, ?anchor:Null<Point>):Mat;
    @:CvProc function bilateralFilter(src:Arr, dst:Arr, d:Int, sigmaColor:Float, sigmaSpace:Float):Void;
    @:CvProc function dilate(src:Arr, dst:Arr, ?element:Null<Mat>, iterations:Int=1, ?anchor:Null<Point>):Void;
    @:CvProc function erode(src:Arr, dst:Arr, ?element:Null<Mat>, iterations:Int=1, ?anchor:Null<Point>):Void;
    @:CvProc function morphologyEx(src:Arr, dst:Arr, operation:Int, element:Mat, iterations:Int=1, ?anchor:Null<Point>):Void;
    @:CvProc function equalizeHist(src:Arr, dst:Arr):Void;
    /** CLAHE clip limit and tile-grid dimensions use modern OpenCV semantics. */
    @:CvProc function equalizeHistAdaptive(src:Arr, dst:Arr, clipLimit:Float=40, ?tileGridSize:Null<Size>):Void;
    @:CvProc function filter2D(src:Arr, dst:Arr, kernel:Mat, ddepth:Int=-1, ?anchor:Null<Point>, delta:Float=0, borderType:Int=BORDER_DEFAULT):Void;
    @:CvProc function gaussianBlur(src:Arr, dst:Arr, ksize:Size, sigmaX:Float, sigmaY:Float=0, borderType:Int=BORDER_DEFAULT):Void;
    @:CvProc function threshold(src:Arr, dst:Arr, threshold:Float, maxValue:Float, thresholdType:Int):Float;
    @:CvProc function medianBlur(src:Arr, dst:Arr, ksize:Int):Void;
    @:CvProc function pyrDown(src:Arr, dst:Arr):Void;
    @:CvProc function laplace(src:Arr, dst:Arr, ddepth:Int=-1, apertureSize:Int=3):Void;
    @:CvProc function sobel(src:Arr, dst:Arr, ddepth:Int, xorder:Int, yorder:Int, apertureSize:Int=3):Void;
    @:CvProc function integral(image:Arr, sum:Arr, ?sqsum:Null<Arr>, ?tiltedSum:Null<Arr>):Void;
    @:CvProc function cvtColor(src:Arr, dst:Arr, code:Int):Void;
    /** Labels are optional; custom legacy distance weights are not supported. */
    @:CvProc function distTransform(src:Arr, dst:Arr, distanceType:Int=DIST_L2, maskSize:Int=3, ?labels:Null<Arr>):Void;
    @:CvProc function acc(image:Arr, sum:Arr, ?mask:Null<Arr>):Void;
    @:CvProc function squareAcc(image:Arr, sqsum:Arr, ?mask:Null<Arr>):Void;
    @:CvProc function multiplyAcc(image1:Arr, image2:Arr, acc:Arr, ?mask:Null<Arr>):Void;
    @:CvProc function runningAvg(image:Arr, acc:Arr, alpha:Float, ?mask:Null<Arr>):Void;

    /** Replaces corners with copied point values and returns their count. */
    public static function goodFeaturesToTrack(image:Arr, corners:Array<Point2D32f>, maxCorners:Int,
        qualityLevel:Float, minDistance:Float, ?mask:Null<Arr>, blockSize:Int=3,
        useHarris:Bool=false, k:Float=0.04):Int {
        var handles:Array<Dynamic> = load("goodFeaturesToTrack", 8)(NativeBinding.native(image),
            maxCorners, qualityLevel, minDistance, NativeBinding.native(mask), blockSize, useHarris, k);
        corners.resize(handles.length);
        for (i in 0...handles.length) corners[i] = Point2D32f.cvt(handles[i]);
        return corners.length;
    }
}
