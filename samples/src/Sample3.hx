import spilehx.cv.Core;
import spilehx.cv.HighGUI;
import spilehx.cv.ImgProc;

class Sample3 {
    static function main() {
        haxe.Log.trace = function (m,?_) Sys.println(Std.string(m));

        var I = null;
        try I = HighGUI.loadImage("test.jpg", HighGUI.IMREAD_COLOR_BGR)
        catch (_:Dynamic) {
            trace("Couldn't load image");
            Sys.exit(1);
        }

        if (I == null) throw "Could not decode test.jpg";

        HighGUI.namedWindow("Input", HighGUI.WINDOW_AUTOSIZE);
        HighGUI.namedWindow("Output", HighGUI.WINDOW_AUTOSIZE);

        HighGUI.showImage("Input", I);

        // clone the I matrix to ensure we get one with same data type and number of channels.
        // Easier than extracting information and then using createMat
        var J = Core.cloneMat(I);

        // Create kernel matrix and assign values
        var kern = Core.createMat(3, 3, Core._32FC1);
        var i = 0;
        for (x in [0,-1,0,
                   -1,5,-1,
                   0,-1,0]) kern.set_float(i++, x);

        // Apply kernel to I, writing to matrix J
        ImgProc.filter2D(I, J, kern);

        HighGUI.showImage("Output", J);

        HighGUI.waitKey(0);
        HighGUI.destroyAllWindows();
        Sys.exit(0);
    }
}


