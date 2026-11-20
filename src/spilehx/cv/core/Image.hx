package spilehx.cv.core;

import spilehx.internal.NativeBinding;
import spilehx.cv.core.CVBuffer;
import spilehx.cv.core.Size;

/**
 * Native OpenCV image with read-only layout properties and mutable pixel data.
 * Use `Core.createImage` to allocate an image or `HighGUI.loadImage` to load one.
 */
class Image extends NativeBinding {
    @:allow(spilehx.cv)
    function new(nativeObject:Dynamic) {
        super(nativeObject);
    }
    @:allow(spilehx.cv)
    static inline function cvt(x:Dynamic):Null<Image> {
        return if (x == null) null else new Image(x);
    }

    /**
     * Buffer view of the pixel storage without copying. Keep this image and any
     * owner of its storage alive while using the view.
     */
    public var raw(get, never):CVBuffer;
    inline function get_raw():CVBuffer return Core.load("Image_get_raw", 1)(nativeObject);

    public var nChannels(get,never):Int;
    /**
     * Pixel component depth encoded with the `Core.IPL_DEPTH_*` constants.
     */
    public var depth    (get,never):Int;
    /**
     * Storage order: 0 for interleaved channels, 1 for separate channel planes.
     */
    public var dataOrder(get,never):Int;
    /**
     * Image origin: 0 for top-left, 1 for bottom-left.
     */
    public var origin   (get,never):Int;
    public var width    (get,never):Int;
    public var height   (get,never):Int;
    /**
     * Size of the image data in bytes, including row padding.
     */
    public var imageSize(get,never):Int;
    /**
     * Distance in bytes between consecutive image rows, including padding.
     */
    public var widthStep(get,never):Int;

    inline function get_nChannels():Int { return Core.load("Image_get_nChannels", 1)(this.nativeObject); }
    inline function get_depth    ():Int { return Core.load("Image_get_depth",     1)(this.nativeObject); }
    inline function get_dataOrder():Int { return Core.load("Image_get_dataOrder", 1)(this.nativeObject); }
    inline function get_origin   ():Int { return Core.load("Image_get_origin",    1)(this.nativeObject); }
    inline function get_width    ():Int { return Core.load("Image_get_width",     1)(this.nativeObject); }
    inline function get_height   ():Int { return Core.load("Image_get_height",    1)(this.nativeObject); }
    inline function get_imageSize():Int { return Core.load("Image_get_imageSize", 1)(this.nativeObject); }
    inline function get_widthStep():Int { return Core.load("Image_get_widthStep", 1)(this.nativeObject); }

    public inline function toString() {
        return '{Image (${width}x$height) : nChannels=$nChannels depth=$depth dataOrder=$dataOrder origin=$origin imageSize=$imageSize widthStep=$widthStep}';
    }
}
