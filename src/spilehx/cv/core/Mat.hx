package spilehx.cv.core;

import spilehx.internal.NativeBinding;
import spilehx.cv.core.CVBuffer;

/**
 * Native OpenCV matrix, allocated with `Core.createMat` or `Core.createMatHeader`.
 * Typed accessors index the underlying storage directly and do not convert depth
 * or account for row padding. Use the accessor matching the matrix depth and keep
 * indices within the allocated storage.
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

    /**
     * Buffer view of the matrix storage without copying. Keep this matrix and any
     * owner of its storage alive while using the view.
     */
    public var raw(get, never):CVBuffer;
    inline function get_raw():CVBuffer return Core.load("Mat_get_raw", 1)(nativeObject);

    /**
     * Reads an unsigned 8-bit component.
     * @param i Zero-based component offset from the start of the data.
     * @return The stored component.
     */
    public inline function get_uchar(i:Int):Int return
        Core.load("mat_uchar_get",2)(this.nativeObject, i);
    /**
     * Reads a signed 16-bit component.
     * @param i Zero-based component offset from the start of the data.
     * @return The stored component.
     */
    public inline function get_short(i:Int):Int return
        Core.load("mat_short_get",2)(this.nativeObject, i);
    /**
     * Reads a signed 32-bit component.
     * @param i Zero-based component offset from the start of the data.
     * @return The stored component.
     */
    public inline function get_int(i:Int):Int return
        Core.load("mat_int_get", 2)(this.nativeObject, i);
    /**
     * Reads a single-precision component.
     * @param i Zero-based component offset from the start of the data.
     * @return The stored component as a Haxe Float.
     */
    public inline function get_float(i:Int):Float return
        Core.load("mat_float_get", 2)(this.nativeObject, i);
    /**
     * Reads a double-precision component.
     * @param i Zero-based component offset from the start of the data.
     * @return The stored component.
     */
    public inline function get_double(i:Int):Float return
        Core.load("mat_double_get", 2)(this.nativeObject, i);

    /**
     * Writes an unsigned 8-bit component without saturation.
     * @param i Zero-based component offset from the start of the data.
     * @param v Value to store.
     * @return The stored value after conversion to unsigned 8-bit storage.
     */
    public inline function set_uchar(i:Int, v:Int):Int return
        Core.load("mat_uchar_set",3)(this.nativeObject, i, v);
    /**
     * Writes a signed 16-bit component without saturation.
     * @param i Zero-based component offset from the start of the data.
     * @param v Value to store.
     * @return The stored value after conversion to signed 16-bit storage.
     */
    public inline function set_short(i:Int, v:Int):Int return
        Core.load("mat_short_set",3)(this.nativeObject, i, v);
    /**
     * Writes a signed 32-bit component.
     * @param i Zero-based component offset from the start of the data.
     * @param v Value to store.
     * @return The assigned value.
     */
    public inline function set_int(i:Int, v:Int):Int return
        Core.load("mat_int_set", 3)(this.nativeObject, i, v);
    /**
     * Writes a single-precision component.
     * @param i Zero-based component offset from the start of the data.
     * @param v Value to store.
     * @return The stored value after rounding to single precision.
     */
    public inline function set_float(i:Int, v:Float):Float return
        Core.load("mat_float_set", 3)(this.nativeObject, i, v);
    /**
     * Writes a double-precision component.
     * @param i Zero-based component offset from the start of the data.
     * @param v Value to store.
     * @return The assigned value.
     */
    public inline function set_double(i:Int, v:Float):Float return
        Core.load("mat_double_set", 3)(this.nativeObject, i, v);

    /**
     * Native matrix type flags encoding depth, channel count, and layout flags.
     */
    public var type(get,never):Int;
    /**
     * Distance in bytes between consecutive rows, including padding.
     */
    public var step(get,never):Int;
    public var rows(get,never):Int;
    public var cols(get,never):Int;

    inline function get_type():Int { return Core.load("Mat_get_type", 1)(this.nativeObject); }
    inline function get_step():Int { return Core.load("Mat_get_step", 1)(this.nativeObject); }
    inline function get_rows():Int { return Core.load("Mat_get_rows", 1)(this.nativeObject); }
    inline function get_cols():Int { return Core.load("Mat_get_cols", 1)(this.nativeObject); }



    public inline function toString() {
        return '{Mat (${rows}x$cols) : type=$type step=$step}';
    }
}
