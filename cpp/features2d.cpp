#include "features2d.h"
#include <vector>

DEFINE_KIND(k_KeyPoint);
DEFINE_KIND(k_GFFT);
DEFINE_KIND(k_SIFT);

static cv::KeyPoint& keypoint(value handle) {
    val_check_kind(handle, k_KeyPoint);
    return *static_cast<cv::KeyPoint*>(val_data(handle));
}

static value toKeyPoint(const cv::KeyPoint& point) {
    value handle = alloc_abstract(k_KeyPoint, new cv::KeyPoint(point));
    val_gc(handle, finaliser<cv::KeyPoint>);
    return handle;
}

static void writeKeypoints(value output, const std::vector<cv::KeyPoint>& points) {
    val_check(output, array);
    int previousCount = val_array_size(output);
    val_array_set_size(output, points.size());
    for (int i = 0; i < static_cast<int>(points.size()); ++i) {
        if (i >= previousCount || val_is_null(val_array_i(output, i)))
            val_array_set_i(output, i, toKeyPoint(points[i]));
        else
            keypoint(val_array_i(output, i)) = points[i];
    }
}

#define KEYPOINT_PROPERTY(name, allocate) \
    CV_PRIM(features2d, KeyPoint_get_##name, 1, (value handle), \
        return allocate(keypoint(handle).name); \
    )

KEYPOINT_PROPERTY(size, alloc_float);
KEYPOINT_PROPERTY(angle, alloc_float);
KEYPOINT_PROPERTY(response, alloc_float);
KEYPOINT_PROPERTY(octave, alloc_int);
KEYPOINT_PROPERTY(class_id, alloc_int);

CV_PRIM(features2d, KeyPoint_get_pt, 1, (value handle),
    return hx_cv_core_toPoint2D32f(new cv::Point2f(keypoint(handle).pt));
);
CV_PRIM_MULT(features2d, KeyPoint_make, 7,
    return toKeyPoint(cv::KeyPoint(val_get_double(args[0]), val_get_double(args[1]),
        val_get_double(args[2]), val_get_double(args[3]), val_get_double(args[4]),
        val_get_int(args[5]), val_get_int(args[6])));
);

CV_PRIM_MULT(features2d, GFFT, 6,
    cv::Ptr<cv::GFTTDetector> detector = cv::GFTTDetector::create(val_get_int(args[0]),
        val_get_double(args[1]), val_get_double(args[2]), val_get_int(args[3]),
        val_get_bool(args[4]), val_get_double(args[5]));
    value handle = alloc_abstract(k_GFFT, new cv::Ptr<cv::GFTTDetector>(detector));
    val_gc(handle, finaliser<cv::Ptr<cv::GFTTDetector>>);
    return handle;
);
CV_PRIM(features2d, GFFT_detect, 4, (value handle, value image, value mask, value output),
    val_check_kind(handle, k_GFFT);
    val_check(output, array);
    std::vector<cv::KeyPoint> points;
    (*static_cast<cv::Ptr<cv::GFTTDetector>*>(val_data(handle)))->detect(
        hx_cv_core_mat(image), points, hx_cv_core_optionalMat(mask));
    writeKeypoints(output, points);
    return alloc_int(points.size());
);

CV_PRIM(features2d, SIFT, 5, (value count, value layers, value contrast, value edge, value sigma),
    cv::Ptr<cv::SIFT> detector = cv::SIFT::create(val_get_int(count), val_get_int(layers),
        val_get_double(contrast), val_get_double(edge), val_get_double(sigma));
    value handle = alloc_abstract(k_SIFT, new cv::Ptr<cv::SIFT>(detector));
    val_gc(handle, finaliser<cv::Ptr<cv::SIFT>>);
    return handle;
);
CV_PRIM_MULT(features2d, SIFT_detectAndCompute, 6,
    val_check_kind(args[0], k_SIFT);
    value output = args[3];
    val_check(output, array);
    std::vector<cv::KeyPoint> points;
    bool useProvided = val_get_bool(args[5]);
    if (useProvided) {
        for (int i = 0; i < val_array_size(output); ++i)
            points.push_back(keypoint(val_array_i(output, i)));
    }
    (*static_cast<cv::Ptr<cv::SIFT>*>(val_data(args[0])))->detectAndCompute(
        hx_cv_core_mat(args[1]), hx_cv_core_optionalMat(args[2]), points,
        hx_cv_core_mat(args[4]), useProvided);
    writeKeypoints(output, points);
    return alloc_int(points.size());
);

extern "C" void features2d_allocateKinds() {
    k_KeyPoint = alloc_kind();
    k_GFFT = alloc_kind();
    k_SIFT = alloc_kind();
}
