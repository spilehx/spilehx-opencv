package spilehx.cv.highgui;

import spilehx.internal.NativeBinding;

/**
 * Native video capture handle opened by `HighGUI.captureFromFile`.
 * Keep it alive while using frames borrowed from the capture.
 */
abstract Capture(NativeBinding) from NativeBinding to NativeBinding {
    @:allow(spilehx.cv)
    inline function new(x:Dynamic) this = x;

    @:allow(spilehx.cv)
    static inline function cvt(x:Dynamic):Null<Capture> {
        return if (x == null) null else NativeBinding.generic(x);
    }
}
