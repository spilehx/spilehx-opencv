#include "videoio.h"
#include <memory>

DEFINE_KIND(k_Capture);

static cv::VideoCapture& capture(value handle) {
    val_check_kind(handle, k_Capture);
    return *static_cast<cv::VideoCapture*>(val_data(handle));
}

CV_PRIM(videoio, fromFile, 2, (value filename, value backend),
    std::unique_ptr<cv::VideoCapture> input(new cv::VideoCapture());
    if (!input->open(val_get_string(filename), val_get_int(backend))) return val_null;
    value handle = alloc_abstract(k_Capture, input.release());
    val_gc(handle, finaliser<cv::VideoCapture>);
    return handle;
);
CV_PRIM(videoio, fromCamera, 2, (value index, value backend),
    std::unique_ptr<cv::VideoCapture> input(new cv::VideoCapture());
    if (!input->open(val_get_int(index), val_get_int(backend))) return val_null;
    value handle = alloc_abstract(k_Capture, input.release());
    val_gc(handle, finaliser<cv::VideoCapture>);
    return handle;
);
CV_PRIM(videoio, getProperty, 2, (value handle, value property),
    return alloc_float(capture(handle).get(val_get_int(property)));
);
CV_PRIM(videoio, setProperty, 3, (value handle, value property, value number),
    return alloc_bool(capture(handle).set(val_get_int(property), val_get_double(number)));
);
CV_PRIM(videoio, grabFrame, 1, (value handle),
    return alloc_bool(capture(handle).grab());
);
CV_PRIM(videoio, retrieveFrame, 1, (value handle),
    cv::Mat frame;
    if (!capture(handle).retrieve(frame) || frame.empty()) return val_null;
    // Detach decoded storage so later backend operations cannot overwrite this frame.
    return hx_cv_core_toMat(new cv::Mat(frame.clone()));
);
CV_PRIM(videoio, readFrame, 1, (value handle),
    cv::Mat frame;
    if (!capture(handle).read(frame) || frame.empty()) return val_null;
    return hx_cv_core_toMat(new cv::Mat(frame.clone()));
);
CV_PRIM(videoio, release, 1, (value handle),
    capture(handle).release();
    return val_null;
);

extern "C" void videoio_allocateKinds() {
    k_Capture = alloc_kind();
}
