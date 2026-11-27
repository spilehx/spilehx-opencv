package spilehx.cv;

import spilehx.internal.NativeLibrary as Lib;
import spilehx.internal.Macros;
import spilehx.internal.NativeBinding;
import spilehx.cv.core.Mat;
import spilehx.cv.core.Point2D32f;
import spilehx.cv.objdetect.FaceDetectorYN;

/** ArUco marker detection and DNN-based face detection. */
class ObjDetect implements CvProcs {
    @:allow(spilehx.cv.objdetect)
    static inline function load(n:String, p:Int=-1):Dynamic
        return Lib.load("opencv", "hx_cv_objdetect_"+n, p > 5 ? -1 : p);

    /**
     * Loads a YuNet model once. Model loading failures throw an OpenCV error.
     *
     * @param model Path to the YuNet ONNX model file.
     * @param scoreThreshold Minimum detection score for retaining a face.
     * @return A reusable face detector.
     */
    @:CvProc(FaceDetectorYN) function faceDetectorYN(model:String, scoreThreshold:Float=0.9):FaceDetectorYN;

    /**
     * Detects DICT_5X5_50 markers without modifying the input image.
     *
     * @param image An 8-bit grayscale or BGR image.
     * @param corners Resized to contain four independent points per detected marker,
     * in OpenCV's clockwise order starting at the marker's top-left corner.
     * @param rejected Optional output resized to contain four corners per rejected candidate.
     * Rejected candidates have no decoded ID or canonical marker orientation.
     * @return Marker IDs matching the corner arrays, or an empty array when none are found.
     */
    public static function detectMarkers(image:Mat, corners:Array<Array<Point2D32f>>,
        ?rejected:Array<Array<Point2D32f>>):Array<Int> {
        var handles:Array<Array<Dynamic>> = [];
        var rejectedHandles:Array<Array<Dynamic>> = rejected == null ? null : [];
        var ids:Array<Int> = load("detectMarkers", 3)(NativeBinding.native(image), handles, rejectedHandles);
        corners.resize(handles.length);
        for (i in 0...handles.length) {
            corners[i] = [for (handle in handles[i]) Point2D32f.cvt(handle)];
        }
        if (rejected != null) {
            rejected.resize(rejectedHandles.length);
            for (i in 0...rejectedHandles.length) {
                rejected[i] = [for (handle in rejectedHandles[i]) Point2D32f.cvt(handle)];
            }
        }
        return ids;
    }
}
