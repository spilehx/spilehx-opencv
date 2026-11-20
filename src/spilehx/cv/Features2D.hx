package spilehx.cv;

import spilehx.internal.NativeLibrary as Lib;
import spilehx.cv.core.*;
import spilehx.cv.Core;
import spilehx.cv.features2d.*;

import spilehx.internal.Macros;

/**
 * Factory methods for feature detectors. Detection is performed on the returned objects.
 */
class Features2D implements CvProcs {
    @:allow(spilehx.cv.features2d)
    static inline function load(n:String, p:Int=-1):Dynamic
        return Lib.load("opencv", "hx_cv_features2d_"+n, p > 5 ? -1 : p);

    // -------------------------
    // BRISK
    // -------------------------
    // Differs from C++ API with non-constructor being used.
    /**
     * Creates a BRISK detector and descriptor extractor.
     * @param thresh Detection threshold.
     * @param octaves Number of detection octaves.
     * @param patternScale Scale factor for the descriptor sampling pattern.
     * @return A new BRISK instance.
     */
    @:CvProc(BRISK) function brisk(thresh:Int=30, octaves:Int=3, patternScale:Float=1.0):BRISK;

    /**
     * Creates a good-features-to-track detector.
     * @param maxCorners Maximum number of features to retain.
     * @param qualityLevel Minimum quality relative to the strongest corner.
     * @param minDistance Minimum separation between features in pixels.
     * @param blockSize Neighborhood size for corner estimation.
     * @param useHarris Whether to use Harris corner detection.
     * @param k Harris detector parameter, used when useHarris is true.
     * @return A new detector.
     */
    @:CvProc(GFFT) function gfft(maxCorners:Int, qualityLevel:Float, minDistance:Float, blockSize:Int=3, useHarris:Bool=false, k:Float=0.04):GFFT;
}
