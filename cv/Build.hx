package cv;

#if macro
import haxe.io.Path;
import haxe.macro.Compiler;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
#end

class Build {
#if macro
    public static function configure():Void {
        if (Context.defined("display") || Context.defined("no-output")) return;
        if (!Context.defined("cpp") || Sys.systemName() != "Linux"
            || Context.defined("windows") || Context.defined("mac")
            || Context.defined("android") || Context.defined("emscripten")
            || Context.defined("HXCPP_ARM64") || Context.defined("HXCPP_ARMV7")
            || Context.defined("HXCPP_M32") || Context.defined("cppia")) {
            Context.fatalError("spilehx-opencv supports Linux x86_64 C++ applications only.", Context.currentPos());
        }

        Compiler.define("HXCPP_M64");
        var libraryDir:String = Path.directory(Path.directory(Context.resolvePath("cv/Build.hx")));
        var runtimeDir:String = Path.join([libraryDir, "native", "Linux64"]);
        if (!FileSystem.exists(Path.join([runtimeDir, "opencv.ndll"]))) {
            Context.fatalError("OpenCV runtime missing. Prepare this checkout with bash package-haxelib.sh, or use a packaged release.", Context.currentPos());
        }

        var outputDir:String = FileSystem.absolutePath(Compiler.getOutput());
        Context.onAfterGenerate(function():Void {
            copyRuntime(runtimeDir, Path.join([outputDir, "native"]));
        });
    }

    static function copyRuntime(sourceDir:String, destinationDir:String):Void {
        FileSystem.createDirectory(destinationDir);
        for (name in FileSystem.readDirectory(sourceDir)) {
            var sourcePath:String = Path.join([sourceDir, name]);
            if (!FileSystem.isDirectory(sourcePath)) {
                File.copy(sourcePath, Path.join([destinationDir, name]));
            }
        }
    }
#end
}
