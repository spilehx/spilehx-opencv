package spilehx.cv;

import spilehx.internal.NativeBinding;
import spilehx.internal.NativeLibrary as Lib;
import spilehx.internal.Macros;
import spilehx.cv.core.*;
import spilehx.cv.core.Scalar.RGB;

/** Matrix input or destination, including reference-counted views. */
typedef Arr = Mat;

/** Modern matrix operations. Destination matrices are resized as needed. */
class Core implements CvProcs {
    @:allow(spilehx.cv.core)
    static inline function load(n:String, p:Int=-1):Dynamic
        return Lib.load("opencv", "hx_cv_core_"+n, p > 5 ? -1 : p);

    public static inline var TERMCRIT_ITER = 1;
    public static inline var TERMCRIT_EPS = 2;

    static inline function MAKETYPE(depth,cn) return (depth & 31) + ((cn-1) << 5);
    public static inline var _8U = 0;
        public static inline var _8UC1 = MAKETYPE(_8U,1);
        public static inline var _8UC2 = MAKETYPE(_8U,2);
        public static inline var _8UC3 = MAKETYPE(_8U,3);
        public static inline var _8UC4 = MAKETYPE(_8U,4);
    public static inline var _8S = 1;
        public static inline var _8SC1 = MAKETYPE(_8S,1);
        public static inline var _8SC2 = MAKETYPE(_8S,2);
        public static inline var _8SC3 = MAKETYPE(_8S,3);
        public static inline var _8SC4 = MAKETYPE(_8S,4);
    public static inline var _16U = 2;
        public static inline var _16UC1 = MAKETYPE(_16U,1);
        public static inline var _16UC2 = MAKETYPE(_16U,2);
        public static inline var _16UC3 = MAKETYPE(_16U,3);
        public static inline var _16UC4 = MAKETYPE(_16U,4);
    public static inline var _16S = 3;
        public static inline var _16SC1 = MAKETYPE(_16S,1);
        public static inline var _16SC2 = MAKETYPE(_16S,2);
        public static inline var _16SC3 = MAKETYPE(_16S,3);
        public static inline var _16SC4 = MAKETYPE(_16S,4);
    public static inline var _32S = 4;
        public static inline var _32SC1 = MAKETYPE(_32S,1);
        public static inline var _32SC2 = MAKETYPE(_32S,2);
        public static inline var _32SC3 = MAKETYPE(_32S,3);
        public static inline var _32SC4 = MAKETYPE(_32S,4);
    public static inline var _32F = 5;
        public static inline var _32FC1 = MAKETYPE(_32F,1);
        public static inline var _32FC2 = MAKETYPE(_32F,2);
        public static inline var _32FC3 = MAKETYPE(_32F,3);
        public static inline var _32FC4 = MAKETYPE(_32F,4);
    public static inline var _64F = 6;
        public static inline var _64FC1 = MAKETYPE(_64F,1);
        public static inline var _64FC2 = MAKETYPE(_64F,2);
        public static inline var _64FC3 = MAKETYPE(_64F,3);
        public static inline var _64FC4 = MAKETYPE(_64F,4);

    /**
     * @param N Channel count from 1 through 4.
     * @return Unsigned 8-bit matrix type for the requested channel count.
     */
    public static inline function _8UC (N:Int) return [_8UC1,  _8UC2,  _8UC3,  _8UC4 ][N-1];
    /**
     * @param N Channel count from 1 through 4.
     * @return Signed 8-bit matrix type for the requested channel count.
     */
    public static inline function _8SC (N:Int) return [_8SC1,  _8SC2,  _8SC3,  _8SC4 ][N-1];
    /**
     * @param N Channel count from 1 through 4.
     * @return Unsigned 16-bit matrix type for the requested channel count.
     */
    public static inline function _16UC(N:Int) return [_16UC1, _16UC2, _16UC3, _16UC4][N-1];
    /**
     * @param N Channel count from 1 through 4.
     * @return Signed 16-bit matrix type for the requested channel count.
     */
    public static inline function _16SC(N:Int) return [_16SC1, _16SC2, _16SC3, _16SC4][N-1];
    /**
     * @param N Channel count from 1 through 4.
     * @return Signed 32-bit matrix type for the requested channel count.
     */
    public static inline function _32SC(N:Int) return [_32SC1, _32SC2, _32SC3, _32SC4][N-1];
    /**
     * @param N Channel count from 1 through 4.
     * @return Single-precision matrix type for the requested channel count.
     */
    public static inline function _32FC(N:Int) return [_32FC1, _32FC2, _32FC3, _32FC4][N-1];
    /**
     * @param N Channel count from 1 through 4.
     * @return Double-precision matrix type for the requested channel count.
     */
    public static inline function _64FC(N:Int) return [_64FC1, _64FC2, _64FC3, _64FC4][N-1];

    public static inline var CMP_EQ = 0;
    public static inline var CMP_GT = 1;
    public static inline var CMP_GE = 2;
    public static inline var CMP_LT = 3;
    public static inline var CMP_LE = 4;
    public static inline var CMP_NE = 5;

    public static inline var DCT_INVERSE = DFT_INVERSE;
    public static inline var DCT_ROWS    = DFT_ROWS;

    public static inline var DFT_INVERSE        = 1;
    public static inline var DFT_SCALE          = 2;
    public static inline var DFT_ROWS           = 4;
    public static inline var DFT_COMPLEX_OUTPUT = 16;
    public static inline var DFT_REAL_OUTPUT    = 32;

    // -------------------------
    // Flags for drawing operations.
    // -------------------------
    public static inline var AA     = 16;
    public static inline var FILLED = -1;

    // -------------------------
    // Flags for supported font faces.
    // -------------------------
    public static inline var FONT_HERSHEY_SIMPLEX        = 0;
    public static inline var FONT_HERSHEY_PLAIN          = 1;
    public static inline var FONT_HERSHEY_DUPLEX         = 2;
    public static inline var FONT_HERSHEY_COMPLEX        = 3;
    public static inline var FONT_HERSHEY_TRIPLEX        = 4;
    public static inline var FONT_HERSHEY_COMPLEX_SMALL  = 5;
    public static inline var FONT_HERSHEY_SCRIPT_SIMPLEX = 6;
    public static inline var FONT_HERSHEY_SCRIPT_COMPLEX = 7;
    public static inline var FONT_ITALIC                 = 16;

    @:CvProc function absDiff(src1:Arr, src2:Arr, dst:Arr):Void;
    @:CvProc function absDiffS(src:Arr, value:Scalar, dst:Arr):Void;
    @:CvProc function add(src1:Arr, src2:Arr, dst:Arr, ?mask:Null<Arr>):Void;
    @:CvProc function addS(src:Arr, value:Scalar, dst:Arr, ?mask:Null<Arr>):Void;
    @:CvProc function addWeighted(src1:Arr, alpha:Float, src2:Arr, beta:Float, gamma:Float, dst:Arr):Void;
    @:CvProc function scaleAdd(src1:Arr, scale:Float, src2:Arr, dst:Arr):Void;
    @:CvProc function sub(src1:Arr, src2:Arr, dst:Arr, ?mask:Null<Arr>):Void;
    @:CvProc function mul(src1:Arr, src2:Arr, dst:Arr, scale:Float=1):Void;
    @:CvProc function div(src1:Arr, src2:Arr, dst:Arr, scale:Float=1):Void;
    @:CvProc function and(src1:Arr, src2:Arr, dst:Arr, ?mask:Null<Arr>):Void;
    @:CvProc function andS(src:Arr, value:Scalar, dst:Arr, ?mask:Null<Arr>):Void;
    @:CvProc function avg(arr:Arr, ?mask:Null<Arr>):Scalar;
    /** Writes per-channel statistics into the supplied scalars. */
    @:CvProc function avgSdv(arr:Arr, mean:Scalar, stdDev:Scalar, ?mask:Null<Arr>):Void;
    @:CvProc function cmp(src1:Arr, src2:Arr, dst:Arr, cmpOp:Int):Void;
    @:CvProc function cmpS(src:Arr, value:Float, dst:Arr, cmpOp:Int):Void;

    /** Converts to ddepth, or preserves the source depth when ddepth is -1. */
    @:CvProc function convertScale(src:Arr, dst:Arr, ddepth:Int=-1, scale:Float=1, shift:Float=0):Void;
    @:CvProc function convert(src:Arr, dst:Arr, ddepth:Int=-1):Void convertScale(src, dst, ddepth);
    @:CvProc function convertScaleAbs(src:Arr, dst:Arr, scale:Float=1, shift:Float=0):Void;
    @:CvProc function copy(src:Arr, dst:Arr, ?mask:Null<Arr>):Void;
    @:CvProc function set(arr:Arr, value:Scalar, ?mask:Null<Arr>):Void;
    @:CvProc function countNonZero(arr:Arr):Int;
    @:CvProc function DCT(src:Arr, dst:Arr, flags:Int=0):Void;
    @:CvProc function DFT(src:Arr, dst:Arr, flags:Int=0, nonzeroRows:Int=0):Void;
    @:CvProc function det(mat:Arr):Float;
    @:CvProc function dotProduct(src1:Arr, src2:Arr):Float;
    @:CvProc function magnitude(x:Arr, y:Arr, mag:Arr):Void;
    @:CvProc function phase(x:Arr, y:Arr, angle:Arr, angleInDegrees:Bool=false):Void;
    @:CvProc function cartToPolar(x:Arr, y:Arr, magnitude:Arr, angle:Arr, angleInDegrees:Bool=false):Void;
    @:CvProc function polarToCart(magnitude:Arr, angle:Arr, x:Arr, y:Arr, angleInDegrees:Bool=false):Void;

    @:CvProc function merge(mv:Array<Arr>, dst:Arr):Void;
    /** Returns owned headers for newly allocated channel matrices. */
    public static inline function split(src:Arr):Array<Mat> {
        var handles:Array<Dynamic> = load("split", 1)(NativeBinding.native(src));
        return [for (handle in handles) Mat.cvt(handle)];
    }

    /** Reads up to four channel values, with bounds and depth checks. */
    @:CvProc function get1D(arr:Arr, index:Int):Scalar;
    @:CvProc function get2D(arr:Arr, row:Int, col:Int):Scalar;
    @:CvProc function get3D(arr:Arr, i:Int, j:Int, k:Int):Scalar;
    @:CvProc function getND(arr:Arr, indices:Array<Int>):Scalar;
    @:CvProc function getReal1D(arr:Arr, index:Int):Float;
    @:CvProc function getReal2D(arr:Arr, row:Int, col:Int):Float;
    @:CvProc function getReal3D(arr:Arr, i:Int, j:Int, k:Int):Float;
    @:CvProc function getRealND(arr:Arr, indices:Array<Int>):Float;

    /** Returns a shared view that keeps its storage alive independently of arr. */
    @:CvProc function getCols(arr:Arr, startCol:Int, endCol:Int):Mat;
    @:CvProc function getRows(arr:Arr, startRow:Int, endRow:Int):Mat;
    @:CvProc function getDiag(arr:Arr, diag:Int=0):Mat;
    @:CvProc function getSubRect(arr:Arr, rect:Rect):Mat;
    @:CvProc function getCol(arr:Arr, col:Int):Mat return getCols(arr, col, col+1);
    @:CvProc function getRow(arr:Arr, row:Int):Mat return getRows(arr, row, row+1);
    @:CvProc function getElemType(arr:Arr):Int;
    @:CvProc function getSize(arr:Arr):Size;

    /** Single-channel floating-point access; other depths use typed Mat accessors. */
    @:CvProc function mGet(mat:Mat, row:Int, col:Int):Float;
    @:CvProc function mSet(mat:Mat, row:Int, col:Int, value:Float):Float;
    @:CvProc function cloneMat(mat:Mat):Mat;
    /** Zero dimensions create an empty destination; allocated data is uninitialized. */
    @:CvProc function createMat(rows:Int=0, cols:Int=0, type:Int=_8UC1):Mat;

    @:CvProc(Point) function point(x:Int=0, y:Int=0):Point;
    @:CvProc(Point2D32f) function point2D32f(x:Float=0, y:Float=0):Point2D32f;
    @:CvProc(Point2D64f) function point2D64f(x:Float=0, y:Float=0):Point2D64f;
    @:CvProc(Point3D32f) function point3D32f(x:Float=0, y:Float=0, z:Float=0):Point3D32f;
    @:CvProc(Point3D64f) function point3D64f(x:Float=0, y:Float=0, z:Float=0):Point3D64f;
    @:CvProc(Rect) function rect(x:Int=0, y:Int=0, width:Int=0, height:Int=0):Rect;
    @:CvProc(Scalar) function scalar(x:Float=0, y:Float=0, z:Float=0, w:Float=0):Scalar;
    @:CvProc(Size) function size(width:Int=0, height:Int=0):Size;
    @:CvProc(Size2D32f) function size2D32f(width:Float=0, height:Float=0):Size2D32f;
    @:CvProc(TermCriteria) function termCriteria(type:Int, maxCount:Int, epsilon:Float):TermCriteria;

    @:CvProc function scalarAll(v:Float):Scalar return scalar(v, v, v, v);
    @:CvProc function realScalar(v:Float):Scalar return scalar(v);
    @:CvProc function gray(v:Float=0):RGB return scalar(v, v, v);
    @:CvProc function rgb(r:Float=0, g:Float=0, b:Float=0):RGB return scalar(b, g, r);

    @:CvProc function circle(img:Arr, center:Point, radius:Int, color:RGB, thickness:Int=1, lineType:Int=8, shift:Int=0):Void;
    @:CvProc function line(img:Arr, pt1:Point, pt2:Point, color:RGB, thickness:Int=1, lineType:Int=8, shift:Int=0):Void;
    @:CvProc function rectangle(img:Arr, pt1:Point, pt2:Point, color:RGB, thickness:Int=1, lineType:Int=8, shift:Int=0):Void;
    /** Draws text using a FONT_* face and a single scale. */
    @:CvProc function putText(img:Arr, text:String, org:Point, fontFace:Int, fontScale:Float, color:RGB, thickness:Int=1, lineType:Int=8, bottomLeftOrigin:Bool=false):Void;
}
