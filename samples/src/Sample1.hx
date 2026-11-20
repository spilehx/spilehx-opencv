import spilehx.cv.HighGUI;

class Sample1 {
    static function main() {
        haxe.Log.trace = function (m,?_) Sys.println(Std.string(m));

        trace("Sample1 starting (C++ target)");
        trace("Working directory: " + Sys.getCwd());
        trace("Image path: " + haxe.io.Path.join([Sys.getCwd(), "test.jpg"]));
        trace("DISPLAY=" + Sys.getEnv("DISPLAY") + "; WAYLAND_DISPLAY=" + Sys.getEnv("WAYLAND_DISPLAY")
            + "; QT_QPA_PLATFORM=" + Sys.getEnv("QT_QPA_PLATFORM"));

        var image = null;
        trace("Loading test.jpg");
        try image = HighGUI.loadImage("test.jpg", HighGUI.IMREAD_COLOR_BGR)
        catch (error:Dynamic) {
            trace("Image loading failed: " + Std.string(error));
            Sys.exit(1);
        }

        if (image == null) {
            trace("Image loading returned null; check the image path and file contents");
            Sys.exit(1);
        }
        trace("Image loaded: " + image.cols + "x" + image.rows + "; type=" + image.type);

        // Create window and display image.
        trace("Calling namedWindow()");
        HighGUI.namedWindow("Display window", HighGUI.WINDOW_AUTOSIZE);
        trace("Calling showImage()");
        HighGUI.showImage("Display window", image);
        trace("showImage() returned");

        // Wait for key stroke before exiting.
        trace("Calling waitKey(0); waiting for a key press in the image window");
        HighGUI.waitKey(0);
        trace("waitKey(0) returned; exiting");
        HighGUI.destroyAllWindows();
        Sys.exit(0);
    }
}
