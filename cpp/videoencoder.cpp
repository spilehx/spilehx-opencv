#include "videoencoder.h"
#include "core.h"
#include <opencv2/imgproc.hpp>
#include <gst/app/gstappsrc.h>
#include <gst/app/gstappsink.h>
#include <gst/video/video.h>
#include <gst/video/video-event.h>
#include <cstring>
#include <limits>
#include <memory>
#include <mutex>
#include <string>
#include <utility>
#include <vector>

namespace {
struct Packet {
    std::vector<unsigned char> data;
    GstClockTime timestamp;
    GstClockTime decodeTimestamp;
    GstClockTime duration;
    bool keyFrame;
};

struct Encoder {
    std::mutex mutex;
    GstElement* pipeline = nullptr;
    GstElement* source = nullptr;
    GstElement* sink = nullptr;
    GstBus* bus = nullptr;
    GstVideoInfo videoInfo;
    int fps = 0;
    gint64 lastFrameTime = 0;
    bool closed = false;
    bool failed = false;
    std::vector<std::string> errors;

    ~Encoder() { close(); }

    void close() {
        std::lock_guard<std::mutex> lock(mutex);
        if (closed) return;
        closed = true;
        if (pipeline) gst_element_set_state(pipeline, GST_STATE_NULL);
        if (bus) gst_object_unref(bus);
        if (source) gst_object_unref(source);
        if (sink) gst_object_unref(sink);
        if (pipeline) gst_object_unref(pipeline);
        bus = nullptr;
        source = sink = pipeline = nullptr;
    }

    void open(int width, int height, int frameRate, int bitrate) {
        CV_Assert(width > 0 && height > 0 && width % 2 == 0 && height % 2 == 0);
        CV_Assert(frameRate > 0 && frameRate <= 240 && bitrate > 0);
        fps = frameRate;
        static std::once_flag initialized;
        std::call_once(initialized, [] {
            GError* error = nullptr;
            if (!gst_init_check(nullptr, nullptr, &error)) {
                std::string message = error ? error->message : "Could not initialize GStreamer";
                if (error) g_error_free(error);
                CV_Error(cv::Error::StsError, message);
            }
        });

        GError* error = nullptr;
        pipeline = gst_parse_launch(
            "appsrc name=frames is-live=true format=time do-timestamp=true block=false "
            "max-buffers=2 max-bytes=0 max-time=0 leaky-type=downstream ! "
            "videoconvert ! video/x-raw,format=I420 ! "
            "x264enc name=encoder tune=zerolatency speed-preset=ultrafast bframes=0 byte-stream=true ! "
            "video/x-h264,profile=constrained-baseline ! h264parse config-interval=-1 ! "
            "video/x-h264,stream-format=byte-stream,alignment=au ! "
            "appsink name=packets max-buffers=8 drop=false sync=false enable-last-sample=false wait-on-eos=false",
            &error);
        if (error) {
            std::string message = error->message;
            g_error_free(error);
            CV_Error(cv::Error::StsError, "Could not create H.264 pipeline: " + message);
        }
        CV_Assert(pipeline);
        source = gst_bin_get_by_name(GST_BIN(pipeline), "frames");
        sink = gst_bin_get_by_name(GST_BIN(pipeline), "packets");
        GstElement* encoder = gst_bin_get_by_name(GST_BIN(pipeline), "encoder");
        CV_Assert(source && sink && encoder);
        g_object_set(encoder, "bitrate", static_cast<guint>(bitrate), "key-int-max", static_cast<guint>(fps), nullptr);
        gst_object_unref(encoder);

        gst_video_info_init(&videoInfo);
        CV_Assert(gst_video_info_set_format(&videoInfo, GST_VIDEO_FORMAT_BGR, width, height));
        videoInfo.fps_n = fps;
        videoInfo.fps_d = 1;
        GstCaps* caps = gst_video_info_to_caps(&videoInfo);
        gst_app_src_set_caps(GST_APP_SRC(source), caps);
        gst_caps_unref(caps);
        bus = gst_element_get_bus(pipeline);
        if (gst_element_set_state(pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_FAILURE)
            CV_Error(cv::Error::StsError, "Could not start H.264 encoding pipeline");
    }

    // Caller holds mutex. Bus polling avoids callbacks from GStreamer into Haxe.
    void collectErrors() {
        if (!bus) return;
        while (GstMessage* message = gst_bus_pop(bus)) {
            if (GST_MESSAGE_TYPE(message) == GST_MESSAGE_ERROR) {
                GError* error = nullptr;
                gst_message_parse_error(message, &error, nullptr);
                errors.push_back(error ? error->message : "H.264 encoding pipeline failed");
                if (error) g_error_free(error);
                failed = true;
            } else if (GST_MESSAGE_TYPE(message) == GST_MESSAGE_EOS) {
                errors.push_back("H.264 encoding pipeline ended unexpectedly");
                failed = true;
            }
            gst_message_unref(message);
        }
    }

    bool write(const cv::Mat& frame) {
        std::lock_guard<std::mutex> lock(mutex);
        collectErrors();
        if (closed || failed) return false;
        CV_Assert(frame.cols == videoInfo.width && frame.rows == videoInfo.height);
        CV_Assert(frame.type() == CV_8UC3 || frame.type() == CV_8UC1);
        gint64 now = g_get_monotonic_time();
        if (lastFrameTime && now - lastFrameTime < G_USEC_PER_SEC / fps) return true;
        cv::Mat bgr;
        if (frame.channels() == 1) cv::cvtColor(frame, bgr, cv::COLOR_GRAY2BGR);
        else bgr = frame;
        GstBuffer* buffer = gst_buffer_new_allocate(nullptr, videoInfo.size, nullptr);
        CV_Assert(buffer);
        GstMapInfo mapped;
        if (!gst_buffer_map(buffer, &mapped, GST_MAP_WRITE)) {
            gst_buffer_unref(buffer);
            CV_Error(cv::Error::StsError, "Could not map encoder frame buffer");
        }
        std::memset(mapped.data, 0, mapped.size);
        for (int row = 0; row < bgr.rows; ++row)
            std::memcpy(mapped.data + static_cast<size_t>(row) * videoInfo.stride[0], bgr.ptr(row), static_cast<size_t>(bgr.cols) * 3);
        gst_buffer_unmap(buffer, &mapped);
        GST_BUFFER_DURATION(buffer) = GST_SECOND / fps;
        GstFlowReturn result = gst_app_src_push_buffer(GST_APP_SRC(source), buffer);
        lastFrameTime = now;
        if (result != GST_FLOW_OK) {
            failed = true;
            errors.push_back("Could not queue encoder frame: " + std::string(gst_flow_get_name(result)));
        }
        return result == GST_FLOW_OK;
    }

    std::vector<Packet> pollPackets(int maxPackets) {
        CV_Assert(maxPackets > 0 && maxPackets <= 64);
        std::lock_guard<std::mutex> lock(mutex);
        collectErrors();
        std::vector<Packet> packets;
        if (closed) return packets;
        while (static_cast<int>(packets.size()) < maxPackets) {
            std::unique_ptr<GstSample, decltype(&gst_sample_unref)> sample(
                gst_app_sink_try_pull_sample(GST_APP_SINK(sink), 0), gst_sample_unref);
            if (!sample) break;
            GstBuffer* buffer = gst_sample_get_buffer(sample.get());
            const GstSegment* segment = gst_sample_get_segment(sample.get());
            CV_Assert(buffer && segment && segment->format == GST_FORMAT_TIME);
            Packet packet;
            packet.timestamp = gst_segment_to_running_time(segment, GST_FORMAT_TIME, GST_BUFFER_PTS(buffer));
            packet.decodeTimestamp = gst_segment_to_running_time(segment, GST_FORMAT_TIME, GST_BUFFER_DTS(buffer));
            packet.duration = GST_BUFFER_DURATION(buffer);
            packet.keyFrame = !GST_BUFFER_FLAG_IS_SET(buffer, GST_BUFFER_FLAG_DELTA_UNIT);
            CV_Assert(GST_CLOCK_TIME_IS_VALID(packet.timestamp));
            gsize length = gst_buffer_get_size(buffer);
            CV_Assert(length <= static_cast<gsize>(std::numeric_limits<int>::max()));
            packet.data.resize(length);
            CV_Assert(gst_buffer_extract(buffer, 0, packet.data.data(), length) == length);
            packets.push_back(std::move(packet));
        }
        return packets;
    }
};
}

DEFINE_KIND(k_VideoEncoder);

static Encoder& encoder(value handle) {
    val_check_kind(handle, k_VideoEncoder);
    return *static_cast<Encoder*>(val_data(handle));
}

static value seconds(GstClockTime time) {
    return GST_CLOCK_TIME_IS_VALID(time) ? alloc_float(static_cast<double>(time) / GST_SECOND) : val_null;
}

CV_PRIM(videoencoder, create, 4, (value width, value height, value fps, value bitrate),
    std::unique_ptr<Encoder> output(new Encoder());
    output->open(val_get_int(width), val_get_int(height), val_get_int(fps), val_get_int(bitrate));
    value handle = alloc_abstract(k_VideoEncoder, output.release());
    val_gc(handle, finaliser<Encoder>);
    return handle;
);

CV_PRIM(videoencoder, write, 2, (value handle, value frame),
    return alloc_bool(encoder(handle).write(hx_cv_core_mat(frame)));
);

CV_PRIM(videoencoder, pollPackets, 2, (value handle, value maximum),
    std::vector<Packet> packets = encoder(handle).pollPackets(val_get_int(maximum));
    value result = alloc_array(static_cast<int>(packets.size()));
    for (size_t i = 0; i < packets.size(); ++i) {
        const Packet& packet = packets[i];
        buffer bytes = alloc_buffer_len(static_cast<int>(packet.data.size()));
        if (!packet.data.empty()) std::memcpy(buffer_data(bytes), packet.data.data(), packet.data.size());
        value item = alloc_empty_object();
        alloc_field(item, val_id("data"), buffer_val(bytes));
        alloc_field(item, val_id("timestamp"), seconds(packet.timestamp));
        alloc_field(item, val_id("decodeTimestamp"), seconds(packet.decodeTimestamp));
        alloc_field(item, val_id("duration"), seconds(packet.duration));
        alloc_field(item, val_id("keyFrame"), alloc_bool(packet.keyFrame));
        val_array_set_i(result, static_cast<int>(i), item);
    }
    return result;
);

CV_PRIM(videoencoder, requestKeyFrame, 1, (value handle),
    Encoder& output = encoder(handle);
    std::lock_guard<std::mutex> lock(output.mutex);
    output.collectErrors();
    if (output.closed || output.failed) return alloc_bool(false);
    return alloc_bool(gst_element_send_event(output.sink,
        gst_video_event_new_upstream_force_key_unit(GST_CLOCK_TIME_NONE, TRUE, 0)));
);

CV_PRIM(videoencoder, pollErrors, 1, (value handle),
    Encoder& output = encoder(handle);
    std::vector<std::string> errors;
    {
        std::lock_guard<std::mutex> lock(output.mutex);
        output.collectErrors();
        errors.swap(output.errors);
    }
    value result = alloc_array(static_cast<int>(errors.size()));
    for (size_t i = 0; i < errors.size(); ++i)
        val_array_set_i(result, static_cast<int>(i), alloc_string(errors[i].c_str()));
    return result;
);

CV_PRIM(videoencoder, release, 1, (value handle),
    encoder(handle).close();
    return val_null;
);

extern "C" void videoencoder_allocateKinds() {
    k_VideoEncoder = alloc_kind();
}
