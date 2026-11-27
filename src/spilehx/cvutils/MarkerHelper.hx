package spilehx.cvutils;

import spilehx.cv.ObjDetect;
import spilehx.cv.core.Mat;
import spilehx.cv.core.Point2D32f;

class MarkerHelper {
    /** Returns DICT_5X5_50 markers with their IDs and four corner coordinates. */
    public static function detectMarkers(source:Mat):Array<Marker> {
        var corners:Array<Array<Point2D32f>> = [];
        var ids:Array<Int> = ObjDetect.detectMarkers(source, corners);
        return [for (i in 0...ids.length) new Marker(ids[i], corners[i])];
    }

    /** Returns rejected square candidates with four corners each and no decoded marker IDs. */
    public static function detectRejectedCandidates(source:Mat):Array<RejectedMarker> {
        var rejected:Array<Array<Point2D32f>> = [];
        ObjDetect.detectMarkers(source, [], rejected);
        return [for (corners in rejected) new RejectedMarker(corners)];
    }
}

/** A detected marker with independent corner coordinates in image pixels. */
class Marker {
    public var id:Int;

    /** Clockwise from the marker's top-left corner, accounting for its orientation. */
    public var corners:Array<Point2D32f>;

    public function new(id:Int, corners:Array<Point2D32f>) {
        this.id = id;
        this.corners = corners;
    }
}
/** A rejected square candidate with independent corner coordinates in image pixels. */
class RejectedMarker {
    /** Four corners in OpenCV's candidate order, without a canonical marker orientation. */
    public var corners:Array<Point2D32f>;

    public function new(corners:Array<Point2D32f>) {
        this.corners = corners;
    }
}
