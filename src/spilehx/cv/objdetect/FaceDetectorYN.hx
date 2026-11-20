package spilehx.cv.objdetect;

import spilehx.internal.NativeBinding;
import spilehx.cv.core.Mat;
import spilehx.cv.core.Rect;

/** YuNet face detector, created by `ObjDetect.faceDetectorYN`. */
class FaceDetectorYN extends NativeBinding {
    @:allow(spilehx.cv)
    function new(nativeObject:Dynamic) {
        super(nativeObject);
    }

    @:allow(spilehx.cv)
    static inline function cvt(x:Dynamic):Null<FaceDetectorYN> {
        return if (x == null) null else new FaceDetectorYN(x);
    }

    /**
     * Returns independent face rectangles clipped to the input BGR image.
     * Adjusts the detector input size to match the image. Inference failures
     * throw an OpenCV error.
     *
     * @param image BGR image to search for faces; its pixels are not modified.
     * @return Face rectangles, or an empty array when no faces are detected.
     */
    public function detect(image:Mat):Array<Rect> {
        var handles:Array<Dynamic> = ObjDetect.load("FaceDetectorYN_detect", 2)(nativeObject, NativeBinding.native(image));
        return [for (handle in handles) Rect.cvt(handle)];
    }
}
