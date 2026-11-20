package spilehx.cv.core;

import spilehx.build.NativeBinding;

abstract Font(NativeBinding) from NativeBinding to NativeBinding {
    @:allow(spilehx.cv)
    inline function new(x:Dynamic) this = x;

    @:allow(spilehx.cv)
    static inline function cvt(x:Dynamic):Null<Font> {
        return if (x == null) null else NativeBinding.generic(x);
    }
}
