package spilehx.cv.features2d;

import spilehx.build.NativeBinding;
import spilehx.cv.Core.Arr;
import spilehx.cv.features2d.KeyPoint;

class GFFT extends NativeBinding {
    @:allow(spilehx.cv)
    function new(nativeObject:Dynamic) {
        super(nativeObject);
    }
    @:allow(spilehx.cv)
    static inline function cvt(x:Dynamic):Null<GFFT> {
        return if (x == null) null else new GFFT(x);
    }

    @:CvProc public inline function detect(img:Arr, mask:Null<Arr>, keypoints:Array<KeyPoint>):Int {
        var points = NativeBinding.mapNative(keypoints);
        var ret = Features2D.load("GFFT_detect", 4)(this.nativeObject, img.nativeObject, NativeBinding.native(mask), points);
        for (i in keypoints.length...points.length) keypoints[i] = new KeyPoint(points[i]);
        return ret;
    }

    public inline function toString() {
        return '{GFFT}';
    }
}
