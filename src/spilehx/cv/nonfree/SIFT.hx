package spilehx.cv.nonfree;

import spilehx.internal.NativeBinding;
import spilehx.cv.Core.Arr;
import spilehx.cv.features2d.KeyPoint;

/**
 * SIFT feature detector and descriptor extractor, created by `NonFree.sift`.
 */
class SIFT extends NativeBinding {
    @:allow(spilehx.cv)
    function new(nativeObject:Dynamic) {
        super(nativeObject);
    }
    @:allow(spilehx.cv)
    static inline function cvt(x:Dynamic):Null<SIFT> {
        return if (x == null) null else new SIFT(x);
    }


    // change of api on return value.
    /**
     * Detects features or computes descriptors for supplied keypoints. Updates
     * existing keypoint objects and grows the array without removing trailing entries.
     * @param img Input image.
     * @param mask Detection mask, or null to use the whole image.
     * @param keypoints Input/output keypoints; only the first returned count are results.
     * @param descriptors Optional output array, resized and filled with descriptor rows in sequence.
     * @param useProvidedKeypoints Whether to process supplied keypoints instead of detecting them.
     * @return Number of resulting keypoints.
     */
    @:CvProc public inline function detect(img:Arr, mask:Null<Arr>, keypoints:Array<KeyPoint>, ?descriptors:Null<Array<Float>>, useProvidedKeypoints:Bool=false):Int {
        var points = NativeBinding.mapNative(keypoints);
        var ret = NonFree.load("SIFT_detect", 6)(this.nativeObject, img.nativeObject, NativeBinding.native(mask), points, descriptors, useProvidedKeypoints);
        for (i in keypoints.length...points.length) keypoints[i] = new KeyPoint(points[i]);
        return ret;
    }


    public inline function toString() {
        return '{SIFT}';
    }
}
