package spilehx.cvutils;

import haxe.io.Path;
import sys.FileSystem;
import spilehx.cvutils.ImageFilters;
import spilehx.cv.Core;
import spilehx.cv.ImgProc;
import spilehx.cv.ObjDetect;
import spilehx.cv.Video;
import spilehx.cv.core.Mat;
import spilehx.cv.core.Point2D32f;
import spilehx.cv.core.Rect;
import spilehx.cv.objdetect.FaceDetectorYN;

/** Tracks face regions; IDs describe continuous tracks, not recognised people. */
class FaceTrackingHelper {
	private static final DETECTION_INTERVAL:Int = 10;
	private static final MIN_POINTS:Int = 6;
	private static final MAX_MISSED_DETECTIONS:Int = 2;

	private var detector:FaceDetectorYN;
	private var previousGrey:Null<Mat>;
	private var faces:Array<TrackedFace> = [];
	private var framesSinceDetection:Int = DETECTION_INTERVAL;
	private var nextId:Int = 1;

	public function new() {
		detector = ObjDetect.faceDetectorYN(findModelPath());
	}

	private function findModelPath():String {
		var arguments:Array<String> = Sys.args();
		if (arguments.length > 0) {
			if (!isModelFile(arguments[0]))
				throw 'YuNet model not found: ${arguments[0]}';
			return arguments[0];
		}

		for (candidate in getDefaultModelPaths()) {
			if (isModelFile(candidate))
				return candidate;
		}
		throw "YuNet model not found. Pass the ONNX model path as the first argument.";
	}

	private function isModelFile(path:String):Bool {
		return FileSystem.exists(path) && !FileSystem.isDirectory(path);
	}

	private function getDefaultModelPaths():Array<String> {
		var modelName:String = "face_detection_yunet_2026may.onnx";
		return [
			Path.join([Path.directory(Sys.programPath()), "..", "models", modelName]),
			Path.join(["models", modelName]),
			Path.join(["samples", "models", modelName])
		];
	}

	public function update(frame:Mat):Void {
		var grey:Mat = ImageFilters.greyscale(frame);
		if (previousGrey != null && (previousGrey.rows != grey.rows || previousGrey.cols != grey.cols)) {
			faces = [];
			previousGrey = null;
		}

		var needsDetection:Bool = faces.length == 0 || framesSinceDetection >= DETECTION_INTERVAL;
		if (previousGrey != null) {
			for (face in faces) {
				if (!track(face, previousGrey, grey))
					needsDetection = true;
			}
		}

		if (needsDetection) {
			refreshDetections(detector.detect(frame), grey);
			framesSinceDetection = 0;
		}
		previousGrey = grey;
		framesSinceDetection++;
	}

	public function draw(image:Mat):Void {
		for (face in faces) {
			var box:Rect = face.box;
			Core.rectangle(image, Core.point(box.x, box.y), Core.point(box.x + box.width - 1, box.y + box.height - 1),
				Core.gray(255), 2);
			Core.putText(image, 'Face ${face.id}', Core.point(box.x, Std.int(Math.max(18, box.y - 6))),
				0, 0.6, Core.gray(255), 2);
		}
	}

	private function track(face:TrackedFace, previous:Mat, current:Mat):Bool {
		if (face.points.length < MIN_POINTS) {
			face.points = [];
			return false;
		}

		var forward:Array<Point2D32f> = [];
		var status:Array<Bool> = [];
		Video.calcOpticalFlowPyrLK(previous, current, face.points, forward, status);
		var origins:Array<Point2D32f> = [];
		var candidates:Array<Point2D32f> = [];
		for (i in 0...forward.length) {
			var point:Point2D32f = forward[i];
			if (status[i] && insideImage(point, current)) {
				origins.push(face.points[i]);
				candidates.push(point);
			}
		}

		var backward:Array<Point2D32f> = [];
		var backwardStatus:Array<Bool> = [];
		Video.calcOpticalFlowPyrLK(current, previous, candidates, backward, backwardStatus);
		var goodPoints:Array<Point2D32f> = [];
		var dx:Array<Float> = [];
		var dy:Array<Float> = [];
		for (i in 0...candidates.length) {
			var errorX:Float = backward[i].x - origins[i].x;
			var errorY:Float = backward[i].y - origins[i].y;
			if (backwardStatus[i] && errorX * errorX + errorY * errorY <= 2.25) {
				goodPoints.push(candidates[i]);
				dx.push(candidates[i].x - origins[i].x);
				dy.push(candidates[i].y - origins[i].y);
			}
		}
		if (goodPoints.length < MIN_POINTS) {
			face.points = [];
			return false;
		}

		var moveX:Float = median(dx);
		var moveY:Float = median(dy);
		face.positionX += moveX;
		face.positionY += moveY;
		var box:Rect = clipBox(Core.rect(Math.round(face.positionX), Math.round(face.positionY),
			face.box.width, face.box.height), current);
		if (box.x != Math.round(face.positionX))
			face.positionX = box.x;
		if (box.y != Math.round(face.positionY))
			face.positionY = box.y;
		var tolerance:Float = Math.max(3, Math.min(box.width, box.height) * 0.1);
		face.points = [];
		for (i in 0...goodPoints.length) {
			var point:Point2D32f = goodPoints[i];
			if (Math.abs(dx[i] - moveX) <= tolerance && Math.abs(dy[i] - moveY) <= tolerance
				&& point.x >= box.x && point.x < box.x + box.width
				&& point.y >= box.y && point.y < box.y + box.height)
				face.points.push(point);
		}
		face.box = box;
		return face.points.length >= MIN_POINTS;
	}

	private function refreshDetections(detections:Array<Rect>, grey:Mat):Void {
		var remaining:Array<TrackedFace> = faces.copy();
		var boxes:Array<Rect> = [for (box in detections) if (box.width > 0 && box.height > 0) box];
		var refreshed:Array<TrackedFace> = [];

		// Match the strongest overlap first, assigning each track and detection once.
		while (remaining.length > 0 && boxes.length > 0) {
			var bestOverlap:Float = 0.2;
			var bestFace:Int = -1;
			var bestBox:Int = -1;
			for (i in 0...remaining.length) {
				for (j in 0...boxes.length) {
					var overlap:Float = intersectionOverUnion(remaining[i].box, boxes[j]);
					if (overlap > bestOverlap) {
						bestOverlap = overlap;
						bestFace = i;
						bestBox = j;
					}
				}
			}
			if (bestFace < 0)
				break;

			var face:TrackedFace = remaining.splice(bestFace, 1)[0];
			face.box = boxes.splice(bestBox, 1)[0];
			face.positionX = face.box.x;
			face.positionY = face.box.y;
			face.missedDetections = 0;
			seedPoints(face, grey);
			refreshed.push(face);
		}

		for (box in boxes) {
			var face:TrackedFace = new TrackedFace(nextId++, box);
			seedPoints(face, grey);
			refreshed.push(face);
		}
		for (face in remaining) {
			face.missedDetections++;
			if (face.points.length >= MIN_POINTS && face.missedDetections <= MAX_MISSED_DETECTIONS)
				refreshed.push(face);
		}
		faces = refreshed;
	}

	private function seedPoints(face:TrackedFace, grey:Mat):Void {
		var mask:Mat = Core.createMat(grey.rows, grey.cols, Core._8UC1);
		Core.set(mask, Core.gray(0));
		var box:Rect = face.box;
		var insetX:Int = Std.int(box.width * 0.1);
		var insetY:Int = Std.int(box.height * 0.1);
		Core.rectangle(mask, Core.point(box.x + insetX, box.y + insetY),
			Core.point(box.x + box.width - insetX - 1, box.y + box.height - insetY - 1), Core.gray(255), -1);
		ImgProc.goodFeaturesToTrack(grey, face.points, 80, 0.01, 4, mask);
	}

	private static function insideImage(point:Point2D32f, image:Mat):Bool {
		return Math.isFinite(point.x) && Math.isFinite(point.y)
			&& point.x >= 0 && point.x < image.cols && point.y >= 0 && point.y < image.rows;
	}

	private static function median(values:Array<Float>):Float {
		var sorted:Array<Float> = values.copy();
		sorted.sort(function(a:Float, b:Float):Int { return a < b ? -1 : (a > b ? 1 : 0); });
		var middle:Int = Std.int(sorted.length / 2);
		return sorted.length % 2 == 0 ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle];
	}

	private static function clipBox(box:Rect, image:Mat):Rect {
		var left:Int = Std.int(Math.max(0, Math.min(image.cols, box.x)));
		var top:Int = Std.int(Math.max(0, Math.min(image.rows, box.y)));
		var right:Int = Std.int(Math.max(left, Math.min(image.cols, box.x + box.width)));
		var bottom:Int = Std.int(Math.max(top, Math.min(image.rows, box.y + box.height)));
		return Core.rect(left, top, right - left, bottom - top);
	}

	private static function intersectionOverUnion(a:Rect, b:Rect):Float {
		var width:Float = Math.max(0, Math.min(a.x + a.width, b.x + b.width) - Math.max(a.x, b.x));
		var height:Float = Math.max(0, Math.min(a.y + a.height, b.y + b.height) - Math.max(a.y, b.y));
		var intersection:Float = width * height;
		var unionArea:Float = a.width * a.height + b.width * b.height - intersection;
		return unionArea > 0 ? intersection / unionArea : 0;
	}
}

private class TrackedFace {
	public var id(default, null):Int;
	public var box:Rect;
	public var positionX:Float;
	public var positionY:Float;
	public var points:Array<Point2D32f> = [];
	public var missedDetections:Int = 0;

	public function new(id:Int, box:Rect) {
		this.id = id;
		this.box = box;
		positionX = box.x;
		positionY = box.y;
	}
}
