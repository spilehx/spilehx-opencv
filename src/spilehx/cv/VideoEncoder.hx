package spilehx.cv;

import haxe.io.Bytes;
import haxe.io.BytesData;
import spilehx.cv.core.Mat;
import spilehx.internal.NativeBinding;
import spilehx.internal.NativeLibrary as Lib;

/** H.264 encoding in memory. The consuming app owns transport and viewer connections. */
class VideoEncoder extends NativeBinding {
    static inline function load(name:String, count:Int):Dynamic
        return Lib.load("opencv", "hx_cv_videoencoder_" + name, count);

    public var width(default, null):Int;
    public var height(default, null):Int;
    public var fps(default, null):Int;
    public var bitrate(default, null):Int;

    /** Fixed positive, even dimensions; FPS is 1–240 and bitrate is in kbit/s. */
    public function new(width:Int, height:Int, fps:Int=30, bitrate:Int=2000) {
        super(load("create", 4)(width, height, fps, bitrate));
        this.width = width;
        this.height = height;
        this.fps = fps;
        this.bitrate = bitrate;
    }

    /**
     * Copies 8-bit BGR/grayscale pixels; never waits for encoded output or a network consumer.
     * Frames above FPS or overflowing the raw input queue may be dropped; false means closed/failed.
     * Dimensions must match the encoder. Invalid frames throw an OpenCV error.
     */
    public function write(frame:Mat):Bool {
        return load("write", 2)(nativeObject, NativeBinding.native(frame));
    }

    /**
     * Nonblocking, destructive read of up to maxPackets (1–64) complete H.264 access units.
     * Use one consumer and fan packets out in your app. Returned bytes own their storage.
     * SPS/PPS are included with each IDR; timing is in seconds relative to pipeline running time.
     */
    public function pollPackets(maxPackets:Int=8):Array<EncodedVideoPacket> {
        var packets:Array<NativeVideoPacket> = load("pollPackets", 2)(nativeObject, maxPackets);
        return [for (packet in packets) {
            data: Bytes.ofData(packet.data),
            timestamp: packet.timestamp,
            decodeTimestamp: packet.decodeTimestamp,
            duration: packet.duration,
            keyFrame: packet.keyFrame
        }];
    }

    /** Asks the encoder for an IDR with codec headers, for example when a new viewer joins. */
    public function requestKeyFrame():Bool {
        return load("requestKeyFrame", 1)(nativeObject);
    }

    /** Drains asynchronous pipeline errors. A failed encoder must be released and recreated. */
    public function pollErrors():Array<String> {
        return load("pollErrors", 1)(nativeObject);
    }

    /** Idempotently stops this live encoder and discards any pending frames/packets. */
    public function release():Void {
        load("release", 1)(nativeObject);
    }
}

/** Annex B byte stream, access-unit aligned; each packet contains one encoded frame. */
typedef EncodedVideoPacket = {
    var data:Bytes;
    var timestamp:Float;
    var decodeTimestamp:Null<Float>;
    var duration:Null<Float>;
    var keyFrame:Bool;
}

private typedef NativeVideoPacket = {
    var data:BytesData;
    var timestamp:Float;
    var decodeTimestamp:Null<Float>;
    var duration:Null<Float>;
    var keyFrame:Bool;
}
