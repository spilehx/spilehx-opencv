import spilehx.cv.ImgProc;
import spilehx.cv.Core;
import spilehx.cv.core.Mat;
import spilehx.cv.HighGUI;

class TestBench {
	static function main() {
		trace("TestBench starting");
		new TestBenchApplication().run();
	}
}

class TestBenchApplication {
	private var sourceImage:Mat;
	private var outputImage:Mat;
	private var filters:Array<TestFilter>;

	public function new() {}

	public function run() {
		trace("TestBenchApplication running");
		sourceImage = getImageInput("test.jpg");
		outputImage = sourceImage;

		showImageWindow("Input window", sourceImage);

		filters = getFilters();
		showFilterWindow(filters);

		showImageWindow("Output window", outputImage);

		HighGUI.waitKey(0);
		trace("waitKey(0) returned; exiting");
		HighGUI.destroyAllWindows();
		Sys.exit(0);
	}

	private function getFilters():Array<TestFilter> {
		return [
			// new TestFilter("Filter 1", function(checked:Bool):Void {
			// 	filterCallBack(checked, ImageFilters.greyscale);
			// }),
			new TestFilter("Filter 2", function(checked:Bool):Void {
				filterCallBack(checked, ImageFilters.greyscale);
			})
		];
	}

	private function filterCallBack(checked:Bool, filter:Bool->Mat->Mat):Void {
		trace("Filter callback called with checked: " + checked);
		outputImage = filter(checked, outputImage);
	}

	private function applyFilter(filter:TestFilter, checked:Bool):Void {
		filter.applied = checked;
		// filter.callBack(checked);
		updateWithFilters();
	}

	private function updateWithFilters():Void {
		outputImage = sourceImage;
		for (filter in filters) {
			if (filter.applied) {
				filter.callBack(true);
			}
		}

		HighGUI.showImage("Output window", outputImage);
	}

	private function showFilterWindow(filters:Array<TestFilter>):Void {
		var title:String = "Filters";
		var height:Int = 20 + filters.length * 45;
		var panel:Mat = Core.createMat(height, 220, Core._8UC3);
		var checked:Array<Bool> = filters.map(function(f) return false);
		var redraw:Void->Void = function():Void {
			Core.rectangle(panel, Core.point(0, 0), Core.point(219, height - 1), Core.gray(40), -1);
			for (index in 0...filters.length) {
				var top:Int = 20 + index * 45;
				Core.rectangle(panel, Core.point(15, top), Core.point(39, top + 24), Core.gray(255), 1);
				if (checked[index]) {
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
					checked[index] = !checked[index];
					trace(filters[index].label + " checked: " + checked[index]);
					// filters[index].callBack(checked[index]);
					applyFilter(filters[index], checked[index]);
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
	public var callBack(default, null):Bool->Void;
	public var applied:Bool = false;

	public function new(label:String, callBack:Bool->Void) {
		this.label = label;
		this.callBack = callBack;
		this.applied = false;
	}
}

private class ImageFilters {
	public static function greyscale(apply:Bool, source:Mat):Mat {
		if (!apply)
			return source;

		var grey:Mat = Core.createMat(source.rows, source.cols, Core._8UC1);
		ImgProc.cvtColor(source, grey, ImgProc.BGR2GRAY);
		return grey;
	}
}
