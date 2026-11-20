package spilehx.cv.core;

import spilehx.internal.NativeBinding;

/**
 * Owned OpenCV matrix header and reference-counted pixel storage.
 * Allocate with `Core.createMat` and copy with `Core.cloneMat`.
 */
class Mat extends NativeBinding {
    @:allow(spilehx.cv)
    function new(nativeObject:Dynamic) {
        super(nativeObject);
    }

    @:allow(spilehx.cv)
    static inline function cvt(x:Dynamic):Null<Mat> {
        return if (x == null) null else new Mat(x);
    }

    /** Matrix depth and channel type, without layout flags. */
    public var type(get, never):Int;
    /** Distance in bytes between consecutive rows, including padding. */
    public var step(get, never):Int;
    public var depth(get, never):Int;
    public var channels(get, never):Int;
    public var rows(get, never):Int;
    public var cols(get, never):Int;

    inline function get_type():Int return Core.load("Mat_get_type", 1)(nativeObject);
    inline function get_step():Int return Core.load("Mat_get_step", 1)(nativeObject);
    inline function get_depth():Int return Core.load("Mat_get_depth", 1)(nativeObject);
    inline function get_channels():Int return Core.load("Mat_get_channels", 1)(nativeObject);
    inline function get_rows():Int return Core.load("Mat_get_rows", 1)(nativeObject);
    inline function get_cols():Int return Core.load("Mat_get_cols", 1)(nativeObject);

    /** Typed accessors use logical component indices, skip row padding and check depth/bounds. */
    public inline function get_uchar(i:Int):Int
        return Core.load("mat_uchar_get", 2)(nativeObject, i);
    public inline function set_uchar(i:Int, v:Int):Int
        return Core.load("mat_uchar_set", 3)(nativeObject, i, v);
    public inline function get_char(i:Int):Int
        return Core.load("mat_char_get", 2)(nativeObject, i);
    public inline function set_char(i:Int, v:Int):Int
        return Core.load("mat_char_set", 3)(nativeObject, i, v);
    public inline function get_ushort(i:Int):Int
        return Core.load("mat_ushort_get", 2)(nativeObject, i);
    public inline function set_ushort(i:Int, v:Int):Int
        return Core.load("mat_ushort_set", 3)(nativeObject, i, v);
    public inline function get_short(i:Int):Int
        return Core.load("mat_short_get", 2)(nativeObject, i);
    public inline function set_short(i:Int, v:Int):Int
        return Core.load("mat_short_set", 3)(nativeObject, i, v);
    public inline function get_int(i:Int):Int
        return Core.load("mat_int_get", 2)(nativeObject, i);
    public inline function set_int(i:Int, v:Int):Int
        return Core.load("mat_int_set", 3)(nativeObject, i, v);
    public inline function get_float(i:Int):Float
        return Core.load("mat_float_get", 2)(nativeObject, i);
    public inline function set_float(i:Int, v:Float):Float
        return Core.load("mat_float_set", 3)(nativeObject, i, v);
    public inline function get_double(i:Int):Float
        return Core.load("mat_double_get", 2)(nativeObject, i);
    public inline function set_double(i:Int, v:Float):Float
        return Core.load("mat_double_set", 3)(nativeObject, i, v);

    public inline function toString():String {
        return '{Mat (${rows}x$cols) : type=$type step=$step}';
    }
}
