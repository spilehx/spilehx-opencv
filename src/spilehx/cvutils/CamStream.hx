package spilehx.cvutils;

import spilehx.cv.Core;
import spilehx.cv.VideoCapture;
import spilehx.cv.VideoEncoder;
import spilehx.cv.core.Mat;
import sys.thread.Mutex;

class CamStream {
	public var onFrame(null, default):Mat->Mat;
	private var cameraId:Int;

	public var baseImage(get, never):Mat;

	public var lastOutputImage(default, null):Mat;

	private var lastInputImage:Mat;
	private var baseFrame:Mat;
	private var outputImageMutex:Mutex = new Mutex();
	private var encoderMutex:Mutex = new Mutex();
	private var encoders:Array<VideoEncoder> = [];
	private var captureRunning:Bool = false;
	private var stopRequested:Bool = false;
	private var captureSessionId:Int = 0;

	public function new(cameraId:Int) {
		this.cameraId = cameraId;
	}

	public function startCapture():Void {
		encoderMutex.acquire();
		if (captureRunning) {
			encoderMutex.release();
			throw "Camera capture is already running";
		}
		captureRunning = true;
		stopRequested = false;
		captureSessionId++;
		outputImageMutex.acquire();
		lastInputImage = null;
		baseFrame = null;
		lastOutputImage = null;
		outputImageMutex.release();
		encoderMutex.release();
		var capture:VideoCapture = null;

		try {
			capture = VideoCapture.fromCamera(cameraId);
			if (capture == null)
				throw "Could not open webcam " + cameraId;

			while (shouldCapture()) {
				var frame:Mat = capture.readFrame();
				if (frame == null) {
					trace("Webcam frame read failed; exiting");
					break;
				}

				processFrame(frame);
			}
		} catch (error:Dynamic) {
			if (capture != null) capture.release();
			closeEncoders();
			throw error;
		}

		capture.release();
		closeEncoders();
	}

	/** Requests shutdown after the current camera read/frame processing returns. */
	public function stopCapture():Void {
		encoderMutex.acquire();
		stopRequested = true;
		encoderMutex.release();
	}

	private function shouldCapture():Bool {
		encoderMutex.acquire();
		var active:Bool = !stopRequested;
		encoderMutex.release();
		return active;
	}

	/**
	 * Creates and attaches an H.264 encoder after the first processed output is available.
	 * Poll encoded packets on one app thread and distribute them through your chosen transport.
	 */
	public function createVideoEncoder(fps:Int=30, bitrate:Int=2000):VideoEncoder {
		encoderMutex.acquire();
		if (!captureRunning || stopRequested) {
			encoderMutex.release();
			throw "Camera capture is not running";
		}
		var sessionId:Int = captureSessionId;
		outputImageMutex.acquire();
		var frame:Mat = lastOutputImage;
		outputImageMutex.release();
		encoderMutex.release();
		if (frame == null) throw "Wait for the first processed camera frame before creating a video encoder";
		var encoder:VideoEncoder = new VideoEncoder(frame.cols, frame.rows, fps, bitrate);
		encoderMutex.acquire();
		if (!captureRunning || stopRequested || captureSessionId != sessionId) {
			encoderMutex.release();
			encoder.release();
			throw "Camera capture stopped or restarted while creating the video encoder";
		}
		encoders.push(encoder);
		encoderMutex.release();
		return encoder;
	}

	/** Detaches and releases an encoder, discarding pending output. */
	public function removeVideoEncoder(encoder:VideoEncoder):Void {
		encoderMutex.acquire();
		encoders.remove(encoder);
		encoderMutex.release();
		encoder.release();
	}

	private function closeEncoders():Void {
		encoderMutex.acquire();
		var closing:Array<VideoEncoder> = encoders;
		encoders = [];
		captureRunning = false;
		encoderMutex.release();
		for (encoder in closing) encoder.release();
	}

	private function processFrame(frame:Mat):Void {
		// Keep camera input independent of filters that modify their Mat in place.
		var input:Mat = Core.cloneMat(frame);
		outputImageMutex.acquire();
		lastInputImage = input;
		outputImageMutex.release();

		if (onFrame != null) {
			frame = onFrame(frame);
		}
		if (frame == null) throw "Camera frame processing returned null";

		outputImageMutex.acquire();
		lastOutputImage = frame;
		outputImageMutex.release();

		encoderMutex.acquire();
		var outputs:Array<VideoEncoder> = encoders.copy();
		encoderMutex.release();
		for (encoder in outputs) encoder.write(frame);
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

	private function get_baseImage():Mat {
		outputImageMutex.acquire();
		var frame:Mat = baseFrame;
		outputImageMutex.release();
		return frame;
	}

	/** Captures an independent, unfiltered background; null until camera input is available. */
	public function captureBase():Void {
		outputImageMutex.acquire();
		try {
			baseFrame = lastInputImage == null ? null : Core.cloneMat(lastInputImage);
		} catch (error:Dynamic) {
			outputImageMutex.release();
			throw error;
		}
		outputImageMutex.release();
	}
}
