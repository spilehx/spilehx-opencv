package spilehx.cv.features2d;

import spilehx.internal.NativeBinding;
import spilehx.cv.core.Mat;

/** SIFT detector and descriptor extractor, created by `Features2D.sift`. */
class SIFT extends NativeBinding {
    @:allow(spilehx.cv)
    function new(nativeObject:Dynamic) {
        super(nativeObject);
    }
    @:allow(spilehx.cv)
    static inline function cvt(x:Dynamic):Null<SIFT> {
        return if (x == null) null else new SIFT(x);
    }

    /**
     * Resizes keypoints and writes one descriptor row per resulting keypoint.
     * Set useProvidedKeypoints to compute descriptors for the supplied features.
     */
    public function detectAndCompute(image:Mat, mask:Null<Mat>, keypoints:Array<KeyPoint>,
        descriptors:Mat, useProvidedKeypoints:Bool=false):Int {
        var points:Array<Dynamic> = NativeBinding.mapNative(keypoints);
        var count:Int = Features2D.load("SIFT_detectAndCompute", 6)(nativeObject,
            NativeBinding.native(image), NativeBinding.native(mask), points,
            NativeBinding.native(descriptors), useProvidedKeypoints);
        keypoints.resize(points.length);
        for (i in 0...points.length)
            if (keypoints[i] == null) keypoints[i] = KeyPoint.cvt(points[i]);
        return count;
    }

    public inline function toString():String {
        return '{SIFT}';
    }
}
