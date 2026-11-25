package spilehx.cvutils;

import haxe.io.Bytes;
import spilehx.cv.VideoCapture;
import spilehx.cv.core.Mat;
import sys.thread.Mutex;

class CamStream {
	public var onFrame(null, default):Mat->Mat;

	private var cameraId:Int;

	public var lastOutputImage(default, null):Mat;

	private var outputImageMutex:Mutex = new Mutex();

	public function new(cameraId:Int) {
		this.cameraId = cameraId;
	}

	public function startCapture():Void {
		var capture:VideoCapture = VideoCapture.fromCamera(cameraId);
		if (capture == null)
			throw "Could not open webcam " + cameraId;

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
		if (onFrame != null) {
			frame = onFrame(frame);
		}

		outputImageMutex.acquire();
		lastOutputImage = frame;
		outputImageMutex.release();
	}

	public function getLastOutputToImage():haxe.io.Bytes {
		outputImageMutex.acquire();
		var frame:Mat = lastOutputImage;
		outputImageMutex.release();
		if (frame == null) {
			return null;
		}
		return spilehx.cvutils.MatHelper.matToJpg(frame);
	}
}
