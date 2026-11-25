package ;

import spilehx.cvutils.ImageFilters;
import spilehx.cv.Core;
import spilehx.cv.core.Mat;
import spilehx.cv.HighGUI;
import spilehx.cv.VideoCapture;

class VideoTestBench {
	static function main() {
		trace("VideoTestBench starting");
		new TestBenchApplication().run();
	}
}

private class TestBenchApplication {
	private static final INPUT_WINDOW_TITLE:String = "Input";
	private static final CHECKBOX_WINDOW_TITLE:String = "Filters";
	private static final OUTPUT_WINDOW_TITLE:String = "Output";

	private var sourceImage:Mat;
	private var outputImage:Mat;
	private var filters:Array<TestFilter>;

	public function new() {}

	public function run() {
		var capture = VideoCapture.fromCamera();
		if (capture == null)
			throw "Could not open webcam 0";

		try {
			HighGUI.namedWindow(INPUT_WINDOW_TITLE, HighGUI.WINDOW_AUTOSIZE | HighGUI.WINDOW_GUI_NORMAL);
			HighGUI.namedWindow(OUTPUT_WINDOW_TITLE, HighGUI.WINDOW_AUTOSIZE | HighGUI.WINDOW_GUI_NORMAL);
			filters = getFilters();
			showFilterWindow(filters);

			while (true) {
				var frame:Mat = capture.readFrame();
				if (frame == null) {
					trace("Webcam frame read failed; exiting");
					break;
				}

				sourceImage = frame;
				HighGUI.showImage(INPUT_WINDOW_TITLE, sourceImage);
				updateWithFilters();
				if (HighGUI.waitKey(1) == 27)
					break;
			}
		} catch (error:Dynamic) {
			capture.release();
			HighGUI.destroyAllWindows();
			throw error;
		}

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

	private function applyFilter(filter:TestFilter, checked:Bool):Void {
		filter.applied = checked;
	}

	private function updateWithFilters():Void {
		outputImage = sourceImage;
		for (filter in filters) {
			if (filter.applied) {
				outputImage = filter.callBack(outputImage);
			}
		}

		HighGUI.showImage(OUTPUT_WINDOW_TITLE, outputImage);
	}

	private function showFilterWindow(filters:Array<TestFilter>):Void {
		var title:String = CHECKBOX_WINDOW_TITLE;
		var height:Int = 20 + filters.length * 45;
		var panel:Mat = Core.createMat(height, 220, Core._8UC3);
		var redraw:Void->Void = function():Void {
			Core.rectangle(panel, Core.point(0, 0), Core.point(219, height - 1), Core.gray(40), -1);
			for (index in 0...filters.length) {
				var top:Int = 20 + index * 45;
				Core.rectangle(panel, Core.point(15, top), Core.point(39, top + 24), Core.gray(255), 1);
				if (filters[index].applied) {
					Core.line(panel, Core.point(20, top + 12), Core.point(25, top + 18), Core.gray(255), 2);
					Core.line(panel, Core.point(25, top + 18), Core.point(35, top + 6), Core.gray(255), 2);
				}
				Core.putText(panel, filters[index].label, Core.point(55, top + 19), 0, 0.6, Core.gray(255));
			}
			HighGUI.showImage(title, panel);
		};

		HighGUI.namedWindow(title, HighGUI.WINDOW_AUTOSIZE | HighGUI.WINDOW_GUI_NORMAL);
		redraw();
		HighGUI.setMouseCallback(title, function(event:Int, x:Int, y:Int, flags:Int):Void {
			if (event != HighGUI.EVENT_LBUTTONDOWN)
				return;
			if (x < 15 || x > 200)
				return;

			for (index in 0...filters.length) {
				var top:Int = 20 + index * 45;
				if (y >= top && y <= top + 24) {
					applyFilter(filters[index], !filters[index].applied);
					redraw();
					return;
				}
			}
		});
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

