package spilehx.cvutils;

import haxe.io.Bytes;
import spilehx.cv.ImgCodecs;
import spilehx.cv.core.Mat;

class MatHelper {
    /**
     * Encodes an image as independently owned JPEG bytes without file or GUI access.
     * Quality must be between 0 and 100. Encoding failures throw an OpenCV error.
     */
    public static function matToJpg(mat:Mat, quality:Int=100):Bytes {
        return ImgCodecs.encodeJpeg(mat, quality);
    }
}
