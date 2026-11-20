package spilehx.cv.features2d;

import spilehx.internal.NativeBinding;
import spilehx.cv.core.Mat;

/** Good-features-to-track detector, created by `Features2D.gfft`. */
class GFFT extends NativeBinding {
    @:allow(spilehx.cv)
    function new(nativeObject:Dynamic) {
        super(nativeObject);
    }
    @:allow(spilehx.cv)
    static inline function cvt(x:Dynamic):Null<GFFT> {
        return if (x == null) null else new GFFT(x);
    }

    /** Updates keypoint values and resizes the array to the detected count. */
    public function detect(image:Mat, mask:Null<Mat>, keypoints:Array<KeyPoint>):Int {
        var points:Array<Dynamic> = NativeBinding.mapNative(keypoints);
        var count:Int = Features2D.load("GFFT_detect", 4)(nativeObject,
            NativeBinding.native(image), NativeBinding.native(mask), points);
        keypoints.resize(points.length);
        for (i in 0...points.length)
            if (keypoints[i] == null) keypoints[i] = KeyPoint.cvt(points[i]);
        return count;
    }

    public inline function toString():String {
        return '{GFFT}';
    }
}
