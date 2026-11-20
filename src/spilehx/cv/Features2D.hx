package spilehx.cv;

import spilehx.internal.NativeLibrary as Lib;
import spilehx.internal.Macros;
import spilehx.cv.features2d.GFFT;
import spilehx.cv.features2d.SIFT;

/** Factories for the retained modern feature detectors. */
class Features2D implements CvProcs {
    @:allow(spilehx.cv.features2d)
    static inline function load(n:String, p:Int=-1):Dynamic
        return Lib.load("opencv", "hx_cv_features2d_"+n, p > 5 ? -1 : p);

    /** Creates a good-features-to-track detector using GFTTDetector. */
    @:CvProc(GFFT) function gfft(maxCorners:Int=1000, qualityLevel:Float=0.01, minDistance:Float=1,
        blockSize:Int=3, useHarris:Bool=false, k:Float=0.04):GFFT;

    /** Creates a SIFT detector with single-precision, 128-column descriptors. */
    @:CvProc(SIFT) function sift(nFeatures:Int=0, nOctaveLayers:Int=3, contrastThreshold:Float=0.04,
        edgeThreshold:Float=10, sigma:Float=1.6):SIFT;
}
