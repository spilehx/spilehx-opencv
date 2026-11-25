package ;

import spilehx.cv.VideoCapture;
import spilehx.cv.core.Mat;

class Sandbox {
	static function main() {
		trace("Sandbox starting");
		new TestBenchApplication().run();
	}
}

private class TestBenchApplication {
	private static final CAMERA_ID:Int = 0;

	public function new() {}

	public function run():Void {
		captureFrames();
	}

	private function captureFrames():Void {
		var capture:VideoCapture = VideoCapture.fromCamera(CAMERA_ID);
		if (capture == null)
			throw "Could not open webcam " + CAMERA_ID;

		try {
			while (true) {
				var frame:Mat = capture.readFrame();
				if (frame == null) {
					trace("Webcam frame read failed; exiting");
					break;
				}

				processFrame(frame);
			}
		} catch (error:Dynamic) {
			capture.release();
			throw error;
		}

		capture.release();
	}

	private function processFrame(frame:Mat):Void {
		// Add headless frame processing here.
	}
}


