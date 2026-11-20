package ;

import helpers.ImageFilters;

import spilehx.cv.features2d.KeyPoint;
import spilehx.cv.Features2D;
import spilehx.cv.ImgProc;
import spilehx.cv.Core;
import spilehx.cv.core.Mat;
import spilehx.cv.HighGUI;

class ImageTestBench {
	static function main() {
		trace("TestBench starting");
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
		trace("TestBenchApplication running");
		sourceImage = getImageInput("test.jpg");
		outputImage = sourceImage;

		showImageWindow(INPUT_WINDOW_TITLE, sourceImage);

		filters = getFilters();
		showFilterWindow(filters);

		showImageWindow(OUTPUT_WINDOW_TITLE, outputImage);

		HighGUI.waitKey(0);
		trace("waitKey(0) returned; exiting");
		HighGUI.destroyAllWindows();
		Sys.exit(0);
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
		updateWithFilters();
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

	private function showImageWindow(title:String, image:Mat) {
		HighGUI.namedWindow(title, HighGUI.WINDOW_AUTOSIZE | HighGUI.WINDOW_GUI_NORMAL);
		HighGUI.showImage(title, image);
	}

	private function getImageInput(path:String):Mat {
		var image:Mat = null;
		try {
			image = HighGUI.loadImage(path, HighGUI.IMREAD_COLOR_BGR);
		} catch (error:Dynamic) {
			trace("Image loading failed: " + Std.string(error));
			Sys.exit(1);
		}

		if (image == null) {
			trace("Image loading returned null; check the image path and file contents");
			Sys.exit(1);
		}

		return image;
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
