package spilehx.cv.core;

import spilehx.internal.NativeBinding;

/**
 * Mutable stopping criteria for iterative algorithms, created by `Core.termCriteria`.
 */
class TermCriteria extends NativeBinding {
    @:allow(spilehx.cv)
    function new(nativeObject:Dynamic) {
        super(nativeObject);
    }
    @:allow(spilehx.cv)
    static inline function cvt(type:Dynamic):Null<TermCriteria> {
        return if (type == null) null else new TermCriteria(type);
    }



    /**
     * Bitwise combination of `Core.TERMCRIT_ITER` and `Core.TERMCRIT_EPS`.
     */
    public var type    (get,set):Int;
    /**
     * Iteration limit used when `Core.TERMCRIT_ITER` is enabled.
     */
    public var maxCount(get,set):Int;
    /**
     * Convergence tolerance used when `Core.TERMCRIT_EPS` is enabled.
     */
    public var epsilon (get,set):Float;

    inline function get_type    () { return Core.load("TermCriteria_get_type",     1)(nativeObject); }
    inline function get_maxCount() { return Core.load("TermCriteria_get_maxCount", 1)(nativeObject); }
    inline function get_epsilon () { return Core.load("TermCriteria_get_epsilon",  1)(nativeObject); }

    inline function set_type    (type:Int)      { return Core.load("TermCriteria_set_type",     2)(nativeObject, type); }
    inline function set_maxCount(maxCount:Int)  { return Core.load("TermCriteria_set_maxCount", 2)(nativeObject, maxCount); }
    inline function set_epsilon (epsilon:Float) { return Core.load("TermCriteria_set_epsilon",  2)(nativeObject, epsilon); }



    public inline function toString() {
        return '{TermCriteria type=$type maxCount=$maxCount}';
    }
}
