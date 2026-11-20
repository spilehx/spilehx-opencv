package spilehx.cv;

import spilehx.internal.NativeLibrary as Lib;
import spilehx.internal.Macros;
import spilehx.cv.objdetect.FaceDetectorYN;

/** DNN-based face detection using an external YuNet ONNX model. */
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
}
