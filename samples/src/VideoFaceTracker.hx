package;

import spilehx.cvutils.ImageFilters;
import spilehx.cvutils.FaceTrackingHelper;
import spilehx.cv.Core;
import spilehx.cv.core.Mat;
import spilehx.cv.HighGUI;
import spilehx.cv.VideoCapture;

class VideoFaceTracker {
	static function main() {
		trace("VideoFaceTracker starting");
		new FaceTrackerApplication().run();
	}
}

private class FaceTrackerApplication {
	private static final INPUT_WINDOW_TITLE:String = "Input";
	private static final CHECKBOX_WINDOW_TITLE:String = "Filters";
	private static final OUTPUT_WINDOW_TITLE:String = "Output";
	private static final CAMERA_ID:Int = 5;

	private var filters:Array<TestFilter>;
	private var faceTracker:FaceTrackingHelper;

	public function new() {}

	public function run():Void {
		faceTracker = new FaceTrackingHelper();
		var capture:VideoCapture = openCamera();

		try {
			initializeWindows();
			captureFrames(capture);
		} catch (error:Dynamic) {
			closeCapture(capture);
			throw error;
		}

		closeCapture(capture);
	}

	private function openCamera():VideoCapture {
		var capture:VideoCapture = VideoCapture.fromCamera(CAMERA_ID);
		if (capture == null)
			throw "Could not open webcam " + CAMERA_ID;
		return capture;
	}

	private function initializeWindows():Void {
		HighGUI.namedWindow(INPUT_WINDOW_TITLE, HighGUI.WINDOW_AUTOSIZE | HighGUI.WINDOW_GUI_NORMAL);
		HighGUI.namedWindow(OUTPUT_WINDOW_TITLE, HighGUI.WINDOW_AUTOSIZE | HighGUI.WINDOW_GUI_NORMAL);
		filters = getFilters();
		showFilterWindow(filters);
	}

	private function captureFrames(capture:VideoCapture):Void {
		while (true) {
			var frame:Mat = capture.readFrame();
			if (frame == null) {
				trace("Webcam frame read failed; exiting");
				break;
			}

			processFrame(frame);
			if (HighGUI.waitKey(1) == 27)
				break;
		}
	}

	private function processFrame(frame:Mat):Void {
		faceTracker.update(frame);
		HighGUI.showImage(INPUT_WINDOW_TITLE, frame);
		showOutput(applyFilters(frame));
	}

	private function closeCapture(capture:VideoCapture):Void {
		capture.release();
		HighGUI.destroyAllWindows();
	}

	private function getFilters():Array<TestFilter> {
		return [
			new TestFilter("Grey scale", ImageFilters.greyscale),
			new TestFilter("Gaussian Blur", ImageFilters.gaussianBlur),
			new TestFilter("Threshold", ImageFilters.threshold),
			new TestFilter("DetectCorners", ImageFilters.detectCorners)
		];
	}

	private function applyFilters(sourceImage:Mat):Mat {
		var outputImage:Mat = Core.cloneMat(sourceImage);
		for (filter in filters) {
			if (filter.applied) {
				outputImage = filter.callBack(outputImage);
			}
		}
		return outputImage;
	}

	private function showOutput(outputImage:Mat):Void {
		faceTracker.draw(outputImage);
		HighGUI.showImage(OUTPUT_WINDOW_TITLE, outputImage);
	}

	private function showFilterWindow(filters:Array<TestFilter>):Void {
		var title:String = CHECKBOX_WINDOW_TITLE;
		var height:Int = 20 + filters.length * 45;
		var panel:Mat = Core.createMat(height, 220, Core._8UC3);
		var redraw:Void->Void = function():Void {
			drawFilterPanel(panel, filters);
			HighGUI.showImage(title, panel);
		};

		HighGUI.namedWindow(title, HighGUI.WINDOW_AUTOSIZE | HighGUI.WINDOW_GUI_NORMAL);
		redraw();
		HighGUI.setMouseCallback(title, function(event:Int, x:Int, y:Int, flags:Int):Void {
			if (event != HighGUI.EVENT_LBUTTONDOWN)
				return;
			if (toggleFilterAt(filters, x, y))
				redraw();
		});
	}

	private function drawFilterPanel(panel:Mat, filters:Array<TestFilter>):Void {
		Core.rectangle(panel, Core.point(0, 0), Core.point(panel.cols - 1, panel.rows - 1), Core.gray(40), -1);
		for (index in 0...filters.length) {
			var top:Int = 20 + index * 45;
			Core.rectangle(panel, Core.point(15, top), Core.point(39, top + 24), Core.gray(255), 1);
			if (filters[index].applied) {
				Core.line(panel, Core.point(20, top + 12), Core.point(25, top + 18), Core.gray(255), 2);
				Core.line(panel, Core.point(25, top + 18), Core.point(35, top + 6), Core.gray(255), 2);
			}
			Core.putText(panel, filters[index].label, Core.point(55, top + 19), 0, 0.6, Core.gray(255));
		}
	}

	private function toggleFilterAt(filters:Array<TestFilter>, x:Int, y:Int):Bool {
		if (x < 15 || x > 200)
			return false;

		for (index in 0...filters.length) {
			var top:Int = 20 + index * 45;
			if (y >= top && y <= top + 24) {
				filters[index].applied = !filters[index].applied;
				return true;
			}
		}
		return false;
	}
}

private class TestFilter {
	public var label(default, null):String;
	public var callBack(default, null):Mat->Mat;
	public var applied:Bool = false;

	public function new(label:String, callBack:Mat->Mat) {
		this.label = label;
		this.callBack = callBack;
		this.applied = false;
	}
}
