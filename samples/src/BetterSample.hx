package;

import spilehx.cv.Core;
import spilehx.cv.Features2D;
import spilehx.cv.HighGUI;
import spilehx.cv.ImgProc;
import spilehx.cv.core.Mat;
import spilehx.cv.features2d.KeyPoint;
import haxe.io.Path;
import sys.FileSystem;

class BetterSample {
	static function main():Void {
		haxe.Log.trace = function(message:Dynamic, ?position:haxe.PosInfos):Void {
			Sys.println(Std.string(message));
		};

		#if !cpp
		#error "BetterSample requires the C++ target"
		#end

		trace("BetterSample: spilehx-opencv C++ showcase");
		trace("Working directory: " + Sys.getCwd());
		trace("DISPLAY=" + Sys.getEnv("DISPLAY") + "; QT_QPA_PLATFORM=" + Sys.getEnv("QT_QPA_PLATFORM"));

		try {
			run();
		} catch (error:Dynamic) {
			Sys.stderr().writeString("BetterSample failed: " + Std.string(error) + "\n");
			Sys.exit(1);
		}
	}

	static function run():Void {
		var imagePath:String = Path.join([Sys.getCwd(), "test.jpg"]);
		trace("Loading image: " + imagePath);
		var source:Mat = HighGUI.loadImageM(imagePath, HighGUI.LOAD_IMAGE_COLOR);
		if (source == null) throw "Could not decode image: " + imagePath;
		trace("Source: " + source.cols + "x" + source.rows + "; element type=" + Core.getElemType(source));

		trace("Converting BGR to grayscale");
		var grey:Mat = Core.createMat(source.rows, source.cols, Core._8UC1);
		ImgProc.cvtColor(source, grey, ImgProc.BGR2GRAY);

		trace("Applying a 9x9 Gaussian blur");
		var blurred:Mat = Core.createMat(source.rows, source.cols, Core._8UC1);
		ImgProc.gaussianBlur(grey, blurred, Core.size(9, 9), 2.0);

		trace("Applying binary threshold at 110");
		var binary:Mat = Core.createMat(source.rows, source.cols, Core._8UC1);
		ImgProc.threshold(blurred, binary, 110, 255, ImgProc.THRESH_BINARY);

		trace("Sharpening with a custom float kernel");
		var sharpened:Mat = Core.cloneMat(source);
		var kernel:Mat = Core.createMat(3, 3, Core._32FC1);
		var weights:Array<Float> = [0, -1, 0, -1, 5, -1, 0, -1, 0];
		for (index in 0...weights.length) kernel.set_float(index, weights[index]);
		ImgProc.filter2D(source, sharpened, kernel);

		trace("Detecting up to 80 corners with GFFT");
		var detector = Features2D.gfft(80, 0.02, 12);
		var keypoints:Array<KeyPoint> = [];
		detector.detect(grey, null, keypoints);
		var corners:Mat = Core.cloneMat(source);
		for (keypoint in keypoints) {
			var point = keypoint.pt;
			Core.circle(corners, Core.point(Math.round(point.x), Math.round(point.y)), 5, Core.rgb(255, 70, 70), 2);
		}
		trace("Detected " + keypoints.length + " corners");

		var outputDirectory:String = Path.join([Sys.getCwd(), "better-sample-output"]);
		FileSystem.createDirectory(outputDirectory);
		var views:Array<{title:String, filename:String, image:Mat}> = [
			{title: "1 - Colour", filename: "01-colour.png", image: source},
			{title: "2 - Grayscale", filename: "02-grayscale.png", image: grey},
			{title: "3 - Gaussian blur", filename: "03-blur.png", image: blurred},
			{title: "4 - Binary threshold", filename: "04-threshold.png", image: binary},
			{title: "5 - Sharpened", filename: "05-sharpened.png", image: sharpened},
			{title: "6 - Detected corners", filename: "06-corners.png", image: corners}
		];

		for (index in 0...views.length) {
			var view = views[index];
			var outputPath:String = Path.join([outputDirectory, view.filename]);
			trace("Saving " + outputPath);
			if (HighGUI.saveImage(outputPath, view.image) == 0) throw "Could not save " + outputPath;

			trace("Creating window: " + view.title);
			HighGUI.namedWindow(view.title, HighGUI.WINDOW_NORMAL | HighGUI.GUI_NORMAL);
			trace("Displaying image: " + view.title);
			HighGUI.showImage(view.title, view.image);
			HighGUI.resizeWindow(view.title, 320, 240);
			HighGUI.moveWindow(view.title, 40 + (index % 3) * 360, 60 + Std.int(index / 3) * 330);
			trace("Window configured: " + view.title);
		}

		trace("Processing GUI events; press any key in an image window to exit");
		trace("Saved results: " + outputDirectory + " (same filenames are replaced on each run)");
		HighGUI.waitKey(0);
		HighGUI.destroyAllWindows();
		trace("Windows closed; finished");
	}

}
