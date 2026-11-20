#include "highgui.h"
#include <map>
#include <memory>
#include <string>
#include <vector>

using WindowRoots = std::vector<AutoGCRoot*>;
static std::map<std::string, WindowRoots> windowRoots;

static void cleanupWindow(const std::string& name) {
    auto window = windowRoots.find(name);
    if (window == windowRoots.end()) return;
    for (AutoGCRoot* root : window->second) delete root;
    windowRoots.erase(window);
}

static void boundOnTrackbar(int position, void* userdata) {
    AutoGCRoot* root = static_cast<AutoGCRoot*>(userdata);
    val_call1(root->get(), alloc_int(position));
}

static void boundOnMouse(int event, int x, int y, int flags, void* userdata) {
    AutoGCRoot* root = static_cast<AutoGCRoot*>(userdata);
    value args[4] = {alloc_int(event), alloc_int(x), alloc_int(y), alloc_int(flags)};
    val_callN(root->get(), args, 4);
}

CV_PRIM(highgui, loadImage, 2, (value filename, value flags),
    cv::Mat image = cv::imread(val_get_string(filename), val_get_int(flags));
    if (image.empty()) return val_null;
    return hx_cv_core_toMat(new cv::Mat(image));
);
CV_PRIM(highgui, saveImage, 2, (value filename, value image),
    return alloc_bool(cv::imwrite(val_get_string(filename), hx_cv_core_mat(image)));
);
CV_PRIM(highgui, waitKey, 1, (value delay),
    return alloc_int(cv::waitKey(val_get_int(delay)));
);
CV_PRIM(highgui, namedWindow, 2, (value name, value flags),
    cv::namedWindow(val_get_string(name), val_get_int(flags));
    return val_null;
);
CV_PRIM(highgui, showImage, 2, (value name, value image),
    cv::imshow(val_get_string(name), hx_cv_core_mat(image));
    return val_null;
);
CV_PRIM(highgui, moveWindow, 3, (value name, value x, value y),
    cv::moveWindow(val_get_string(name), val_get_int(x), val_get_int(y));
    return val_null;
);
CV_PRIM(highgui, resizeWindow, 3, (value name, value width, value height),
    cv::resizeWindow(val_get_string(name), val_get_int(width), val_get_int(height));
    return val_null;
);
CV_PRIM(highgui, destroyWindow, 1, (value name),
    std::string windowName = val_get_string(name);
    cv::destroyWindow(windowName);
    cleanupWindow(windowName);
    return val_null;
);
CV_PRIM(highgui, destroyAllWindows, 0, (),
    cv::destroyAllWindows();
    while (!windowRoots.empty()) cleanupWindow(windowRoots.begin()->first);
    return val_null;
);

CV_PRIM(highgui, createTrackbar, 5, (value name, value window, value initial, value count, value onChange),
    std::string trackbarName = val_get_string(name);
    std::string windowName = val_get_string(window);
    std::unique_ptr<AutoGCRoot> root;
    if (!val_is_null(onChange)) {
        val_check_function(onChange, 1);
        root.reset(new AutoGCRoot(onChange));
    }
    // OpenCV manages each position; no shared or borrowed integer storage.
    int created = cv::createTrackbar(trackbarName, windowName, nullptr, val_get_int(count),
        root ? boundOnTrackbar : nullptr, root.get());
    if (created) {
        if (root) windowRoots[windowName].push_back(root.release());
        cv::setTrackbarPos(trackbarName, windowName, val_get_int(initial));
    }
    return alloc_bool(created != 0);
);
CV_PRIM(highgui, getTrackbarPos, 2, (value name, value window),
    return alloc_int(cv::getTrackbarPos(val_get_string(name), val_get_string(window)));
);
CV_PRIM(highgui, setTrackbarPos, 3, (value name, value window, value position),
    cv::setTrackbarPos(val_get_string(name), val_get_string(window), val_get_int(position));
    return val_null;
);
CV_PRIM(highgui, setMouseCallback, 2, (value window, value onMouse),
    std::string windowName = val_get_string(window);
    if (val_is_null(onMouse)) {
        cv::setMouseCallback(windowName, nullptr);
    } else {
        val_check_function(onMouse, 4);
        std::unique_ptr<AutoGCRoot> root(new AutoGCRoot(onMouse));
        cv::setMouseCallback(windowName, boundOnMouse, root.get());
        windowRoots[windowName].push_back(root.release());
    }
    return val_null;
);

DEFINE_KIND(k_Capture);

static cv::VideoCapture& capture(value handle) {
    val_check_kind(handle, k_Capture);
    return *static_cast<cv::VideoCapture*>(val_data(handle));
}

CV_PRIM(highgui, captureFromFile, 2, (value filename, value backend),
    std::unique_ptr<cv::VideoCapture> input(new cv::VideoCapture());
    if (!input->open(val_get_string(filename), val_get_int(backend))) return val_null;
    value handle = alloc_abstract(k_Capture, input.release());
    val_gc(handle, finaliser<cv::VideoCapture>);
    return handle;
);
CV_PRIM(highgui, getCaptureProperty, 2, (value handle, value property),
    return alloc_float(capture(handle).get(val_get_int(property)));
);
CV_PRIM(highgui, setCaptureProperty, 3, (value handle, value property, value number),
    return alloc_bool(capture(handle).set(val_get_int(property), val_get_double(number)));
);
CV_PRIM(highgui, grabFrame, 1, (value handle),
    return alloc_bool(capture(handle).grab());
);
CV_PRIM(highgui, retrieveFrame, 1, (value handle),
    cv::Mat frame;
    if (!capture(handle).retrieve(frame) || frame.empty()) return val_null;
    // Detach decoded storage so later backend operations cannot overwrite this frame.
    return hx_cv_core_toMat(new cv::Mat(frame.clone()));
);
CV_PRIM(highgui, readFrame, 1, (value handle),
    cv::Mat frame;
    if (!capture(handle).read(frame) || frame.empty()) return val_null;
    return hx_cv_core_toMat(new cv::Mat(frame.clone()));
);
CV_PRIM(highgui, releaseCapture, 1, (value handle),
    capture(handle).release();
    return val_null;
);

extern "C" void highgui_allocateKinds() {
    k_Capture = alloc_kind();
}
