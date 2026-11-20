package spilehx.cv;

import spilehx.internal.NativeBinding;
import spilehx.internal.NativeLibrary as Lib;
import spilehx.internal.Macros;
import spilehx.cv.core.Mat;
import spilehx.cv.core.Point2D32f;
import spilehx.cv.core.Size;
import spilehx.cv.core.TermCriteria;

/** Modern sparse PyrLK and dense Farneback optical flow. */
class Video implements CvProcs {
    @:allow(spilehx.cv.video)
    static inline function load(n:String, p:Int=-1):Dynamic
        return Lib.load("opencv", "hx_cv_video_"+n, p > 5 ? -1 : p);

    public static inline var OPTFLOW_USE_INITIAL_FLOW = 4;
    public static inline var OPTFLOW_LK_GET_MIN_EIGENVALS = 8;
    public static inline var OPTFLOW_FARNEBACK_GAUSSIAN = 256;

    /**
     * Resizes currFeatures, status and optional error to prevFeatures.length.
     * Initial flow requires one current point per previous point. Errors for failed
     * tracks are undefined. Null window/criteria use OpenCV's ordinary defaults.
     */
    public static function calcOpticalFlowPyrLK(prev:Mat, curr:Mat, prevFeatures:Array<Point2D32f>,
        currFeatures:Array<Point2D32f>, status:Array<Bool>, ?error:Null<Array<Float>>,
        ?winSize:Null<Size>, maxLevel:Int=3, ?criteria:Null<TermCriteria>, flags:Int=0,
        minEigThreshold:Float=1e-4):Void {
        var points:Array<Dynamic> = NativeBinding.mapNative(currFeatures);
        load("calcOpticalFlowPyrLK", 11)(NativeBinding.native(prev), NativeBinding.native(curr),
            NativeBinding.mapNative(prevFeatures), points, status, error, NativeBinding.native(winSize),
            maxLevel, NativeBinding.native(criteria), flags, minEigThreshold);
        currFeatures.resize(points.length);
        for (i in 0...points.length)
            if (currFeatures[i] == null) currFeatures[i] = Point2D32f.cvt(points[i]);
    }

    /** Writes horizontal/vertical displacement into a resizable _32FC2 matrix. */
    @:CvProc function calcOpticalFlowFarneback(prev:Mat, curr:Mat, flow:Mat, pyrScale:Float=0.5,
        levels:Int=3, winSize:Int=15, iterations:Int=3, polyN:Int=5, polySigma:Float=1.2,
        flags:Int=0):Void;
}
