package spilehx.build;

#if macro
import haxe.io.Path;
import haxe.macro.Compiler;
import haxe.macro.Context;
import sys.FileSystem;
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
        var libraryDir:String = Path.normalize(Path.join([Path.directory(Context.resolvePath("spilehx/build/Build.hx")), "../../.."]));
        var runtimeDir:String = Path.join([libraryDir, "native", "Linux64"]);
        var buildFile:String = Path.join([runtimeDir, "Build.xml"]);
        if (!FileSystem.exists(buildFile)) {
            Context.fatalError("OpenCV static libraries missing. Prepare this checkout with bash package-haxelib.sh, or use a packaged release.", Context.currentPos());
        }

        var buildXml:String = '<include name="' + StringTools.htmlEscape(buildFile, true) + '"/>';
        Compiler.addMetadata("@:buildXml(" + haxe.Json.stringify(buildXml) + ")", "spilehx.build.NativeLibrary");
    }
#end
}
