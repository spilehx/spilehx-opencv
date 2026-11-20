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
	public function new() {}

	public function run() {
		trace("TestBenchApplication running");
		var image:Mat = getImageInput("test.jpg");


		showImageWindow("Input window", image);

		showFilterWindow();

		showImageWindow("Greyscale window", applyGreyscale(image));

		HighGUI.waitKey(0);
		trace("waitKey(0) returned; exiting");
		HighGUI.destroyAllWindows();
		Sys.exit(0);
	}


	private function showFilterWindow(){

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

	private function applyGreyscale(source:Mat):Mat {
		var grey:Mat = Core.createMat(source.rows, source.cols, Core._8UC1);
		ImgProc.cvtColor(source, grey, ImgProc.BGR2GRAY);

		return grey;
	}
}



