package cv;

import haxe.io.Path;

class NativeLibrary {
    public static function load(library:String, primitive:String, argumentCount:Int):Dynamic {
        var libraryPath:String = Path.join([Path.directory(Sys.programPath()), "native", library]);
        return cpp.Lib.load(libraryPath, primitive, argumentCount);
    }
}
