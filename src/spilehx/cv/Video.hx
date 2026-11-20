package spilehx.cv;

import spilehx.internal.NativeBinding;
import spilehx.internal.NativeLibrary as Lib;
import spilehx.cv.core.*;
import spilehx.cv.Core;

import spilehx.internal.Macros;

/**
 * Optical flow between successive images, written into caller-supplied outputs.
 */
class Video implements CvProcs {
    @:allow(spilehx.cv.video)
    static inline function load(n:String, p:Int=-1):Dynamic
        return Lib.load("opencv", "hx_cv_video_"+n, p > 5 ? -1 : p);


    public static inline var LKFLOW_PYR_A_READY       = 1;
    public static inline var LKFLOW_PYR_B_READY       = 2;
    public static inline var LKFLOW_INITIAL_GUESSES   = 4;
    public static inline var LKFLOW_GET_MIN_EIGENVALS = 8;


    /**
     * Computes block-matching flow into the horizontal velx and vertical vely arrays.
     * @param blockSize Dimensions of each compared block.
     * @param shiftSize Step between blocks.
     * @param max_range Search range around each block.
     * @param usePrevious Whether existing velocity values provide initial estimates.
     */
    @:CvProc function calcOpticalFlowBM(prev:Arr, curr:Arr, blockSize:Size, shiftSize:Size, max_range:Size, usePrevious:Bool, velx:Arr, vely:Arr)
        load("calcOpticalFlowBM", 8)(prev.nativeObject, curr.nativeObject, blockSize.nativeObject, shiftSize.nativeObject, max_range.nativeObject, usePrevious ? 1 : 0, velx.nativeObject, vely.nativeObject);
    /**
     * Computes Horn-Schunck flow into the horizontal velx and vertical vely arrays.
     * @param usePrevious Whether existing velocity values provide initial estimates.
     * @param lambda Smoothness weight.
     * @param criteria Iteration stopping criteria.
     */
    @:CvProc function calcOpticalFlowHS(prev:Arr, curr:Arr, usePrevious:Bool, velx:Arr, vely:Arr, lambda:Float, criteria:TermCriteria)
        load("calcOpticalFlowHS", 7)(prev.nativeObject, curr.nativeObject, usePrevious ? 1 : 0, velx.nativeObject, vely.nativeObject, lambda, criteria.nativeObject);
    /**
     * Computes dense Lucas-Kanade flow into horizontal velx and vertical vely.
     * @param winSize Averaging window dimensions; each must be a power of two minus one.
     */
    @:CvProc function calcOpticalFlowLK(prev:Arr, curr:Arr, winSize:Size, velx:Arr, vely:Arr) {
        @:CvCheck if (winSize.width & (winSize.width + 1) != 0) throw "winSize.width must be power of 2, minus 1";
        @:CvCheck if (winSize.height & (winSize.height + 1) != 0) throw "winSize.height must be power of 2, minus 1";
        load("calcOpticalFlowLK", 5)(prev.nativeObject, curr.nativeObject, winSize.nativeObject, velx.nativeObject, vely.nativeObject);
    }

    // arrays currFeatures, status, and error will be resized as necessary by this call
    // to match the size of prevFeatures.
    /**
     * Tracks sparse features with pyramidal Lucas-Kanade flow. Output arrays are
     * resized to prevFeatures.length, and existing output point objects are updated.
     * @param prevPyr Previous-image pyramid buffer, or null for internal allocation.
     * @param currPyr Current-image pyramid buffer, or null for internal allocation.
     * @param prevFeatures Input feature positions in the previous image.
     * @param currFeatures Output positions; must contain an initial guess per feature when LKFLOW_INITIAL_GUESSES is set.
     * @param winSize Search window dimensions.
     * @param level Maximum pyramid level, with 0 using only the original images.
     * @param status Per-feature tracking success output.
     * @param error Optional per-feature error output; values for failed tracks are not meaningful.
     * @param criteria Iteration stopping criteria.
     * @param flags Combination of LKFLOW_* flags.
     * @throws String If initial guesses are requested but currFeatures is too short.
     */
    @:CvProc function calcOpticalFlowPyrLK(prev:Arr, curr:Arr, prevPyr:Null<Arr>, currPyr:Null<Arr>, prevFeatures:Array<Point2D32f>, currFeatures:Array<Point2D32f>, winSize:Size, level:Int, status:Array<Bool>, error:Null<Array<Float>>, criteria:TermCriteria, flags:Int) {
        if ((flags & LKFLOW_INITIAL_GUESSES) != 0 && currFeatures.length < prevFeatures.length)
            throw "calcOpticalFlowPyrLK :: currFeatures must contain an initial guess for each previous feature";
        var currs = NativeBinding.mapNative(currFeatures);
        load("calcOpticalFlowPyrLK", 13)(prev.nativeObject, curr.nativeObject, NativeBinding.native(prevPyr), NativeBinding.native(currPyr), NativeBinding.mapNative(prevFeatures), currs, prevFeatures.length, winSize.nativeObject, level, status, error, criteria.nativeObject, flags);
        for (i in currFeatures.length...currs.length)
            currFeatures[i] = new Point2D32f(currs[i]);
        currFeatures.resize(currs.length);
    }

    /**
     * Computes dense Farneback flow into a two-channel single-precision array.
     * @param flow Preallocated horizontal and vertical displacement output.
     * @param pyrScale Scale between pyramid layers, less than 1.
     * @param levels Number of pyramid layers including the original images.
     * @param winSize Averaging window size in pixels.
     * @param iterations Iterations at each pyramid level.
     * @param polyN Neighborhood size for polynomial expansion.
     * @param polySigma Gaussian sigma for polynomial expansion.
     * @param flags Native Farneback optical-flow flags.
     */
    @:CvProc function calcOpticalFlowFarneback(prev:Arr, curr:Arr, flow:Arr, pyrScale:Float, levels:Int, winSize:Int, iterations:Int, polyN:Int, polySigma:Float, flags:Int):Void;
}
