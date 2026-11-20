package spilehx.cv.core;

import spilehx.internal.NativeBinding;

/**
 * Mutable four-component scalar, created by `Core.scalar` or its color helpers.
 * Components are accessed with zero-based indices from 0 through 3.
 */
abstract Scalar(Scalar_) from Scalar_ to Scalar_ {
    @:allow(spilehx.cv)
    inline function new(x:Dynamic) {
        this = new Scalar_(x);
    }
    @:allow(spilehx.cv)
    inline static function cvt(x:Dynamic) {
        return if (x == null) null else new Scalar_(x);
    }


    /**
     * Reads a component using method or array access syntax.
     * @param i Component index from 0 through 3.
     * @return The component value.
     */
    @:arrayAccess public inline function get(i:Int):Float {
        return Core.load("Scalar_get_i", 2)(this.nativeObject, i);
    }
    /**
     * Writes a component using method or array access syntax.
     * @param i Component index from 0 through 3.
     * @param x New component value.
     * @return The assigned value.
     */
    @:arrayAccess public inline function set(i:Int, x:Float):Float {
        return Core.load("Scalar_set_i", 3)(this.nativeObject, i, x);
    }


    public inline function toString() {
        return '{Scalar [${get(0)},${get(1)},${get(2)},${get(3)}]}';
    }
}

/**
 * Drawing color represented as a scalar in BGR order. Use `Core.rgb` to supply
 * components in RGB order.
 */
typedef RGB = Scalar;

class Scalar_ extends NativeBinding {
    public function new(x:Dynamic) {
        super(x);
    }
}
