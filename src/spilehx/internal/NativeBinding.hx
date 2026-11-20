package spilehx.internal;

@:noCompletion
@:noDoc
class NativeBinding {
    @:allow(spilehx.cv)
    var nativeObject:Dynamic;

    @:allow(spilehx.cv)
    function new(x:Dynamic) {
        nativeObject = x;
    }

    @:allow(spilehx.cv)
    inline static function generic(x:Null<Dynamic>):Null<NativeBinding> {
        return if (x == null) null else new NativeBinding(x);
    }

    @:allow(spilehx.cv)
    static inline function native(object:Null<NativeBinding>):Null<Dynamic> {
        return if (object == null) null else object.nativeObject;
    }

    @:allow(spilehx.cv)
    static inline function mapNative<T:NativeBinding>(objects:Null<Array<Null<T>>>):Null<Array<Null<Dynamic>>> {
        if (objects == null) return null;
        else {
            var ret = [];
            for (o in objects) ret.push(native(o));
            return ret;
        }
    }
}
