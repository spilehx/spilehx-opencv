package cv;

@:cppFileCode('extern "C" void hx_opencv_entry();')
class NativeLibrary {
    static var initialized:Bool = false;

    @:functionCode('hx_opencv_entry();')
    static function initialize():Void {}

    public static function load(library:String, primitive:String, argumentCount:Int):Dynamic {
        if (!initialized) {
            initialize();
            initialized = true;
        }
        return cpp.Lib.load(library, primitive, argumentCount);
    }
}
