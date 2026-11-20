package spilehx.cv.core;

import spilehx.internal.NativeBinding;

/**
 * Native text drawing font created by `Core.createFont` and used by `Core.putText`.
 */
abstract Font(NativeBinding) from NativeBinding to NativeBinding {
    @:allow(spilehx.cv)
    inline function new(x:Dynamic) this = x;

    @:allow(spilehx.cv)
    static inline function cvt(x:Dynamic):Null<Font> {
        return if (x == null) null else NativeBinding.generic(x);
    }
}
