#include "objdetect.h"
#include <vector>

DEFINE_KIND(k_FaceDetectorYN);

CV_PRIM(objdetect, FaceDetectorYN, 2, (value model, value scoreThreshold),
    val_check(model, string);
    cv::Ptr<cv::FaceDetectorYN> detector = cv::FaceDetectorYN::create(
        val_string(model), "", cv::Size(320, 320), val_get_double(scoreThreshold));
    value handle = alloc_abstract(k_FaceDetectorYN, new cv::Ptr<cv::FaceDetectorYN>(detector));
    val_gc(handle, finaliser<cv::Ptr<cv::FaceDetectorYN>>);
    return handle;
);

CV_PRIM(objdetect, FaceDetectorYN_detect, 2, (value handle, value image),
    val_check_kind(handle, k_FaceDetectorYN);
    cv::Mat& input = hx_cv_core_mat(image);
    cv::Ptr<cv::FaceDetectorYN>& detector = *static_cast<cv::Ptr<cv::FaceDetectorYN>*>(val_data(handle));
    detector->setInputSize(input.size());
    cv::Mat faces;
    detector->detect(input, faces);
    value output = alloc_array(faces.rows);
    for (int i = 0; i < faces.rows; ++i) {
        cv::Rect box(cvFloor(faces.at<float>(i, 0)), cvFloor(faces.at<float>(i, 1)),
            cvCeil(faces.at<float>(i, 2)), cvCeil(faces.at<float>(i, 3)));
        box &= cv::Rect(0, 0, input.cols, input.rows);
        val_array_set_i(output, i, hx_cv_core_toRect(new cv::Rect(box)));
    }
    return output;
);

static void writeMarkerCorners(const std::vector<std::vector<cv::Point2f>>& corners, value output) {
    int count = static_cast<int>(corners.size());
    val_array_set_size(output, count);
    for (int i = 0; i < count; ++i) {
        value points = alloc_array(4);
        val_array_set_i(output, i, points);
        for (int j = 0; j < 4; ++j) {
            val_array_set_i(points, j, hx_cv_core_toPoint2D32f(new cv::Point2f(corners[i][j])));
        }
    }
}

CV_PRIM(objdetect, detectMarkers, 3, (value image, value cornerOutput, value rejectedOutput),
    cv::Mat& input = hx_cv_core_mat(image);
    val_check(cornerOutput, array);
    if (!val_is_null(rejectedOutput)) {
        val_check(rejectedOutput, array);
    }
    cv::aruco::DetectorParameters parameters;
    parameters.adaptiveThreshConstant = 5;
    cv::aruco::ArucoDetector detector(cv::aruco::getPredefinedDictionary(cv::aruco::DICT_5X5_50), parameters);
    std::vector<std::vector<cv::Point2f>> corners;
    std::vector<std::vector<cv::Point2f>> rejected;
    std::vector<int> ids;
    cv::_OutputArray rejectedCorners = val_is_null(rejectedOutput) ? cv::_OutputArray() : cv::_OutputArray(rejected);
    detector.detectMarkers(input, corners, ids, rejectedCorners);

    int count = static_cast<int>(ids.size());
    value output = alloc_array(count);
    for (int i = 0; i < count; ++i) {
        val_array_set_i(output, i, alloc_int(ids[i]));
    }
    writeMarkerCorners(corners, cornerOutput);
    if (!val_is_null(rejectedOutput)) {
        writeMarkerCorners(rejected, rejectedOutput);
    }
    return output;
);

extern "C" void objdetect_allocateKinds() {
    k_FaceDetectorYN = alloc_kind();
}
