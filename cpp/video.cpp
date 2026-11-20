#include "video.h"
#include <vector>

CV_PRIM_MULT(video, calcOpticalFlowPyrLK, 11,
    cv::Mat& previousImage = hx_cv_core_mat(args[0]);
    cv::Mat& currentImage = hx_cv_core_mat(args[1]);
    value previousPoints = args[2];
    value currentPoints = args[3];
    value status = args[4];
    value error = args[5];
    val_check(previousPoints, array);
    val_check(currentPoints, array);
    val_check(status, array);
    if (!val_is_null(error)) val_check(error, array);
    int count = val_array_size(previousPoints);
    int previousOutputCount = val_array_size(currentPoints);
    int flags = val_get_int(args[9]);
    bool useInitialFlow = (flags & cv::OPTFLOW_USE_INITIAL_FLOW) != 0;
    CV_Assert(!useInitialFlow || previousOutputCount == count);

    std::vector<cv::Point2f> previous, current;
    std::vector<uchar> trackingStatus;
    std::vector<float> trackingError;
    for (int i = 0; i < count; ++i) {
        previous.push_back(hx_cv_core_asPoint2D32f(val_array_i(previousPoints, i)));
        if (useInitialFlow) current.push_back(hx_cv_core_asPoint2D32f(val_array_i(currentPoints, i)));
    }
    cv::Size window = val_is_null(args[6]) ? cv::Size(21, 21) : hx_cv_core_asSize(args[6]);
    cv::TermCriteria criteria = val_is_null(args[8])
        ? cv::TermCriteria(cv::TermCriteria::COUNT | cv::TermCriteria::EPS, 30, 0.01)
        : hx_cv_core_asTermCriteria(args[8]);
    cv::_OutputArray errorOutput = val_is_null(error) ? cv::_OutputArray() : cv::_OutputArray(trackingError);
    if (count > 0) {
        cv::calcOpticalFlowPyrLK(previousImage, currentImage, previous, current, trackingStatus,
            errorOutput, window, val_get_int(args[7]), criteria, flags, val_get_double(args[10]));
    }

    val_array_set_size(currentPoints, count);
    val_array_set_size(status, count);
    if (!val_is_null(error)) val_array_set_size(error, count);
    for (int i = 0; i < count; ++i) {
        if (i >= previousOutputCount || val_is_null(val_array_i(currentPoints, i)))
            val_array_set_i(currentPoints, i, hx_cv_core_toPoint2D32f(new cv::Point2f(current[i])));
        else
            hx_cv_core_asPoint2D32f(val_array_i(currentPoints, i)) = current[i];
        val_array_set_i(status, i, alloc_bool(trackingStatus[i] != 0));
        if (!val_is_null(error)) val_array_set_i(error, i, alloc_float(trackingError[i]));
    }
    return val_null;
);

CV_PRIM_MULT(video, calcOpticalFlowFarneback, 10,
    cv::calcOpticalFlowFarneback(hx_cv_core_mat(args[0]), hx_cv_core_mat(args[1]), hx_cv_core_mat(args[2]),
        val_get_double(args[3]), val_get_int(args[4]), val_get_int(args[5]), val_get_int(args[6]),
        val_get_int(args[7]), val_get_double(args[8]), val_get_int(args[9]));
    return val_null;
);
