import spilehx.cv.Core;
import spilehx.cv.HighGUI;
import spilehx.cv.ImgProc;

class Sample2 {
    static function main() {
        haxe.Log.trace = function (m,?_) Sys.println(Std.string(m));

        var image = null;
        try image = HighGUI.loadImageM("test.jpg", HighGUI.LOAD_IMAGE_COLOR)
        catch (_:Dynamic) {
            trace("Couldn't load image");
            Sys.exit(1);
        }

        // Create matrix of same size, with 8bit single channel to store
        // greyscale version of image.
        var grey = Core.createMat(image.rows, image.cols, Core._8U);

        // Convert input image to greyscale and save to file.
        ImgProc.cvtColor(image, grey, ImgProc.BGR2GRAY);
        HighGUI.saveImage("Happy Fish (Grey).jpg", grey);

        HighGUI.namedWindow("Colour", HighGUI.WINDOW_AUTOSIZE);
        HighGUI.namedWindow("Grey", HighGUI.WINDOW_AUTOSIZE);

        HighGUI.showImage("Colour", image);
        HighGUI.showImage("Grey", grey);

        HighGUI.waitKey(0);
        Sys.exit(0);
    }
}

