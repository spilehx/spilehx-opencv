import spilehx.cv.Core;
import spilehx.cv.HighGUI;
import spilehx.cv.ImgProc;

class Sample2 {
    static function main() {
        haxe.Log.trace = function (m,?_) Sys.println(Std.string(m));

        var image = null;
        try image = HighGUI.loadImage("test.jpg", HighGUI.IMREAD_COLOR_BGR)
        catch (_:Dynamic) {
            trace("Couldn't load image");
            Sys.exit(1);
        }

        if (image == null) throw "Could not decode test.jpg";

        // Create matrix of same size, with 8bit single channel to store
        // greyscale version of image.
        var grey = Core.createMat(image.rows, image.cols, Core._8UC1);

        // Convert input image to greyscale and save to file.
        ImgProc.cvtColor(image, grey, ImgProc.BGR2GRAY);
        if (!HighGUI.saveImage("Happy Fish (Grey).jpg", grey)) throw "Could not save grayscale image";

        HighGUI.namedWindow("Colour", HighGUI.WINDOW_AUTOSIZE);
        HighGUI.namedWindow("Grey", HighGUI.WINDOW_AUTOSIZE);

        HighGUI.showImage("Colour", image);
        HighGUI.showImage("Grey", grey);

        HighGUI.waitKey(0);
        HighGUI.destroyAllWindows();
        Sys.exit(0);
    }
}

