package helpers;

import spilehx.cv.features2d.GFFT;
import spilehx.cv.Features2D;
import spilehx.cv.ImgProc;
import spilehx.cv.Core;
import spilehx.cv.core.Mat;
import spilehx.cv.features2d.KeyPoint;

class ImageFilters {
	private static var cornerDetector:GFFT = Features2D.gfft(80, 0.02, 12);

	public static function greyscale(source:Mat):Mat {
		if (source.channels == 1)
			return source;

		var grey:Mat = Core.createMat(source.rows, source.cols, Core._8UC1);
		ImgProc.cvtColor(source, grey, ImgProc.BGR2GRAY);
		return grey;
	}

	public static function gaussianBlur(source:Mat):Mat {
		var blurred:Mat = Core.createMat(source.rows, source.cols, Core._8UC1);
		ImgProc.gaussianBlur(source, blurred, Core.size(9, 9), 2.0);
		return blurred;
	}

	public static function detectCorners(source:Mat):Mat {
		var keypoints:Array<KeyPoint> = [];
		cornerDetector.detect(greyscale(source), null, keypoints);
		var corners:Mat = Core.cloneMat(source);
		for (keypoint in keypoints) {
			var point = keypoint.pt;
			Core.circle(corners, Core.point(Math.round(point.x), Math.round(point.y)), 5, Core.rgb(255, 70, 70), 2);
		}
		return corners;
	}

	public static function threshold(source:Mat):Mat {
		var thresh:Mat = Core.createMat(source.rows, source.cols, Core._8UC1);
		ImgProc.threshold(source, thresh, 128, 255, ImgProc.THRESH_BINARY);
		return thresh;
	}
}
