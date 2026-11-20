#pragma once

#include <opencv2/core.hpp>
#include "utils.h"

DECLARE_KIND(k_Mat);
cv::Mat& hx_cv_core_mat(value handle);
value hx_cv_core_toMat(cv::Mat* matrix);
// Null masks and kernels are represented by empty matrices.
cv::Mat hx_cv_core_optionalMat(value handle);

#define CORE_TYPE(name, type) \
    DECLARE_KIND(k_##name); \
    type& hx_cv_core_as##name(value handle); \
    value hx_cv_core_to##name(type* object)

CORE_TYPE(Point, cv::Point);
CORE_TYPE(Point2D32f, cv::Point2f);
CORE_TYPE(Point2D64f, cv::Point2d);
CORE_TYPE(Point3D32f, cv::Point3f);
CORE_TYPE(Point3D64f, cv::Point3d);
CORE_TYPE(Size, cv::Size);
CORE_TYPE(Size2D32f, cv::Size2f);
CORE_TYPE(Rect, cv::Rect);
CORE_TYPE(Scalar, cv::Scalar);
CORE_TYPE(TermCriteria, cv::TermCriteria);

extern "C" void core_allocateKinds();
