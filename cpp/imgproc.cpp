#include "imgproc.h"
#include <opencv2/features.hpp>
#include <vector>

static cv::Point kernelAnchor(value anchor) {
    return val_is_null(anchor) ? cv::Point(-1, -1) : hx_cv_core_asPoint(anchor);
}

CV_PRIM(imgproc, getStructuringElement, 3, (value shape, value size, value anchor),
    return hx_cv_core_toMat(new cv::Mat(cv::getStructuringElement(val_get_int(shape),
        hx_cv_core_asSize(size), kernelAnchor(anchor))));
);
CV_PRIM(imgproc, bilateralFilter, 5, (value src, value dst, value diameter, value color, value space),
    cv::bilateralFilter(hx_cv_core_mat(src), hx_cv_core_mat(dst), val_get_int(diameter),
        val_get_double(color), val_get_double(space));
    return val_null;
);
CV_PRIM(imgproc, dilate, 5, (value src, value dst, value kernel, value iterations, value anchor),
    cv::dilate(hx_cv_core_mat(src), hx_cv_core_mat(dst), hx_cv_core_optionalMat(kernel),
        kernelAnchor(anchor), val_get_int(iterations));
    return val_null;
);
CV_PRIM(imgproc, erode, 5, (value src, value dst, value kernel, value iterations, value anchor),
    cv::erode(hx_cv_core_mat(src), hx_cv_core_mat(dst), hx_cv_core_optionalMat(kernel),
        kernelAnchor(anchor), val_get_int(iterations));
    return val_null;
);
CV_PRIM_MULT(imgproc, morphologyEx, 6,
    cv::morphologyEx(hx_cv_core_mat(args[0]), hx_cv_core_mat(args[1]), val_get_int(args[2]),
        hx_cv_core_mat(args[3]), kernelAnchor(args[5]), val_get_int(args[4]));
    return val_null;
);
CV_PRIM(imgproc, equalizeHist, 2, (value src, value dst),
    cv::equalizeHist(hx_cv_core_mat(src), hx_cv_core_mat(dst));
    return val_null;
);
CV_PRIM(imgproc, equalizeHistAdaptive, 4, (value src, value dst, value clipLimit, value grid),
    cv::Size tileGrid = val_is_null(grid) ? cv::Size(8, 8) : hx_cv_core_asSize(grid);
    cv::createCLAHE(val_get_double(clipLimit), tileGrid)->apply(hx_cv_core_mat(src), hx_cv_core_mat(dst));
    return val_null;
);
CV_PRIM_MULT(imgproc, filter2D, 7,
    cv::filter2D(hx_cv_core_mat(args[0]), hx_cv_core_mat(args[1]), val_get_int(args[3]),
        hx_cv_core_mat(args[2]), kernelAnchor(args[4]), val_get_double(args[5]), val_get_int(args[6]));
    return val_null;
);
CV_PRIM_MULT(imgproc, gaussianBlur, 6,
    cv::GaussianBlur(hx_cv_core_mat(args[0]), hx_cv_core_mat(args[1]), hx_cv_core_asSize(args[2]),
        val_get_double(args[3]), val_get_double(args[4]), val_get_int(args[5]));
    return val_null;
);
CV_PRIM(imgproc, threshold, 5, (value src, value dst, value threshold, value maxValue, value type),
    return alloc_float(cv::threshold(hx_cv_core_mat(src), hx_cv_core_mat(dst), val_get_double(threshold),
        val_get_double(maxValue), val_get_int(type)));
);
CV_PRIM(imgproc, medianBlur, 3, (value src, value dst, value size),
    cv::medianBlur(hx_cv_core_mat(src), hx_cv_core_mat(dst), val_get_int(size));
    return val_null;
);
CV_PRIM(imgproc, pyrDown, 2, (value src, value dst),
    cv::pyrDown(hx_cv_core_mat(src), hx_cv_core_mat(dst));
    return val_null;
);
CV_PRIM(imgproc, laplace, 4, (value src, value dst, value depth, value size),
    cv::Laplacian(hx_cv_core_mat(src), hx_cv_core_mat(dst), val_get_int(depth), val_get_int(size));
    return val_null;
);
CV_PRIM_MULT(imgproc, sobel, 6,
    cv::Sobel(hx_cv_core_mat(args[0]), hx_cv_core_mat(args[1]), val_get_int(args[2]),
        val_get_int(args[3]), val_get_int(args[4]), val_get_int(args[5]));
    return val_null;
);
CV_PRIM(imgproc, integral, 4, (value src, value sum, value sqsum, value tilted),
    // OutputArray keeps absent outputs disabled while retained Mat references receive allocation.
    cv::_OutputArray squareOutput = val_is_null(sqsum) ? cv::_OutputArray() : cv::_OutputArray(hx_cv_core_mat(sqsum));
    cv::_OutputArray tiltedOutput = val_is_null(tilted) ? cv::_OutputArray() : cv::_OutputArray(hx_cv_core_mat(tilted));
    cv::integral(hx_cv_core_mat(src), hx_cv_core_mat(sum), squareOutput, tiltedOutput);
    return val_null;
);
CV_PRIM(imgproc, cvtColor, 3, (value src, value dst, value code),
    cv::cvtColor(hx_cv_core_mat(src), hx_cv_core_mat(dst), val_get_int(code));
    return val_null;
);
CV_PRIM(imgproc, distTransform, 5, (value src, value dst, value type, value size, value labels),
    if (val_is_null(labels))
        cv::distanceTransform(hx_cv_core_mat(src), hx_cv_core_mat(dst), val_get_int(type), val_get_int(size));
    else
        cv::distanceTransform(hx_cv_core_mat(src), hx_cv_core_mat(dst), hx_cv_core_mat(labels),
            val_get_int(type), val_get_int(size));
    return val_null;
);
CV_PRIM(imgproc, acc, 3, (value src, value sum, value mask),
    cv::accumulate(hx_cv_core_mat(src), hx_cv_core_mat(sum), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM(imgproc, squareAcc, 3, (value src, value sum, value mask),
    cv::accumulateSquare(hx_cv_core_mat(src), hx_cv_core_mat(sum), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM(imgproc, multiplyAcc, 4, (value src1, value src2, value sum, value mask),
    cv::accumulateProduct(hx_cv_core_mat(src1), hx_cv_core_mat(src2), hx_cv_core_mat(sum), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM(imgproc, runningAvg, 4, (value src, value sum, value alpha, value mask),
    cv::accumulateWeighted(hx_cv_core_mat(src), hx_cv_core_mat(sum), val_get_double(alpha), hx_cv_core_optionalMat(mask));
    return val_null;
);
CV_PRIM_MULT(imgproc, goodFeaturesToTrack, 8,
    std::vector<cv::Point2f> corners;
    cv::goodFeaturesToTrack(hx_cv_core_mat(args[0]), corners, val_get_int(args[1]), val_get_double(args[2]),
        val_get_double(args[3]), hx_cv_core_optionalMat(args[4]), val_get_int(args[5]),
        val_get_bool(args[6]), val_get_double(args[7]));
    value result = alloc_array(corners.size());
    for (int i = 0; i < static_cast<int>(corners.size()); ++i)
        val_array_set_i(result, i, hx_cv_core_toPoint2D32f(new cv::Point2f(corners[i])));
    return result;
);
