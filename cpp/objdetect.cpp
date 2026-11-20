#include "objdetect.h"

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

extern "C" void objdetect_allocateKinds() {
    k_FaceDetectorYN = alloc_kind();
}
