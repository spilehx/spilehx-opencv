package spilehx.cv;

import spilehx.internal.NativeLibrary as Lib;
import spilehx.cv.core.*;
import spilehx.cv.Core;
import spilehx.cv.nonfree.*;

import spilehx.internal.Macros;

/**
 * Factory methods for the OpenCV 2.4 nonfree SIFT and SURF implementations.
 */
class NonFree implements CvProcs {
    @:allow(spilehx.cv.nonfree)
    static inline function load(n:String, p:Int=-1):Dynamic
        return Lib.load("opencv", "hx_cv_nonfree_"+n, p > 5 ? -1 : p);


    // -------------------------
    // SURF/SIFT
    // -------------------------
    // Differs from C++-API with non-constructor being used.
    /**
     * Creates a SURF detector and descriptor extractor.
     * @param hessianThreshold Hessian response threshold for detection.
     * @param nOctaves Number of pyramid octaves.
     * @param nOctaveLayers Number of layers in each octave.
     * @param extended Whether to use 128-component rather than 64-component descriptors.
     * @param upright Whether to skip orientation estimation.
     * @return A new SURF instance.
     */
    @:CvProc(SURF) function surf(hessianThreshold:Float, nOctaves:Int=4, nOctaveLayers:Int=2, extended:Bool=true, upright:Bool=false):SURF {
        var ret = SURF.cvt(load("SURF", 5)(hessianThreshold, nOctaves, nOctaveLayers, extended, upright));
        ret.extended = extended;
        return ret;
    }
    /**
     * Creates a SIFT detector and descriptor extractor.
     * @param nFeatures Maximum retained features, or 0 for no limit.
     * @param nOctaveLayers Number of layers in each octave.
     * @param constrastThreshold Contrast threshold used to reject weak features.
     * @param edgeThreshold Threshold used to reject edge-like features.
     * @param sigma Gaussian blur sigma for the initial octave.
     * @return A new SIFT instance.
     */
    @:CvProc(SIFT) function sift(nFeatures:Int=0, nOctaveLayers:Int=3, constrastThreshold:Float=0.04, edgeThreshold:Float=10, sigma:Float=1.6):SIFT;
}
