package spilehx.cvutils;

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

	public static function threshold(source:Mat, cutoffValue:Float=128, maxValue:Float=255):Mat {
		var thresh:Mat = Core.createMat(source.rows, source.cols, Core._8UC1);
		ImgProc.threshold(source, thresh, cutoffValue, maxValue, ImgProc.THRESH_BINARY);
		return thresh;
	}

	/** Keeps current source pixels that differ from the target background; unchanged pixels are black. */
	public static function subtractMat(source:Mat, target:Mat, differenceThreshold:Int=20):Mat {
		if (differenceThreshold < 0 || differenceThreshold > 255)
			throw "Background difference threshold must be between 0 and 255";
		if (source.rows != target.rows || source.cols != target.cols)
			throw "Current frame and background must have matching dimensions";
		var sourceType:Int = source.type;
		var targetType:Int = target.type;
		if ((sourceType != Core._8UC1 && sourceType != Core._8UC3)
				|| (targetType != Core._8UC1 && targetType != Core._8UC3))
			throw "Background subtraction requires 8-bit grayscale or BGR images";

		var current:Mat = source;
		var background:Mat = target;
		if (sourceType != targetType) {
			current = greyscale(source);
			background = greyscale(target);
		}
		var difference:Mat = Core.createMat();
		Core.absDiff(current, background, difference);
		var mask:Mat = greyscale(difference);
		ImgProc.threshold(mask, mask, differenceThreshold, 255, ImgProc.THRESH_BINARY);
		var result:Mat = Core.createMat(source.rows, source.cols, sourceType);
		Core.set(result, Core.gray(0));
		Core.copy(source, result, mask);
		return result;
	}
}
